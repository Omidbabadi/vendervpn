import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/core/utils/app_log.dart';

class SubscriptionItem {
  const SubscriptionItem({
    required this.id,
    required this.name,
    required this.url,
    required this.intervalHours,
    required this.lastUpdated,
    this.userInfo,
  });

  final String id;
  final String name;
  final String url;
  final int intervalHours;
  final DateTime lastUpdated;
  final SubscriptionUserInfo? userInfo;

  bool get isDueForUpdate {
    if (intervalHours <= 0) return false;
    return DateTime.now().difference(lastUpdated) >=
        Duration(hours: intervalHours);
  }

  SubscriptionItem copyWith({
    String? id,
    String? name,
    String? url,
    int? intervalHours,
    DateTime? lastUpdated,
    SubscriptionUserInfo? userInfo,
  }) {
    return SubscriptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      intervalHours: intervalHours ?? this.intervalHours,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'url': url,
    'intervalHours': intervalHours,
    'lastUpdated': lastUpdated.toIso8601String(),
    if (userInfo != null) 'userInfo': userInfo!.toMap(),
  };

  factory SubscriptionItem.fromMap(Map<String, dynamic> map) {
    final url = (map['url'] as String? ?? '').trim();
    final uri = Uri.tryParse(url);
    final fallbackName =
        (uri != null && uri.host.isNotEmpty) ? uri.host : 'Subscription';
    final rawName = (map['name'] as String? ?? '').trim();
    final rawUserInfo = map['userInfo'];
    return SubscriptionItem(
      id: map['id'] as String? ?? 'sub_${url.hashCode.abs()}',
      name: rawName.isNotEmpty ? rawName : fallbackName,
      url: url,
      intervalHours:
          int.tryParse((map['intervalHours'] ?? '6').toString()) ?? 6,
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
      userInfo:
          rawUserInfo is Map
              ? SubscriptionUserInfo.fromMap(
                Map<String, dynamic>.from(rawUserInfo),
              )
              : null,
    );
  }
}

final subscriptionsListProvider =
    NotifierProvider<SubscriptionsList, List<SubscriptionItem>>(
      SubscriptionsList.new,
    );

class SubscriptionsList extends Notifier<List<SubscriptionItem>> {
  final _cacheHelper = sl<CacheHelper>();

  @override
  List<SubscriptionItem> build() {
    return _cacheHelper.subscriptions
        .map(SubscriptionItem.fromMap)
        .where((s) => s.url.isNotEmpty)
        .toList();
  }

  Future<SubscriptionItem> upsertSubscription({
    required String name,
    required String url,
    required int intervalHours,
    SubscriptionUserInfo? userInfo,
  }) async {
    final cleanUrl = url.trim();
    final uri = Uri.tryParse(cleanUrl);
    final fallbackName =
        (uri != null && uri.host.isNotEmpty) ? uri.host : 'Subscription';
    final cleanName = name.trim().isNotEmpty ? name.trim() : fallbackName;
    final id = 'sub_${cleanUrl.hashCode.abs()}';

    SubscriptionUserInfo? previousUserInfo;
    for (final s in state) {
      if (s.id == id || s.url == cleanUrl) {
        previousUserInfo = s.userInfo;
        break;
      }
    }

    final item = SubscriptionItem(
      id: id,
      name: cleanName,
      url: cleanUrl,
      intervalHours: intervalHours,
      lastUpdated: DateTime.now(),
      userInfo: userInfo ?? previousUserInfo,
    );

    final updated = [
      for (final s in state)
        if (s.id != id && s.url != cleanUrl) s,
      item,
    ];
    state = updated;
    await _persist(updated);
    return item;
  }

  Future<void> markUpdated(String id, {SubscriptionUserInfo? userInfo}) async {
    final updated = [
      for (final s in state)
        if (s.id == id)
          s.copyWith(lastUpdated: DateTime.now(), userInfo: userInfo)
        else
          s,
    ];
    state = updated;
    await _persist(updated);
  }

  Future<void> updateUserInfo(String id, SubscriptionUserInfo userInfo) async {
    final updated = [
      for (final s in state)
        if (s.id == id) s.copyWith(userInfo: userInfo) else s,
    ];
    state = updated;
    await _persist(updated);
  }

  Future<void> removeById(String id) async {
    final updated = state.where((s) => s.id != id).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> clearAll() async {
    state = [];
    await _cacheHelper.cacheSubscriptions([]);
  }

  Future<void> _persist(List<SubscriptionItem> items) async {
    await _cacheHelper.cacheSubscriptions(items.map((e) => e.toMap()).toList());
  }
}

final localConfigsListProvider =
    NotifierProvider<LocalConfigsList, List<Config>>(LocalConfigsList.new);

class LocalConfigsList extends Notifier<List<Config>> {
  final _cacheHelper = sl<CacheHelper>();
  Timer? _autoSyncTimer;
  bool _isCheckingAutoSync = false;

  @override
  List<Config> build() {
    final rawList = _cacheHelper.localConfigs;
    final selectedId = _cacheHelper.id;
    final nodeCountries = _cacheHelper.nodeCountryMap;
    final List<Config> loaded = [];

    for (final e in rawList) {
      if ((e['uri'] as String? ?? '').isEmpty) continue;
      try {
        loaded.add(
          V2rayImportHelper.configFromCacheMap(
            e,
            selectedId: selectedId,
            nodeCountries: nodeCountries,
            defaultImportedFrom: 'local',
            readServerIp: true,
          ),
        );
      } catch (err) {
        appLog('Skipping corrupt cached local config: $err');
      }
    }

    _scheduleAutoUpdateCheck();
    return loaded;
  }

  void _scheduleAutoUpdateCheck() {
    _autoSyncTimer?.cancel();
    // Check immediately after startup microtask, then every 5 minutes while app runs
    Future.microtask(checkAndRefreshDueSubscriptions);
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => checkAndRefreshDueSubscriptions(),
    );
    ref.onDispose(() {
      _autoSyncTimer?.cancel();
    });
  }

  /// Checks all saved subscriptions and automatically re-fetches any whose
  /// configured `intervalHours` has elapsed since `lastUpdated`, or fetches
  /// missing `Subscription-Userinfo` headers for previously saved subscriptions.
  Future<int> checkAndRefreshDueSubscriptions() async {
    if (_isCheckingAutoSync) return 0;
    _isCheckingAutoSync = true;
    var totalUpdated = 0;
    try {
      final subs = ref.read(subscriptionsListProvider);
      final subsNotifier = ref.read(subscriptionsListProvider.notifier);
      for (final sub in subs) {
        if (sub.isDueForUpdate) {
          try {
            final count = await refreshSubscription(sub);
            totalUpdated += count;
          } catch (e) {
            appLog('Auto-sync failed for subscription "${sub.name}": $e');
          }
        } else if (sub.userInfo == null) {
          try {
            final info = await V2rayImportHelper.fetchSubscriptionUserInfo(
              sub.url,
            );
            if (info != null) {
              await subsNotifier.updateUserInfo(sub.id, info);
            }
          } catch (e) {
            appLog(
              'Userinfo fetch failed for subscription "${sub.name}": $e',
            );
          }
        }
      }
    } finally {
      _isCheckingAutoSync = false;
    }
    return totalUpdated;
  }

  Future<int> importFromRawPayload(
    String rawInput, {
    String source = 'clipboard',
  }) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return 0;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return importSubscriptionUrl(trimmed);
    }

    final links = V2rayImportHelper.extractLinksFromPayload(trimmed);
    if (links.isEmpty) return 0;

    final parsedModels = await V2rayImportHelper.parseLinksToConfigs(
      links: links,
      importedFrom: source,
    );
    if (parsedModels.isEmpty) return 0;

    await _mergeAndPersist(parsedModels);
    return parsedModels.length;
  }

  Future<int> importSubscriptionUrl(
    String subUrl, {
    String? name,
    int intervalHours = 6,
  }) async {
    final cleanUrl = subUrl.trim();
    final subsNotifier = ref.read(subscriptionsListProvider.notifier);
    final fetched = await V2rayImportHelper.fetchSubscription(cleanUrl);
    if (fetched.links.isEmpty) return 0;

    final subItem = await subsNotifier.upsertSubscription(
      name: name ?? '',
      url: cleanUrl,
      intervalHours: intervalHours,
      userInfo: fetched.userInfo,
    );

    final sourceTag = 'sub:${subItem.name}';
    final parsedModels = await V2rayImportHelper.parseLinksToConfigs(
      links: fetched.links,
      importedFrom: sourceTag,
      idScope: sourceTag,
    );
    if (parsedModels.isEmpty) return 0;

    await _replaceSubscriptionNodesAndPersist(
      sourceTag: sourceTag,
      newModels: parsedModels,
    );
    return parsedModels.length;
  }

  Future<int> refreshSubscription(SubscriptionItem sub) async {
    final subsNotifier = ref.read(subscriptionsListProvider.notifier);
    final fetched = await V2rayImportHelper.fetchSubscription(sub.url);
    if (fetched.links.isEmpty) return 0;

    final sourceTag = 'sub:${sub.name}';
    final parsedModels = await V2rayImportHelper.parseLinksToConfigs(
      links: fetched.links,
      importedFrom: sourceTag,
      idScope: sourceTag,
    );
    if (parsedModels.isEmpty) return 0;

    await subsNotifier.markUpdated(sub.id, userInfo: fetched.userInfo);
    await _replaceSubscriptionNodesAndPersist(
      sourceTag: sourceTag,
      newModels: parsedModels,
    );
    return parsedModels.length;
  }

  Future<void> removeSubscriptionAndNodes(SubscriptionItem sub) async {
    final sourceTag = 'sub:${sub.name}';
    await ref.read(subscriptionsListProvider.notifier).removeById(sub.id);
    final remaining = state.where((c) => c.importedFrom != sourceTag).toList();
    state = remaining;
    await _persistState(remaining);
  }

  Future<void> _replaceSubscriptionNodesAndPersist({
    required String sourceTag,
    required List<Config> newModels,
  }) async {
    // Keep nodes from other sources; replace nodes belonging to this subscription.
    // Keyed by id (scoped per source), so a link shared with another
    // subscription or a direct import is never stolen from it.
    final retained = state.where((c) => c.importedFrom != sourceTag).toList();
    final existingById = <String, Config>{for (final c in retained) c.id: c};
    for (final model in newModels) {
      existingById[model.id] = model;
    }
    final merged = existingById.values.toList();
    state = merged;
    await _persistState(merged);

    final current = ref.read(currentConfigProvider);
    if (current == null) {
      if (merged.isNotEmpty) {
        await ref
            .read(currentConfigProvider.notifier)
            .setCurrentConfig(merged.first);
      }
      return;
    }

    // If the selected node belonged to this subscription, re-point the
    // selection at its refreshed copy (ids may change, e.g. legacy unscoped
    // ids migrating to per-subscription ids).
    if (current.importedFrom == sourceTag &&
        !merged.any((c) => c.id == current.id)) {
      for (final model in newModels) {
        if (model.uri == current.uri) {
          await ref
              .read(currentConfigProvider.notifier)
              .setCurrentConfig(model);
          break;
        }
      }
    }
  }

  Future<void> _mergeAndPersist(List<Config> newModels) async {
    final existingById = <String, Config>{for (final c in state) c.id: c};
    for (final model in newModels) {
      existingById[model.id] = model;
    }
    final merged = existingById.values.toList();
    state = merged;
    await _persistState(merged);

    if (ref.read(currentConfigProvider) == null && merged.isNotEmpty) {
      await ref
          .read(currentConfigProvider.notifier)
          .setCurrentConfig(merged.first);
    }
  }

  Future<void> removeConfig(String id) async {
    final updated = state.where((c) => c.id != id).toList();
    state = updated;
    await _persistState(updated);
  }

  Future<void> clearAll() async {
    state = [];
    await _cacheHelper.cacheLocalConfigs([]);
    await ref.read(subscriptionsListProvider.notifier).clearAll();
  }

  void updateConfigPing(String id, int ping) {
    final updated = [
      for (final config in state)
        if (config.id == id) config.copyWith(ping: ping) else config,
    ];
    state = updated;
    _persistState(updated);
  }

  Future<void> updateConfigEndpoint(
    String id, {
    required String serverIp,
    String? countryCode,
  }) async {
    final updated = [
      for (final config in state)
        if (config.id == id)
          config.copyWith(serverIp: serverIp, country: countryCode)
        else
          config,
    ];
    state = updated;
    await _persistState(updated);
  }

  /// Puts a node that was edited and already saved to storage back into the
  /// list, in place of the old version (matched by id).
  void applySavedConfig(Config saved) {
    state = [
      for (final config in state)
        if (config.id == saved.id) saved else config,
    ];
  }

  Future<void> _persistState(List<Config> list) async {
    await _cacheHelper.cacheLocalConfigs(
      list.map(V2rayImportHelper.configToCacheMap).toList(),
    );
  }
}

final pingingNodeIdsProvider =
    NotifierProvider<PingingNodeIdsNotifier, Set<String>>(
      PingingNodeIdsNotifier.new,
    );

class PingingNodeIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void setPinging(String id, bool isPinging) {
    if (isPinging) {
      state = {...state, id};
    } else {
      final next = {...state}..remove(id);
      state = next;
    }
  }
}

class NodesViewUiState {
  const NodesViewUiState({
    this.selectedTab = 0,
    this.isImporting = false,
    this.isPingingAll = false,
    this.isAutoConnectingFastest = false,
    this.subIntervalHours = 6,
    this.collapsedSubKeys = const <String>{},
    this.refreshingSubIds = const <String>{},
  });

  final int selectedTab;
  final bool isImporting;
  final bool isPingingAll;
  final bool isAutoConnectingFastest;
  final int subIntervalHours;
  final Set<String> collapsedSubKeys;

  /// IDs of subscriptions currently being refreshed from their card.
  final Set<String> refreshingSubIds;

  NodesViewUiState copyWith({
    int? selectedTab,
    bool? isImporting,
    bool? isPingingAll,
    bool? isAutoConnectingFastest,
    int? subIntervalHours,
    Set<String>? collapsedSubKeys,
    Set<String>? refreshingSubIds,
  }) {
    return NodesViewUiState(
      selectedTab: selectedTab ?? this.selectedTab,
      isImporting: isImporting ?? this.isImporting,
      isPingingAll: isPingingAll ?? this.isPingingAll,
      isAutoConnectingFastest:
          isAutoConnectingFastest ?? this.isAutoConnectingFastest,
      subIntervalHours: subIntervalHours ?? this.subIntervalHours,
      collapsedSubKeys: collapsedSubKeys ?? this.collapsedSubKeys,
      refreshingSubIds: refreshingSubIds ?? this.refreshingSubIds,
    );
  }
}

final nodesViewUiStateProvider =
    NotifierProvider<NodesViewUiStateNotifier, NodesViewUiState>(
      NodesViewUiStateNotifier.new,
    );

class NodesViewUiStateNotifier extends Notifier<NodesViewUiState> {
  @override
  NodesViewUiState build() => const NodesViewUiState();

  void setSelectedTab(int tab) => state = state.copyWith(selectedTab: tab);
  void setImporting(bool value) => state = state.copyWith(isImporting: value);
  void setPingingAll(bool value) => state = state.copyWith(isPingingAll: value);
  void setAutoConnectingFastest(bool value) =>
      state = state.copyWith(isAutoConnectingFastest: value);
  void setSubIntervalHours(int hours) =>
      state = state.copyWith(subIntervalHours: hours);

  void setSubRefreshing(String id, bool value) {
    final next = {...state.refreshingSubIds};
    value ? next.add(id) : next.remove(id);
    state = state.copyWith(refreshingSubIds: next);
  }

  void toggleSubExpanded(String key) {
    final next = {...state.collapsedSubKeys};
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = state.copyWith(collapsedSubKeys: next);
  }
}
