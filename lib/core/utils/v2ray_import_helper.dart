import 'dart:convert';

import 'package:vendervpn/core/utils/app_log.dart';

/// Pure parsing for V2Ray share links and subscription payloads. Network,
/// SDK and storage code lives in the configs data layer.
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

  /// Extracts `{method, password, host, port, remark, normalizedUri}` from any
  /// SIP002 or legacy `ss://` link, preserving Shadowsocks-2022 Base64 PSKs
  /// and multi-user identity keys (`psk1:psk2`).
  static ({String method, String password, String normalizedUri})?
  parseShadowsocksCredentials(String rawUri) {
    final trimmed = rawUri.trim();
    if (!trimmed.toLowerCase().startsWith('ss://')) return null;

    try {
      var body = trimmed.substring(5).trim(); // strip 'ss://'
      String remark = '';

      final hashIdx = body.indexOf('#');
      if (hashIdx != -1) {
        remark = body.substring(hashIdx); // keep '#...'
        body = body.substring(0, hashIdx);
      }

      // Strip query parameters (?outline=1, ?plugin=...) and trailing slash
      final queryIdx = body.indexOf('?');
      if (queryIdx != -1) {
        body = body.substring(0, queryIdx);
      }
      if (body.endsWith('/')) {
        body = body.substring(0, body.length - 1);
      }

      String userInfo;
      String hostPort;

      if (body.contains('@')) {
        // SIP002 format: ss://userinfo@host:port
        final atIdx = body.lastIndexOf('@');
        var rawUser = body.substring(0, atIdx).trim();
        hostPort = body.substring(atIdx + 1).trim();

        // 1. If percent-encoded (e.g. %3A, %2B, %2F, %3D), decode using
        // Uri.decodeFull (NOT decodeQueryComponent, which turns '+' into space!)
        if (rawUser.contains('%')) {
          rawUser = Uri.decodeFull(rawUser);
        }

        // 2. If it doesn't contain ':', it is Base64-encoded userinfo
        if (!rawUser.contains(':')) {
          final decodedUser = _tryDecodeBase64(rawUser);
          if (decodedUser != null && decodedUser.contains(':')) {
            userInfo = decodedUser.trim();
          } else {
            return null;
          }
        } else {
          userInfo = rawUser;
        }
      } else {
        // Legacy format: ss://BASE64(method:password@host:port)
        final rawBody = body.contains('%') ? Uri.decodeFull(body) : body;
        final decoded = _tryDecodeBase64(rawBody);
        if (decoded == null || !decoded.contains('@')) return null;
        final clean = decoded.trim();
        final atIdx = clean.lastIndexOf('@');
        userInfo = clean.substring(0, atIdx).trim();
        hostPort = clean.substring(atIdx + 1).trim();
      }

      final firstColon = userInfo.indexOf(':');
      if (firstColon <= 0) return null;

      final method = userInfo.substring(0, firstColon).trim();
      // Keep everything after the FIRST ':' intact so SS2022 EIH keys
      // (server_psk:user_psk) and Base64 padding are never truncated!
      var password = userInfo.substring(firstColon + 1).trim();

      // If the password itself was still percent-encoded inside Base64
      if (password.contains('%')) {
        password = Uri.decodeFull(password);
      }

      // If this is a Shadowsocks 2022 cipher, ensure each Base64 key segment
      // uses standard Base64 ('+', '/', and '=' padding) as required by Xray-core.
      if (method.startsWith('2022-')) {
        password = password
            .split(':')
            .map((segment) {
              var s = segment.trim().replaceAll('-', '+').replaceAll('_', '/');
              final mod = s.length % 4;
              if (mod > 0) s += '=' * (4 - mod);
              return s;
            })
            .join(':');
      }

      final cleanUserInfo = '$method:$password';
      final stdBase64User = base64Encode(utf8.encode(cleanUserInfo));
      final normalizedUri = 'ss://$stdBase64User@$hostPort$remark';

      return (method: method, password: password, normalizedUri: normalizedUri);
    } catch (e) {
      appLog('Failed to parse ss:// credentials: $e');
      return null;
    }
  }

  /// Country code from the first flag emoji in a remark (e.g. "🇩🇪 Fast" →
  /// "DE"), or null. Only explicit flag emoji count: matching country names
  /// in free text is too error-prone ("UK" would match "UKRAINE").
  static String? countryFromRemarkFlag(String? remark) {
    if (remark == null || remark.isEmpty) return null;
    bool isRegional(int r) => r >= 0x1F1E6 && r <= 0x1F1FF;
    final runes = remark.runes.toList();
    for (var i = 0; i < runes.length - 1; i++) {
      if (isRegional(runes[i]) && isRegional(runes[i + 1])) {
        return String.fromCharCodes([
          runes[i] - 0x1F1E6 + 65,
          runes[i + 1] - 0x1F1E6 + 65,
        ]);
      }
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
