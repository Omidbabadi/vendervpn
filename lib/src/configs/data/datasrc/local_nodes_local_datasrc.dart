import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/subscription_item.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/app_log.dart';
import 'package:vendervpn/src/configs/data/datasrc/node_link_converter.dart';
import 'package:vendervpn/src/configs/data/models/subscription_item_model.dart';

/// The user's imported nodes and subscriptions, saved on the device.
abstract class LocalNodesLocalDatasrc {
  const LocalNodesLocalDatasrc();

  /// Saved nodes; entries whose link no longer parses are skipped.
  List<Config> loadNodes();

  Future<void> saveNodes(List<Config> nodes);

  List<SubscriptionItem> loadSubscriptions();

  Future<void> saveSubscriptions(List<SubscriptionItem> subscriptions);
}

class LocalNodesLocalDatasrcImpl implements LocalNodesLocalDatasrc {
  const LocalNodesLocalDatasrcImpl(this._cache);
  final CacheHelper _cache;

  @override
  List<Config> loadNodes() {
    final selectedId = _cache.id;
    final nodeCountries = _cache.nodeCountryMap;
    final loaded = <Config>[];

    for (final e in _cache.localConfigs) {
      if ((e['uri'] as String? ?? '').isEmpty) continue;
      try {
        loaded.add(
          NodeLinkConverter.configFromCacheMap(
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
    return loaded;
  }

  @override
  Future<void> saveNodes(List<Config> nodes) async {
    try {
      await _cache.cacheLocalConfigs(
        nodes.map(NodeLinkConverter.configToCacheMap).toList(),
      );
    } catch (e) {
      throw CacheException(message: 'Saving the nodes failed: $e');
    }
  }

  @override
  List<SubscriptionItem> loadSubscriptions() =>
      _cache.subscriptions
          .map(SubscriptionItemModel.fromMap)
          .where((s) => s.url.isNotEmpty)
          .toList();

  @override
  Future<void> saveSubscriptions(List<SubscriptionItem> subscriptions) async {
    try {
      await _cache.cacheSubscriptions(
        subscriptions
            .map((s) => SubscriptionItemModel.fromEntity(s).toMap())
            .toList(),
      );
    } catch (e) {
      throw CacheException(message: 'Saving the subscriptions failed: $e');
    }
  }
}
