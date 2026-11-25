import 'dart:convert';

import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';

/// Converts between share links (`vless://`, `vmess://`, ...) and
/// [EditableNode]. Link parameters the editor doesn't show are kept in
/// [EditableNode.extras] and written back unchanged.
class ShareLinkCodec {
  const ShareLinkCodec._();

  static const _streamKeys = {
    'type',
    'headerType',
    'host',
    'path',
    'serviceName',
    'mode',
    'security',
    'sni',
    'fp',
    'alpn',
    'pbk',
    'sid',
    'spx',
    'flow',
    'encryption',
  };

  static const _vmessKeys = {
    'v',
    'ps',
    'add',
    'port',
    'id',
    'aid',
    'scy',
    'net',
    'type',
    'host',
    'path',
    'tls',
    'sni',
    'alpn',
    'fp',
  };

  static const _hysteriaKeys = {'security', 'sni', 'fp'};

  // ───────────────────────────── Decoding ─────────────────────────────

  /// Reads [link] into editable form.
  ///
  /// Throws [ConfigEditException] if the link can't be read.
  static EditableNode decode(String link) {
    final raw = link.trim();
    final idx = raw.indexOf('://');
    if (idx <= 0) {
      throw const ConfigEditException(message: 'This is not a share link.');
    }
    final scheme = raw.substring(0, idx).toLowerCase();
    try {
      return switch (scheme) {
        'vless' => _decodeUrlStyle(raw, NodeProtocol.vless),
        'trojan' => _decodeUrlStyle(raw, NodeProtocol.trojan),
        'vmess' => _decodeVmess(raw.substring(idx + 3)),
        'ss' => _decodeShadowsocks(raw),
        'socks' => _decodeSocks(raw),
        'hysteria' || 'hy' => _decodeHysteria(raw, NodeProtocol.hysteria),
        'hysteria2' || 'hy2' => _decodeHysteria(raw, NodeProtocol.hysteria2),
        _ =>
          throw ConfigEditException(
            message: 'Editing "$scheme" links is not supported.',
          ),
      };
    } on ConfigEditException {
      rethrow;
    } catch (e) {
      throw ConfigEditException(message: 'This node link could not be read: $e');
    }
  }

  static EditableNode _decodeUrlStyle(String raw, NodeProtocol protocol) {
    final uri = _parseUri(raw);
    final credential = _decodeComponent(uri.userInfo);
    final base = EditableNode(
      protocol: protocol,
      remark: _remarkOf(uri.fragment),
      address: uri.host,
      port: _portOf(uri),
      userId: protocol == NodeProtocol.vless ? credential : '',
      secret: protocol == NodeProtocol.trojan ? credential : '',
    );
    return _withStreamParams(
      base,
      uri.queryParameters,
      // Trojan links without a `security` parameter are TLS.
      defaultSecurity: protocol == NodeProtocol.trojan ? 'tls' : 'none',
    );
  }

  static EditableNode _decodeVmess(String body) {
    final decoded = V2rayImportHelper.tryDecodeBase64String(body.trim());
    if (decoded == null) {
      throw const ConfigEditException(message: 'The VMess link is not valid.');
    }
    final json = jsonDecode(decoded);
    if (json is! Map) {
      throw const ConfigEditException(message: 'The VMess link is not valid.');
    }
    final map = Map<String, dynamic>.from(json);
    String s(String key) => (map[key] ?? '').toString().trim();

    final network = _network(s('net'));
    // gRPC and XHTTP carry their mode in `type`; gRPC its service in `path`.
    final usesMode = network == 'grpc' || network == 'xhttp';
    final type = s('type');
    return EditableNode(
      protocol: NodeProtocol.vmess,
      remark: s('ps'),
      address: s('add'),
      port: int.tryParse(s('port')) ?? 443,
      userId: s('id'),
      alterId: int.tryParse(s('aid')) ?? 0,
      cipher: s('scy').isEmpty ? 'auto' : s('scy'),
      network: network,
      headerType: usesMode || type.isEmpty ? 'none' : type,
      transportMode: usesMode && type != 'none' ? type : '',
      host: s('host'),
      path: network == 'grpc' ? '' : s('path'),
      serviceName: network == 'grpc' ? s('path') : '',
      security: s('tls').toLowerCase() == 'tls' ? 'tls' : 'none',
      sni: s('sni'),
      fingerprint: s('fp'),
      alpn: s('alpn'),
      extras: {
        for (final e in map.entries)
          if (!_vmessKeys.contains(e.key) && e.value != null)
            e.key: e.value.toString(),
      },
    );
  }

  static EditableNode _decodeShadowsocks(String raw) {
    final creds = V2rayImportHelper.parseShadowsocksCredentials(raw);
    if (creds == null) {
      throw const ConfigEditException(
        message: 'The Shadowsocks link is not valid.',
      );
    }

    // Host and port come from the normalized link (it handles the legacy
    // all-base64 format); remark and parameters from the original.
    final normalized = creds.normalizedUri.split('#').first;
    final hostPort = normalized.substring(normalized.lastIndexOf('@') + 1);
    final server = _parseUri('ss://x@$hostPort');

    final hashIdx = raw.indexOf('#');
    final beforeHash = hashIdx == -1 ? raw : raw.substring(0, hashIdx);
    final queryIdx = beforeHash.indexOf('?');
    var query = const <String, String>{};
    if (queryIdx != -1) {
      try {
        query = Uri.splitQueryString(beforeHash.substring(queryIdx + 1));
      } catch (_) {}
    }

    final base = EditableNode(
      protocol: NodeProtocol.shadowsocks,
      remark: hashIdx == -1 ? '' : _remarkOf(raw.substring(hashIdx + 1)),
      address: server.host,
      port: _portOf(server),
      method: creds.method,
      secret: creds.password,
    );
    return _withStreamParams(base, query, defaultSecurity: 'none');
  }

  static EditableNode _decodeSocks(String raw) {
    final uri = _parseUri(raw);
    var user = '';
    var pass = '';
    if (uri.userInfo.isNotEmpty) {
      final info = _decodeComponent(uri.userInfo);
      // Usually base64("user:pass"); some apps write it in plain text.
      final plain =
          info.contains(':')
              ? info
              : (V2rayImportHelper.tryDecodeBase64String(info) ?? info);
      final colon = plain.indexOf(':');
      if (colon >= 0) {
        user = plain.substring(0, colon);
        pass = plain.substring(colon + 1);
      } else {
        user = plain;
      }
    }
    return EditableNode(
      protocol: NodeProtocol.socks,
      remark: _remarkOf(uri.fragment),
      address: uri.host,
      port: _portOf(uri),
      username: user,
      secret: pass,
    );
  }

  static EditableNode _decodeHysteria(String raw, NodeProtocol protocol) {
    final uri = _parseUri(raw);
    final q = uri.queryParameters;
    final security = (q['security'] ?? 'tls').trim().toLowerCase();
    return EditableNode(
      protocol: protocol,
      remark: _remarkOf(uri.fragment),
      address: uri.host,
      port: _portOf(uri),
      secret: _decodeComponent(uri.userInfo),
      security: security.isEmpty ? 'tls' : security,
      sni: q['sni'] ?? '',
      fingerprint: q['fp'] ?? '',
      extras: {
        for (final e in q.entries)
          if (!_hysteriaKeys.contains(e.key)) e.key: e.value,
      },
    );
  }

  static EditableNode _withStreamParams(
    EditableNode base,
    Map<String, String> q, {
    required String defaultSecurity,
  }) {
    final security = (q['security'] ?? defaultSecurity).trim().toLowerCase();
    return base.copyWith(
      network: _network(q['type']),
      headerType: (q['headerType'] ?? '').isEmpty ? 'none' : q['headerType'],
      host: q['host'] ?? '',
      path: q['path'] ?? '',
      serviceName: q['serviceName'] ?? '',
      transportMode: q['mode'] ?? '',
      security: security.isEmpty ? 'none' : security,
      sni: q['sni'] ?? '',
      fingerprint: q['fp'] ?? '',
      alpn: q['alpn'] ?? '',
      publicKey: q['pbk'] ?? '',
      shortId: q['sid'] ?? '',
      spiderX: q['spx'] ?? '',
      flow: q['flow'] ?? '',
      encryption: (q['encryption'] ?? '').isEmpty ? 'none' : q['encryption'],
      extras: {
        for (final e in q.entries)
          if (!_streamKeys.contains(e.key)) e.key: e.value,
      },
    );
  }

  // ───────────────────────────── Encoding ─────────────────────────────

  /// Builds the share link for [node].
  static String encode(EditableNode node) {
    final remark = node.remark.trim();
    final fragment = remark.isEmpty ? '' : '#${Uri.encodeComponent(remark)}';
    final server = '${_hostForUri(node.address.trim())}:${node.port}';

    switch (node.protocol) {
      case NodeProtocol.vmess:
        return _encodeVmess(node);
      case NodeProtocol.vless:
        final params = _withExtras(_streamParams(node), node.extras);
        return 'vless://${_encodeUserInfo(node.userId.trim())}@$server'
            '${_query(params)}$fragment';
      case NodeProtocol.trojan:
        final params = _withExtras(_streamParams(node), node.extras);
        return 'trojan://${_encodeUserInfo(node.secret)}@$server'
            '${_query(params)}$fragment';
      case NodeProtocol.shadowsocks:
        final isPlainTcp =
            node.network == 'tcp' &&
            node.headerType != 'http' &&
            node.host.trim().isEmpty &&
            node.security == 'none';
        final params = _withExtras(
          isPlainTcp ? <String, String>{} : _streamParams(node),
          node.extras,
        );
        final userInfo = base64Url.encode(
          utf8.encode('${node.method.trim()}:${node.secret}'),
        );
        return 'ss://$userInfo@$server${_query(params)}$fragment';
      case NodeProtocol.socks:
        final hasAuth = node.username.isNotEmpty || node.secret.isNotEmpty;
        final auth =
            hasAuth
                ? '${base64Url.encode(utf8.encode('${node.username}:${node.secret}'))}@'
                : '';
        return 'socks://$auth$server${_query(node.extras)}$fragment';
      case NodeProtocol.hysteria:
      case NodeProtocol.hysteria2:
        final params = <String, String>{};
        if (node.security.isNotEmpty && node.security != 'tls') {
          params['security'] = node.security;
        }
        _put(params, 'sni', node.sni);
        _put(params, 'fp', node.fingerprint);
        final scheme =
            node.protocol == NodeProtocol.hysteria2 ? 'hysteria2' : 'hysteria';
        final auth =
            node.secret.isEmpty ? '' : '${_encodeUserInfo(node.secret)}@';
        return '$scheme://$auth$server'
            '${_query(_withExtras(params, node.extras))}$fragment';
    }
  }

  static String _encodeVmess(EditableNode node) {
    final network = node.network;
    final usesMode = network == 'grpc' || network == 'xhttp';
    final map = <String, dynamic>{
      'v': '2',
      'ps': node.remark.trim(),
      'add': node.address.trim(),
      'port': '${node.port}',
      'id': node.userId.trim(),
      'aid': '${node.alterId}',
      'scy': node.cipher.trim().isEmpty ? 'auto' : node.cipher.trim(),
      'net': network,
      'type':
          usesMode
              ? node.transportMode.trim()
              : (node.headerType.isEmpty ? 'none' : node.headerType),
      'host': node.host.trim(),
      'path': network == 'grpc' ? node.serviceName.trim() : node.path.trim(),
      'tls': node.security == 'tls' ? 'tls' : '',
      'sni': node.security == 'tls' ? node.sni.trim() : '',
      'alpn': node.security == 'tls' ? node.alpn.trim() : '',
      'fp': node.security == 'tls' ? node.fingerprint.trim() : '',
    };
    for (final e in node.extras.entries) {
      map.putIfAbsent(e.key, () => e.value);
    }
    return 'vmess://${base64.encode(utf8.encode(jsonEncode(map)))}';
  }

  /// Transport and TLS parameters for VLESS, Trojan and Shadowsocks links.
  static Map<String, String> _streamParams(EditableNode node) {
    final p = <String, String>{};
    if (node.protocol == NodeProtocol.vless) {
      final encryption = node.encryption.trim();
      p['encryption'] = encryption.isEmpty ? 'none' : encryption;
    }
    if (node.protocol == NodeProtocol.vless ||
        node.protocol == NodeProtocol.trojan) {
      _put(p, 'flow', node.flow);
    }

    final network = node.network;
    p['type'] = network;
    switch (network) {
      case 'tcp':
        if (node.headerType == 'http') {
          p['headerType'] = 'http';
          _put(p, 'host', node.host);
          _put(p, 'path', node.path);
        } else {
          _put(p, 'host', node.host);
        }
      case 'kcp' || 'quic':
        if (node.headerType.isNotEmpty && node.headerType != 'none') {
          p['headerType'] = node.headerType;
        }
      case 'grpc':
        _put(p, 'serviceName', node.serviceName);
        _put(p, 'mode', node.transportMode);
        _put(p, 'host', node.host);
      case 'xhttp':
        _put(p, 'host', node.host);
        _put(p, 'path', node.path);
        _put(p, 'mode', node.transportMode);
      default:
        _put(p, 'host', node.host);
        _put(p, 'path', node.path);
    }

    final security = node.security;
    // Trojan defaults to TLS when the parameter is missing, so "none" must
    // be written out.
    if (node.protocol == NodeProtocol.trojan || security != 'none') {
      p['security'] = security;
    }
    if (security == 'tls' || security == 'reality') {
      _put(p, 'sni', node.sni);
      _put(p, 'fp', node.fingerprint);
    }
    if (security == 'tls') _put(p, 'alpn', node.alpn);
    if (security == 'reality') {
      _put(p, 'pbk', node.publicKey);
      _put(p, 'sid', node.shortId);
      _put(p, 'spx', node.spiderX);
    }
    return p;
  }

  // ───────────────────────────── Helpers ─────────────────────────────

  static Uri _parseUri(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.host.isEmpty) {
      throw const ConfigEditException(
        message: 'The link has no server address.',
      );
    }
    return uri;
  }

  static int _portOf(Uri uri) => uri.hasPort ? uri.port : 443;

  static String _remarkOf(String fragment) {
    try {
      return Uri.decodeFull(fragment.replaceAll('+', '%20'));
    } catch (_) {
      return fragment;
    }
  }

  static String _decodeComponent(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (_) {
      return value;
    }
  }

  static String _network(String? value) {
    final n = (value ?? '').trim().toLowerCase();
    return switch (n) {
      '' || 'raw' => 'tcp',
      'http' => 'h2',
      'splithttp' => 'xhttp',
      _ => n,
    };
  }

  static void _put(Map<String, String> params, String key, String value) {
    final clean = value.trim();
    if (clean.isNotEmpty) params[key] = clean;
  }

  static Map<String, String> _withExtras(
    Map<String, String> params,
    Map<String, String> extras,
  ) {
    for (final e in extras.entries) {
      params.putIfAbsent(e.key, () => e.value);
    }
    return params;
  }

  static String _query(Map<String, String> params) {
    if (params.isEmpty) return '';
    final pairs = params.entries.map(
      (e) =>
          '${Uri.encodeQueryComponent(e.key)}='
          '${Uri.encodeQueryComponent(e.value)}',
    );
    return '?${pairs.join('&')}';
  }

  /// IPv6 addresses need brackets inside a URL.
  static String _hostForUri(String address) =>
      address.contains(':') && !address.startsWith('[')
          ? '[$address]'
          : address;

  static final _userInfoSafe = RegExp(r"[A-Za-z0-9\-._~!$&'()*+,;=:]");

  /// Percent-encodes only what would break the URL, so the core receives
  /// the same credential the user typed for ordinary values.
  static String _encodeUserInfo(String value) {
    final out = StringBuffer();
    for (final byte in utf8.encode(value)) {
      final char = String.fromCharCode(byte);
      if (byte < 0x80 && _userInfoSafe.hasMatch(char)) {
        out.write(char);
      } else {
        out.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return out.toString();
  }
}
