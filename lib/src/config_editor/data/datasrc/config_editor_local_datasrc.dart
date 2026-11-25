import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

/// Stores edited local nodes on the device.
abstract class ConfigEditorLocalDatasrc {
  const ConfigEditorLocalDatasrc();

  /// Replaces the stored local node that has [node]'s id.
  Future<void> saveLocalNode(ConfigModel node);

  /// Country confirmed by a tunnel IP lookup for [nodeUri], if any.
  String? verifiedCountry(String nodeUri);

  Future<void> cacheVerifiedCountry(String nodeUri, String countryCode);
}

class ConfigEditorLocalDatasrcImpl implements ConfigEditorLocalDatasrc {
  const ConfigEditorLocalDatasrcImpl(this._cacheHelper);
  final CacheHelper _cacheHelper;

  @override
  Future<void> saveLocalNode(ConfigModel node) async {
    try {
      final stored = _cacheHelper.localConfigs;
      final index = stored.indexWhere((e) => _idOf(e) == node.id);
      if (index == -1) {
        throw const CacheException(message: 'This node no longer exists.');
      }
      final maps = <Map<String, String>>[
        for (var i = 0; i < stored.length; i++)
          if (i == index)
            // Keep any stored keys the model doesn't know about.
            {..._stringify(stored[i]), ...node.toMap(node)}
          else
            _stringify(stored[i]),
      ];
      await _cacheHelper.cacheLocalConfigs(maps);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Saving the node failed: $e');
    }
  }

  @override
  String? verifiedCountry(String nodeUri) =>
      _cacheHelper.nodeCountryMap[nodeUri.trim()];

  @override
  Future<void> cacheVerifiedCountry(String nodeUri, String countryCode) async {
    try {
      await _cacheHelper.cacheNodeCountry(nodeUri.trim(), countryCode);
    } catch (e) {
      throw CacheException(message: 'Saving the node country failed: $e');
    }
  }

  /// Same id fallback the local node list uses when loading.
  static String _idOf(Map<String, dynamic> entry) =>
      entry['id'] as String? ??
      'local_${(entry['uri'] as String? ?? '').hashCode.abs()}';

  static Map<String, String> _stringify(Map<String, dynamic> entry) => {
    for (final e in entry.entries)
      if (e.value != null) e.key: e.value.toString(),
  };
}
