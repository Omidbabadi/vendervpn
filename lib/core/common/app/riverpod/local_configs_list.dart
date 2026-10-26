import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

class SubscriptionItem {
  const SubscriptionItem({
    required this.id,
    required this.name,
    required this.url,
    required this.intervalHours,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final String url;
  final int intervalHours;
  final DateTime lastUpdated;

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
  }) {
    return SubscriptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      intervalHours: intervalHours ?? this.intervalHours,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'url': url,
    'intervalHours': intervalHours,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory SubscriptionItem.fromMap(Map<String, dynamic> map) {
    final url = (map['url'] as String? ?? '').trim();
    final uri = Uri.tryParse(url);
    final fallbackName =
        (uri != null && uri.host.isNotEmpty) ? uri.host : 'Subscription';
    final rawName = (map['name'] as String? ?? '').trim();
    return SubscriptionItem(
      id: map['id'] as String? ?? 'sub_${url.hashCode.abs()}',
      name: rawName.isNotEmpty ? rawName : fallbackName,
      url: url,
      intervalHours:
          int.tryParse((map['intervalHours'] ?? '6').toString()) ?? 6,
      lastUpdated:
          DateTime.tryParse(map['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
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
  }) async {
    final cleanUrl = url.trim();
    final uri = Uri.tryParse(cleanUrl);
    final fallbackName =
        (uri != null && uri.host.isNotEmpty) ? uri.host : 'Subscription';
    final cleanName = name.trim().isNotEmpty ? name.trim() : fallbackName;
    final id = 'sub_${cleanUrl.hashCode.abs()}';

    final item = SubscriptionItem(
      id: id,
      name: cleanName,
      url: cleanUrl,
      intervalHours: intervalHours,
      lastUpdated: DateTime.now(),
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

  Future<void> markUpdated(String id) async {
    final updated = [
      for (final s in state)
        if (s.id == id) s.copyWith(lastUpdated: DateTime.now()) else s,
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
    await _cacheHelper.cacheSubscriptions(
      items.map((e) => e.toMap()).toList(),
    );
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
    final List<Config> loaded = [];

    for (final e in rawList) {
      try {
        final uri = e['uri'] as String? ?? '';
        if (uri.isEmpty) continue;
        final parser = V2ray.parseFromURL(uri);
        final fullJson =
            V2rayImportHelper.buildFullConfigurationWithHttpInbound(parser);
        final id = e['id'] as String? ?? 'local_${uri.hashCode.abs()}';
        loaded.add(
          Config(
            configjson: fullJson,
            importedFrom: e['importedFrom'] as String? ?? 'local',
            remark: e['remark'] as String? ?? parser.remark,
            port: int.tryParse((e['port'] ?? '0').toString()) ?? parser.port,
            address: e['address'] as String? ?? parser.address,
            uri: uri,
            dateAdded:
                e['dateAdded'] as String? ?? DateTime.now().toIso8601String(),
            id: id,
            isSelected: id == selectedId,
            country: e['country'] as String? ?? 'US',
            serverIp:
                (e['serverIp'] as String?) != null &&
                        e['serverIp'] != 'N/A' &&
                        e['serverIp'] != parser.address
                    ? e['serverIp'] as String
                    : null,
            ping: int.tryParse((e['ping'] ?? '-1').toString()) ?? -1,
          ),
        );
      } catch (err) {
        debugPrint('Skipping corrupt cached local config: $err');
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
  /// configured `intervalHours` has elapsed since `lastUpdated`.
  Future<int> checkAndRefreshDueSubscriptions() async {
    if (_isCheckingAutoSync) return 0;
    _isCheckingAutoSync = true;
    var totalUpdated = 0;
    try {
      final subs = ref.read(subscriptionsListProvider);
      for (final sub in subs) {
        if (sub.isDueForUpdate) {
          try {
            final count = await refreshSubscription(sub);
            totalUpdated += count;
          } catch (e) {
            debugPrint('Auto-sync failed for subscription "${sub.name}": $e');
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
    final links = await V2rayImportHelper.fetchSubscriptionLinks(cleanUrl);
    if (links.isEmpty) return 0;

    final subItem = await ref
        .read(subscriptionsListProvider.notifier)
        .upsertSubscription(
          name: name ?? '',
          url: cleanUrl,
          intervalHours: intervalHours,
        );

    final sourceTag = 'sub:${subItem.name}';
    final parsedModels = await V2rayImportHelper.parseLinksToConfigs(
      links: links,
      importedFrom: sourceTag,
    );
    if (parsedModels.isEmpty) return 0;

    await _replaceSubscriptionNodesAndPersist(
      sourceTag: sourceTag,
      newModels: parsedModels,
    );
    return parsedModels.length;
  }

  Future<int> refreshSubscription(SubscriptionItem sub) async {
    final links = await V2rayImportHelper.fetchSubscriptionLinks(sub.url);
    if (links.isEmpty) return 0;

    final sourceTag = 'sub:${sub.name}';
    final parsedModels = await V2rayImportHelper.parseLinksToConfigs(
      links: links,
      importedFrom: sourceTag,
    );
    if (parsedModels.isEmpty) return 0;

    await ref.read(subscriptionsListProvider.notifier).markUpdated(sub.id);
    await _replaceSubscriptionNodesAndPersist(
      sourceTag: sourceTag,
      newModels: parsedModels,
    );
    return parsedModels.length;
  }

  Future<void> removeSubscriptionAndNodes(SubscriptionItem sub) async {
    final sourceTag = 'sub:${sub.name}';
    await ref.read(subscriptionsListProvider.notifier).removeById(sub.id);
    final remaining =
        state.where((c) => c.importedFrom != sourceTag).toList();
    state = remaining;
    await _persistState(remaining);
  }

  Future<void> _replaceSubscriptionNodesAndPersist({
    required String sourceTag,
    required List<ConfigModel> newModels,
  }) async {
    // Keep nodes from other sources; replace nodes belonging to this subscription
    final retained = state.where((c) => c.importedFrom != sourceTag).toList();
    final existingByUri = <String, Config>{
      for (final c in retained) c.uri: c,
    };
    for (final model in newModels) {
      existingByUri[model.uri] = model;
    }
    final merged = existingByUri.values.toList();
    state = merged;
    await _persistState(merged);

    if (ref.read(currentConfigProvider) == null && merged.isNotEmpty) {
      await ref
          .read(currentConfigProvider.notifier)
          .setCurrentConfig(merged.first);
    }
  }

  Future<void> _mergeAndPersist(List<ConfigModel> newModels) async {
    final existingByUri = <String, Config>{
      for (final c in state) c.uri: c,
    };
    for (final model in newModels) {
      existingByUri[model.uri] = model;
    }
    final merged = existingByUri.values.toList();
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
    required String countryCode,
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

  Future<void> _persistState(List<Config> list) async {
    final maps =
        list.map((c) {
          final model = ConfigModel(
            configjson: c.configjson,
            importedFrom: c.importedFrom,
            remark: c.remark,
            port: c.port,
            address: c.address,
            uri: c.uri,
            dateAdded: c.dateAdded,
            id: c.id,
            isSelected: c.isSelected,
            country: c.country,
            serverIp: c.serverIp,
            ping: c.ping,
          );
          return model.toMap(model);
        }).toList();
    await _cacheHelper.cacheLocalConfigs(maps);
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
    this.subIntervalHours = 6,
    this.collapsedSubKeys = const <String>{},
  });

  final int selectedTab;
  final bool isImporting;
  final bool isPingingAll;
  final int subIntervalHours;
  final Set<String> collapsedSubKeys;

  NodesViewUiState copyWith({
    int? selectedTab,
    bool? isImporting,
    bool? isPingingAll,
    int? subIntervalHours,
    Set<String>? collapsedSubKeys,
  }) {
    return NodesViewUiState(
      selectedTab: selectedTab ?? this.selectedTab,
      isImporting: isImporting ?? this.isImporting,
      isPingingAll: isPingingAll ?? this.isPingingAll,
      subIntervalHours: subIntervalHours ?? this.subIntervalHours,
      collapsedSubKeys: collapsedSubKeys ?? this.collapsedSubKeys,
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
  void setSubIntervalHours(int hours) =>
      state = state.copyWith(subIntervalHours: hours);

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
