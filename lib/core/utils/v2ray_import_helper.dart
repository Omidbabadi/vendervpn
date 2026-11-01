import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/configs/data/models/config_model.dart';

class SubscriptionUserInfo {
  const SubscriptionUserInfo({
    required this.upload,
    required this.download,
    required this.total,
    required this.expire,
    this.announce,
    this.hasTrafficData = true,
  });

  final int upload;
  final int download;
  final int total;
  final int expire;
  final String? announce;
  final bool hasTrafficData;

  int get used => upload + download;
  bool get isUnlimitedTraffic => total <= 0;
  bool get isUnlimitedExpire => expire <= 0;
  bool get hasAnnounce => announce != null && announce!.trim().isNotEmpty;

  double? get usageRatio {
    if (total <= 0) return null;
    return (used / total).clamp(0.0, 1.0);
  }

  DateTime? get expireDate {
    if (expire <= 0) return null;
    final ms = expire > 100000000000 ? expire : expire * 1000;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get isExpired {
    final dt = expireDate;
    if (dt == null) return false;
    return DateTime.now().isAfter(dt);
  }

  SubscriptionUserInfo copyWith({
    int? upload,
    int? download,
    int? total,
    int? expire,
    String? announce,
    bool? hasTrafficData,
  }) {
    return SubscriptionUserInfo(
      upload: upload ?? this.upload,
      download: download ?? this.download,
      total: total ?? this.total,
      expire: expire ?? this.expire,
      announce: announce ?? this.announce,
      hasTrafficData: hasTrafficData ?? this.hasTrafficData,
    );
  }

  Map<String, dynamic> toMap() => {
    'upload': upload,
    'download': download,
    'total': total,
    'expire': expire,
    'hasTrafficData': hasTrafficData,
    if (announce != null && announce!.trim().isNotEmpty) 'announce': announce,
  };

  factory SubscriptionUserInfo.fromMap(Map<String, dynamic> map) {
    final rawAnnounce = (map['announce'] as String?)?.trim();
    return SubscriptionUserInfo(
      upload: int.tryParse((map['upload'] ?? '0').toString()) ?? 0,
      download: int.tryParse((map['download'] ?? '0').toString()) ?? 0,
      total: int.tryParse((map['total'] ?? '0').toString()) ?? 0,
      expire: int.tryParse((map['expire'] ?? '0').toString()) ?? 0,
      hasTrafficData: map['hasTrafficData'] as bool? ?? true,
      announce:
          (rawAnnounce != null && rawAnnounce.isNotEmpty) ? rawAnnounce : null,
    );
  }

  /// Parses an `Announce` header or comment value such as:
  /// `base64:2YTYt9mB2Kcg...` or plain text.
  static String? tryParseAnnounce(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;
    var cleaned = rawValue.trim();

    if (cleaned.toLowerCase().startsWith('announce:')) {
      cleaned = cleaned.substring('announce:'.length).trim();
    } else if (cleaned.toLowerCase().startsWith('#announce:')) {
      cleaned = cleaned.substring('#announce:'.length).trim();
    }

    if (cleaned.toLowerCase().startsWith('base64:')) {
      final b64Payload = cleaned.substring('base64:'.length).trim();
      final decoded = V2rayImportHelper.tryDecodeBase64String(b64Payload);
      if (decoded != null && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    }

    return cleaned.isNotEmpty ? cleaned : null;
  }

  /// Parses a `Subscription-Userinfo` header string such as:
  /// `upload=65973995349; download=832599811771; total=0; expire=0`
  static SubscriptionUserInfo? tryParse(
    String? rawHeader, {
    String? rawAnnounce,
  }) {
    final parsedAnnounce = tryParseAnnounce(rawAnnounce);

    int? upload;
    int? download;
    int? total;
    int? expire;

    if (rawHeader != null && rawHeader.trim().isNotEmpty) {
      var cleaned = rawHeader.trim();
      final colonIdx = cleaned.indexOf(':');
      if (colonIdx != -1 &&
          cleaned.substring(0, colonIdx).toLowerCase().contains('userinfo')) {
        cleaned = cleaned.substring(colonIdx + 1).trim();
      }

      final parts = cleaned.split(RegExp(r'[;,]'));
      for (final part in parts) {
        final kv = part.split('=');
        if (kv.length != 2) continue;
        final key = kv[0].trim().toLowerCase();
        final valStr = kv[1].trim();
        final val = int.tryParse(valStr) ?? double.tryParse(valStr)?.round();
        if (val == null) continue;
        switch (key) {
          case 'upload':
            upload = val;
          case 'download':
            download = val;
          case 'total':
            total = val;
          case 'expire':
            expire = val;
        }
      }
    }

    final hasTraffic =
        upload != null || download != null || total != null || expire != null;

    if (!hasTraffic && parsedAnnounce == null) {
      return null;
    }

    return SubscriptionUserInfo(
      upload: upload ?? 0,
      download: download ?? 0,
      total: total ?? 0,
      expire: expire ?? 0,
      announce: parsedAnnounce,
      hasTrafficData: hasTraffic,
    );
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const kb = 1024.0;
    const mb = kb * 1024.0;
    const gb = mb * 1024.0;
    const tb = gb * 1024.0;

    if (bytes >= tb) {
      return '${(bytes / tb).toStringAsFixed(2)} TB';
    } else if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }
}

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

  /// Extracts `Subscription-Userinfo` and `Announce` from HTTP response headers (case-insensitive).
  static SubscriptionUserInfo? _extractUserInfoFromHeaders(
    HttpHeaders headers,
  ) {
    String? rawUserInfo = headers.value('subscription-userinfo');
    String? rawAnnounce =
        headers.value('announce') ?? headers.value('x-announce');

    headers.forEach((name, values) {
      if (values.isEmpty) return;
      final lower = name.toLowerCase();
      if (rawUserInfo == null && lower == 'subscription-userinfo') {
        rawUserInfo = values.join('; ');
      } else if (rawAnnounce == null &&
          (lower == 'announce' || lower == 'x-announce')) {
        rawAnnounce = values.join('\n');
      }
    });

    return SubscriptionUserInfo.tryParse(
      rawUserInfo,
      rawAnnounce: rawAnnounce,
    );
  }

  /// Extracts an `#announce:` comment line from raw or base64-decoded subscription payload.
  static String? _extractAnnounceFromBody(String rawBody) {
    final trimmed = rawBody.trim();
    if (trimmed.isEmpty) return null;

    String? scanLines(String text) {
      for (final line in text.split(RegExp(r'[\r\n]+'))) {
        final l = line.trim();
        if (l.toLowerCase().startsWith('#announce:') ||
            l.toLowerCase().startsWith('announce:')) {
          return SubscriptionUserInfo.tryParseAnnounce(l);
        }
      }
      return null;
    }

    final direct = scanLines(trimmed);
    if (direct != null) return direct;

    final decoded = _tryDecodeBase64(trimmed);
    if (decoded != null) {
      return scanLines(decoded);
    }
    return null;
  }

  /// Sends a lightweight `HEAD` request (like `curl -sI`) to retrieve
  /// `Subscription-Userinfo` and `Announce` headers from [subUrl].
  static Future<SubscriptionUserInfo?> fetchSubscriptionUserInfo(
    String subUrl,
  ) async {
    final uri = Uri.tryParse(subUrl.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return null;
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.headUrl(uri);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'VenderVPN/1.0 (v2rayNG; clash.meta; Flutter)',
      );
      final response = await request.close();
      await response.drain<void>();
      final info = _extractUserInfoFromHeaders(response.headers);
      if (info != null) return info;

      // Fallback to GET headers if the server does not return headers on HEAD
      final getReq = await client.getUrl(uri);
      getReq.headers.set(
        HttpHeaders.userAgentHeader,
        'VenderVPN/1.0 (v2rayNG; clash.meta; Flutter)',
      );
      final getRes = await getReq.close();
      await getRes.drain<void>();
      return _extractUserInfoFromHeaders(getRes.headers);
    } catch (e) {
      debugPrint('Failed to fetch subscription userinfo: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Fetches a V2Ray subscription URL, extracting all V2Ray links as well as
  /// `Subscription-Userinfo` and `Announce` headers/comments.
  static Future<({List<String> links, SubscriptionUserInfo? userInfo})>
  fetchSubscription(String subUrl) async {
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
        'VenderVPN/1.0 (v2rayNG; clash.meta; Flutter)',
      );
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Subscription returned HTTP ${response.statusCode}');
      }
      var userInfo = _extractUserInfoFromHeaders(response.headers);
      final body = await response.transform(utf8.decoder).join();
      final links = extractLinksFromPayload(body);

      // If GET did not include `Subscription-Userinfo` or `Announce`, try HEAD (`curl -sI`)
      if (userInfo == null || !userInfo.hasAnnounce) {
        try {
          final headReq = await client.headUrl(uri);
          headReq.headers.set(
            HttpHeaders.userAgentHeader,
            'VenderVPN/1.0 (v2rayNG; clash.meta; Flutter)',
          );
          final headRes = await headReq.close();
          await headRes.drain<void>();
          final headInfo = _extractUserInfoFromHeaders(headRes.headers);
          if (userInfo == null) {
            userInfo = headInfo;
          } else if (headInfo != null) {
            userInfo = userInfo.copyWith(
              announce: userInfo.announce ?? headInfo.announce,
            );
          }
        } catch (_) {}
      }

      // Also check `#announce:` inside the subscription body if header wasn't present
      if (userInfo == null || !userInfo.hasAnnounce) {
        final bodyAnnounce = _extractAnnounceFromBody(body);
        if (bodyAnnounce != null) {
          userInfo =
              userInfo != null
                  ? userInfo.copyWith(announce: bodyAnnounce)
                  : SubscriptionUserInfo(
                    upload: 0,
                    download: 0,
                    total: 0,
                    expire: 0,
                    announce: bodyAnnounce,
                    hasTrafficData: false,
                  );
        }
      }

      return (links: links, userInfo: userInfo);
    } finally {
      client.close();
    }
  }

  /// Fetches a V2Ray subscription URL and extracts all V2Ray links.
  static Future<List<String>> fetchSubscriptionLinks(String subUrl) async {
    final result = await fetchSubscription(subUrl);
    return result.links;
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

  static String? tryDecodeBase64String(String input) => _tryDecodeBase64(input);

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
