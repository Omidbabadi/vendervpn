import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/common/entities/subscription_user_info.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/app_log.dart';
import 'package:vendervpn/src/configs/domain/usecases/extract_node_links.dart';
import 'package:vendervpn/src/configs/domain/usecases/fetch_subscription.dart';
import 'package:vendervpn/src/configs/domain/usecases/fetch_subscription_info.dart';
import 'package:vendervpn/src/configs/domain/usecases/get_local_nodes.dart';
import 'package:vendervpn/src/configs/domain/usecases/get_subscriptions.dart';
import 'package:vendervpn/src/configs/domain/usecases/parse_node_links.dart';
import 'package:vendervpn/src/configs/domain/usecases/save_local_nodes.dart';
import 'package:vendervpn/src/configs/domain/usecases/save_subscriptions.dart';

/// An import step failed; [toString] is the message shown to the user.
class NodeImportException implements Exception {
  const NodeImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

final subscriptionsListProvider =
    NotifierProvider<SubscriptionsList, List<SubscriptionItem>>(
      SubscriptionsList.new,
    );

class SubscriptionsList extends Notifier<List<SubscriptionItem>> {
  final _getSubscriptions = sl<GetSubscriptions>();
  final _saveSubscriptions = sl<SaveSubscriptions>();

  @override
  List<SubscriptionItem> build() => _getSubscriptions();

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
    await _persist(const []);
  }

  Future<void> _persist(List<SubscriptionItem> items) async {
    final result = await _saveSubscriptions(items);
    result.fold(
      (failure) => appLog('Saving subscriptions failed: ${failure.message}'),
      (_) {},
    );
  }
}

final localConfigsListProvider =
    NotifierProvider<LocalConfigsList, List<Config>>(LocalConfigsList.new);

class LocalConfigsList extends Notifier<List<Config>> {
  final _getLocalNodes = sl<GetLocalNodes>();
  final _saveLocalNodes = sl<SaveLocalNodes>();
  final _parseNodeLinks = sl<ParseNodeLinks>();
  final _extractNodeLinks = sl<ExtractNodeLinks>();
  final _fetchSubscription = sl<FetchSubscription>();
  final _fetchSubscriptionInfo = sl<FetchSubscriptionInfo>();
  Timer? _autoSyncTimer;
  bool _isCheckingAutoSync = false;

  @override
  List<Config> build() {
    final loaded = _getLocalNodes();
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
          final result = await _fetchSubscriptionInfo(sub.url);
          await result.fold(
            (failure) async => appLog(
              'Userinfo fetch failed for subscription "${sub.name}": '
              '${failure.message}',
            ),
            (info) async {
              if (info != null) await subsNotifier.updateUserInfo(sub.id, info);
            },
          );
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

    final links = _extractNodeLinks(trimmed);
    if (links.isEmpty) return 0;

    final parsedModels = await _parse(links: links, importedFrom: source);
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
    final fetched = await _fetch(cleanUrl);
    if (fetched.links.isEmpty) return 0;

    final subItem = await subsNotifier.upsertSubscription(
      name: name ?? '',
      url: cleanUrl,
      intervalHours: intervalHours,
      userInfo: fetched.userInfo,
    );

    final sourceTag = 'sub:${subItem.name}';
    final parsedModels = await _parse(
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
    final fetched = await _fetch(sub.url);
    if (fetched.links.isEmpty) return 0;

    final sourceTag = 'sub:${sub.name}';
    final parsedModels = await _parse(
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

  /// Throws [NodeImportException] when the download fails.
  Future<SubscriptionFetch> _fetch(String url) async {
    final result = await _fetchSubscription(url);
    return result.fold(_throw, (fetched) => fetched);
  }

  /// Throws [NodeImportException] when the links can't be read.
  Future<List<Config>> _parse({
    required List<String> links,
    required String importedFrom,
    String? idScope,
  }) async {
    final result = await _parseNodeLinks(
      ParseNodeLinksParams(
        links: links,
        importedFrom: importedFrom,
        idScope: idScope,
      ),
    );
    return result.fold(_throw, (nodes) => nodes);
  }

  static Never _throw(Failure failure) =>
      throw NodeImportException(failure.message);

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
    await _persistState(const []);
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
    final result = await _saveLocalNodes(list);
    result.fold(
      (failure) => appLog('Saving local nodes failed: ${failure.message}'),
      (_) {},
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
