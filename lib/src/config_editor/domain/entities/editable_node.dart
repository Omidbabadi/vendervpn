import 'package:equatable/equatable.dart';

/// Share-link protocols the config editor understands.
enum NodeProtocol {
  vmess('VMESS'),
  vless('VLESS'),
  trojan('TROJAN'),
  shadowsocks('SS'),
  socks('SOCKS'),
  hysteria('HYSTERIA'),
  hysteria2('HY2');

  const NodeProtocol(this.label);

  final String label;

  bool get isHysteria => this == hysteria || this == hysteria2;

  /// VMess and VLESS sign in with a UUID; the others use a secret
  /// (password, or the auth string for Hysteria).
  bool get usesUserId => this == vmess || this == vless;
  bool get usesSecret => !usesUserId;
  bool get usesUsername => this == socks;
  bool get usesMethod => this == shadowsocks;
  bool get usesAlterId => this == vmess;
  bool get usesFlow => this == vless;

  /// SOCKS can run without auth, and Hysteria servers may not require it.
  bool get secretOptional => this == socks || isHysteria;

  /// Has a selectable transport (tcp, ws, grpc, ...) and TLS mode.
  bool get hasTransport =>
      this == vmess || this == vless || this == trojan || this == shadowsocks;

  bool get supportsReality => this == vless || this == trojan;
}

/// A local node's settings in editable form, independent of the
/// share-link format it is stored in.
class EditableNode extends Equatable {
  const EditableNode({
    required this.protocol,
    required this.remark,
    required this.address,
    required this.port,
    this.userId = '',
    this.secret = '',
    this.username = '',
    this.method = '',
    this.alterId = 0,
    this.cipher = 'auto',
    this.flow = '',
    this.encryption = 'none',
    this.network = 'tcp',
    this.headerType = 'none',
    this.host = '',
    this.path = '',
    this.serviceName = '',
    this.transportMode = '',
    this.security = 'none',
    this.sni = '',
    this.fingerprint = '',
    this.alpn = '',
    this.publicKey = '',
    this.shortId = '',
    this.spiderX = '',
    this.extras = const {},
  });

  final NodeProtocol protocol;
  final String remark;
  final String address;
  final int port;

  /// UUID (VMess / VLESS).
  final String userId;

  /// Password (Trojan, Shadowsocks, SOCKS) or auth string (Hysteria).
  final String secret;

  /// SOCKS username.
  final String username;

  /// Shadowsocks cipher.
  final String method;

  /// VMess alter ID and cipher.
  final int alterId;
  final String cipher;

  /// VLESS flow and encryption.
  final String flow;
  final String encryption;

  /// Transport: network type and its settings.
  final String network;
  final String headerType;
  final String host;
  final String path;
  final String serviceName;

  /// gRPC mode (gun / multi) or XHTTP mode.
  final String transportMode;

  /// TLS: `none`, `tls` or `reality`, plus their settings.
  final String security;
  final String sni;
  final String fingerprint;
  final String alpn;
  final String publicKey;
  final String shortId;
  final String spiderX;

  /// Share-link parameters the editor doesn't show; written back unchanged.
  final Map<String, String> extras;

  /// Why this node can't be saved, or null when it is valid.
  String? get validationError {
    final cleanAddress = address.trim();
    if (cleanAddress.isEmpty) return 'Address is required.';
    if (cleanAddress.contains(RegExp(r'\s'))) {
      return 'Address must not contain spaces.';
    }
    if (port < 1 || port > 65535) return 'Port must be between 1 and 65535.';
    if (protocol.usesUserId && userId.trim().isEmpty) {
      return 'UUID is required.';
    }
    if (protocol.usesMethod && method.trim().isEmpty) {
      return 'Encryption method is required.';
    }
    if (protocol.usesSecret && !protocol.secretOptional && secret.isEmpty) {
      return 'Password is required.';
    }
    if (protocol.hasTransport && security == 'reality') {
      if (publicKey.trim().isEmpty) return 'REALITY needs a public key.';
      if (sni.trim().isEmpty) return 'REALITY needs an SNI.';
    }
    return null;
  }

  EditableNode copyWith({
    NodeProtocol? protocol,
    String? remark,
    String? address,
    int? port,
    String? userId,
    String? secret,
    String? username,
    String? method,
    int? alterId,
    String? cipher,
    String? flow,
    String? encryption,
    String? network,
    String? headerType,
    String? host,
    String? path,
    String? serviceName,
    String? transportMode,
    String? security,
    String? sni,
    String? fingerprint,
    String? alpn,
    String? publicKey,
    String? shortId,
    String? spiderX,
    Map<String, String>? extras,
  }) {
    return EditableNode(
      protocol: protocol ?? this.protocol,
      remark: remark ?? this.remark,
      address: address ?? this.address,
      port: port ?? this.port,
      userId: userId ?? this.userId,
      secret: secret ?? this.secret,
      username: username ?? this.username,
      method: method ?? this.method,
      alterId: alterId ?? this.alterId,
      cipher: cipher ?? this.cipher,
      flow: flow ?? this.flow,
      encryption: encryption ?? this.encryption,
      network: network ?? this.network,
      headerType: headerType ?? this.headerType,
      host: host ?? this.host,
      path: path ?? this.path,
      serviceName: serviceName ?? this.serviceName,
      transportMode: transportMode ?? this.transportMode,
      security: security ?? this.security,
      sni: sni ?? this.sni,
      fingerprint: fingerprint ?? this.fingerprint,
      alpn: alpn ?? this.alpn,
      publicKey: publicKey ?? this.publicKey,
      shortId: shortId ?? this.shortId,
      spiderX: spiderX ?? this.spiderX,
      extras: extras ?? this.extras,
    );
  }

  @override
  List<Object?> get props => [
    protocol,
    remark,
    address,
    port,
    userId,
    secret,
    username,
    method,
    alterId,
    cipher,
    flow,
    encryption,
    network,
    headerType,
    host,
    path,
    serviceName,
    transportMode,
    security,
    sni,
    fingerprint,
    alpn,
    publicKey,
    shortId,
    spiderX,
    extras,
  ];
}
