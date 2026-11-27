import 'dart:convert';

import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/utils/app_log.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

/// Turns share links into nodes, and nodes into the map they are saved as.
/// Uses the V2Ray SDK, so it lives in the data layer.
class NodeLinkConverter {
  const NodeLinkConverter(this._cache);
  final CacheHelper _cache;

  /// Returns the full V2Ray JSON configuration string with both the default
  /// SOCKS5 inbound (`10807`) and a local HTTP proxy inbound (`10809`) so
  /// in-app `HttpClient` requests (which are excluded from the Android VPN
  /// interface via `addDisallowedApplication`) can route through the active
  /// V2Ray tunnel.
  static String buildFullConfigurationWithHttpInbound(V2RayURL parser) {
    final configMap = Map<String, dynamic>.from(parser.fullConfiguration);
    final rawInbounds = configMap['inbounds'];
    final inbounds =
        rawInbounds is List
            ? List<dynamic>.from(rawInbounds)
            : <dynamic>[parser.inbound];

    final hasHttpInbound = inbounds.any(
      (item) => item is Map && item['protocol'] == 'http',
    );
    if (!hasHttpInbound) {
      inbounds.add({
        'tag': 'in_http',
        'port': 10809,
        'protocol': 'http',
        'listen': '127.0.0.1',
        'settings': {'userLevel': 8},
        'sniffing': {'enabled': false},
      });
    }
    configMap['inbounds'] = inbounds;
    final cleaned = parser.removeNulls(configMap);
    return const JsonEncoder.withIndent('  ').convert(cleaned);
  }

  /// Rebuilds a [Config] from a node map saved by [configToCacheMap].
  /// Throws if the saved link can no longer be parsed.
  static Config configFromCacheMap(
    Map<String, dynamic> e, {
    required String? selectedId,
    required Map<String, String> nodeCountries,
    required String defaultImportedFrom,
    String? defaultDateAdded,
    bool readServerIp = false,
  }) {
    final uri = (e['uri'] as String? ?? '').trim();
    if (uri.isEmpty) throw const FormatException('Saved node has no link');
    final parser = V2ray.parseFromURL(uri);
    final fullJson = buildFullConfigurationWithHttpInbound(parser);
    final id = e['id'] as String? ?? 'local_${uri.hashCode.abs()}';
    final remark = e['remark'] as String? ?? parser.remark;
    final rawServerIp = e['serverIp'] as String?;
    return Config(
      configjson: fullJson,
      importedFrom: e['importedFrom'] as String? ?? defaultImportedFrom,
      remark: remark,
      port: int.tryParse((e['port'] ?? '0').toString()) ?? parser.port,
      address: e['address'] as String? ?? parser.address,
      uri: uri,
      dateAdded:
          e['dateAdded'] as String? ??
          defaultDateAdded ??
          DateTime.now().toIso8601String(),
      id: id,
      isSelected: id == selectedId,
      // Verified country, else the remark's flag emoji, else unknown.
      country:
          nodeCountries[uri] ?? V2rayImportHelper.countryFromRemarkFlag(remark),
      serverIp:
          readServerIp &&
                  rawServerIp != null &&
                  rawServerIp != 'N/A' &&
                  rawServerIp != parser.address
              ? rawServerIp
              : null,
      ping: int.tryParse((e['ping'] ?? '-1').toString()) ?? -1,
    );
  }

  /// The map a node is saved as (see [configFromCacheMap]).
  static Map<String, String> configToCacheMap(Config c) {
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
  }

  /// Parses raw V2Ray links into [ConfigModel]s, skipping links that don't
  /// parse. No per-node network lookups here: the IP lookup runs before and
  /// after the tunnel comes up.
  Future<List<ConfigModel>> parseLinksToConfigs({
    required List<String> links,
    required String importedFrom,
    String? forcedIdPrefix,
    String? createdAt,
    String? idScope,
  }) async {
    final selectedId = _cache.id;
    final cachedNodeCountries = _cache.nodeCountryMap;
    final List<ConfigModel> parsed = [];

    for (var i = 0; i < links.length; i++) {
      final rawLink = links[i].trim();
      if (!V2rayImportHelper.isSupportedLink(rawLink)) continue;

      try {
        final V2RayURL parser = V2ray.parseFromURL(rawLink);
        final fullJson = buildFullConfigurationWithHttpInbound(parser);
        final id =
            forcedIdPrefix != null
                ? (links.length == 1 ? forcedIdPrefix : '${forcedIdPrefix}_$i')
                : idScope != null
                // Scope the id to its source (e.g. a subscription) so the same
                // link in two subscriptions yields two distinct nodes.
                ? 'local_${'$idScope|$rawLink'.hashCode.abs()}'
                : 'local_${rawLink.hashCode.abs()}';
        final remark =
            parser.remark.trim().isNotEmpty
                ? parser.remark.trim()
                : '${V2rayImportHelper.protocolOf(rawLink)} (${parser.address})';

        final cleanAddr = parser.address.trim();
        // A country verified by a tunnel IP lookup wins; otherwise use the
        // flag the provider put in the remark; otherwise unknown (placeholder).
        final countryCode =
            cachedNodeCountries[rawLink] ??
            V2rayImportHelper.countryFromRemarkFlag(remark);

        parsed.add(
          ConfigModel(
            configjson: fullJson,
            importedFrom: importedFrom,
            remark: remark,
            port: parser.port,
            address: cleanAddr,
            uri: rawLink,
            dateAdded: createdAt ?? DateTime.now().toIso8601String(),
            id: id,
            country: countryCode,
            serverIp: null,
            isSelected: selectedId == id,
            ping: -1,
          ),
        );
      } catch (e) {
        appLog('Skipping invalid V2Ray link: $e');
      }
    }

    return parsed;
  }
}
