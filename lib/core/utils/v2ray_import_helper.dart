import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

class V2rayImportHelper {
  const V2rayImportHelper._();

  static const List<String> _supportedSchemes = [
    'vmess://',
    'vless://',
    'trojan://',
    'ss://',
    'socks://',
    'hysteria://',
    'hysteria2://',
    'hy://',
    'hy2://',
  ];

  static bool isSupportedLink(String line) {
    final trimmed = line.trim().toLowerCase();
    return _supportedSchemes.any(trimmed.startsWith);
  }

  static String protocolOf(String uri) {
    final idx = uri.indexOf('://');
    if (idx <= 0) return 'V2RAY';
    final scheme = uri.substring(0, idx).toUpperCase();
    return switch (scheme) {
      'HY' || 'HY2' || 'HYSTERIA2' => 'HY2',
      'HYSTERIA' => 'HYSTERIA',
      _ => scheme,
    };
  }

  /// Extracts all valid V2Ray links from raw text (plain links or base64 payload).
  static List<String> extractLinksFromPayload(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return [];

    final directLines =
        trimmed
            .split(RegExp(r'[\r\n]+'))
            .map((e) => e.trim())
            .where(isSupportedLink)
            .toList();
    if (directLines.isNotEmpty) {
      return directLines;
    }

    final decoded = _tryDecodeBase64(trimmed);
    if (decoded != null && decoded.isNotEmpty) {
      final decodedLines =
          decoded
              .split(RegExp(r'[\r\n]+'))
              .map((e) => e.trim())
              .where(isSupportedLink)
              .toList();
      if (decodedLines.isNotEmpty) {
        return decodedLines;
      }
    }

    return [];
  }

  /// Fetches a V2Ray subscription URL and extracts all V2Ray links.
  static Future<List<String>> fetchSubscriptionLinks(String subUrl) async {
    final uri = Uri.tryParse(subUrl.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      throw const FormatException('Invalid subscription URL');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'VenderVPN/1.0 (v2rayNG; Flutter)',
      );
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Subscription returned HTTP ${response.statusCode}');
      }
      final body = await response.transform(utf8.decoder).join();
      return extractLinksFromPayload(body);
    } finally {
      client.close();
    }
  }

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

  /// Parses a list of raw V2Ray links into [ConfigModel] instances without
  /// blocking on per-node network IP lookups (IP lookup is performed before
  /// and after TUN activation).
  static Future<List<ConfigModel>> parseLinksToConfigs({
    required List<String> links,
    required String importedFrom,
    String? forcedIdPrefix,
    String? createdAt,
  }) async {
    final cacheHelper = sl<CacheHelper>();
    final selectedId = cacheHelper.id;
    final cachedIpCountries = cacheHelper.ipCountryMap;
    final List<ConfigModel> parsed = [];

    for (var i = 0; i < links.length; i++) {
      final rawLink = links[i].trim();
      if (!isSupportedLink(rawLink)) continue;

      try {
        final V2RayURL parser = V2ray.parseFromURL(rawLink);
        final fullJson = buildFullConfigurationWithHttpInbound(parser);
        final id =
            forcedIdPrefix != null
                ? (links.length == 1 ? forcedIdPrefix : '${forcedIdPrefix}_$i')
                : 'local_${rawLink.hashCode.abs()}';
        final remark =
            parser.remark.trim().isNotEmpty
                ? parser.remark.trim()
                : '${protocolOf(rawLink)} (${parser.address})';

        final cleanAddr = parser.address.trim();
        final countryCode =
            cachedIpCountries[cleanAddr] ?? _inferCountryFromRemark(remark);

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
        debugPrint('Skipping invalid V2Ray link: $e');
      }
    }

    return parsed;
  }

  static String? _inferCountryFromRemark(String remark) {
    final runes = remark.runes.toList();
    for (var i = 0; i < runes.length - 1; i++) {
      final first = runes[i];
      final second = runes[i + 1];
      if (first >= 0x1F1E6 &&
          first <= 0x1F1FF &&
          second >= 0x1F1E6 &&
          second <= 0x1F1FF) {
        final c1 = String.fromCharCode(first - 0x1F1E6 + 65);
        final c2 = String.fromCharCode(second - 0x1F1E6 + 65);
        return '$c1$c2';
      }
    }

    final upper = remark.toUpperCase();
    const commonCodes = {
      'GERMANY': 'DE',
      'NETHERLANDS': 'NL',
      'FINLAND': 'FI',
      'FRANCE': 'FR',
      'UNITED STATES': 'US',
      'USA': 'US',
      'UK': 'GB',
      'UNITED KINGDOM': 'GB',
      'TURKEY': 'TR',
      'SINGAPORE': 'SG',
      'JAPAN': 'JP',
      'CANADA': 'CA',
      'SWEDEN': 'SE',
      'SWITZERLAND': 'CH',
      'POLAND': 'PL',
      'AUSTRIA': 'AT',
    };
    for (final entry in commonCodes.entries) {
      if (upper.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static String? _tryDecodeBase64(String input) {
    try {
      var normalized = input.replaceAll(RegExp(r'\s+'), '');
      normalized = normalized.replaceAll('-', '+').replaceAll('_', '/');
      final mod = normalized.length % 4;
      if (mod > 0) {
        normalized += '=' * (4 - mod);
      }
      return utf8.decode(base64Decode(normalized), allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
}
