import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/src/config_editor/data/models/share_link_codec.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';

void main() {
  const links = {
    'vless reality':
        'vless://1b2c3d4e-0000-4000-8000-123456789abc@example.com:443'
        '?encryption=none&flow=xtls-rprx-vision&type=tcp&security=reality'
        '&sni=www.google.com&fp=chrome&pbk=PUBKEY&sid=ab12&custom=keep#My%20Node',
    'vless ws tls':
        'vless://1b2c3d4e-0000-4000-8000-123456789abc@1.2.3.4:8443'
        '?type=ws&path=%2Fws%3Fed%3D2048&host=cdn.example.com&security=tls'
        '&sni=cdn.example.com#WS',
    'trojan':
        'trojan://p%40ss@example.org:443?security=tls&sni=example.org#Trojan',
    'ss':
        'ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpzZWNyZXQ=@5.6.7.8:8388#SS',
    'socks': 'socks://dXNlcjpwYXNz@9.9.9.9:1080#Socks',
    'hy2': 'hysteria2://authkey@hy.example.com:443?sni=hy.example.com#HY2',
  };

  for (final entry in links.entries) {
    test('${entry.key}: decode → encode keeps settings and stays parseable',
        () {
      final node = ShareLinkCodec.decode(entry.value);
      final encoded = ShareLinkCodec.encode(node);
      final again = ShareLinkCodec.decode(encoded);
      expect(again, node);
      expect(() => V2ray.parseFromURL(encoded), returnsNormally);
      expect(V2ray.parseFromURL(encoded).address, node.address);
      expect(V2ray.parseFromURL(encoded).port, node.port);
    });
  }

  test('vmess round trip', () {
    const node = EditableNode(
      protocol: NodeProtocol.vmess,
      remark: 'VM',
      address: 'vm.example.com',
      port: 443,
      userId: '1b2c3d4e-0000-4000-8000-123456789abc',
      network: 'grpc',
      serviceName: 'svc',
      transportMode: 'multi',
      security: 'tls',
      sni: 'vm.example.com',
    );
    final encoded = ShareLinkCodec.encode(node);
    expect(ShareLinkCodec.decode(encoded), node);
    expect(V2ray.parseFromURL(encoded).remark, 'VM');
  });

  test('editing keeps unknown params and changes the address', () {
    final node = ShareLinkCodec.decode(links['vless reality']!);
    expect(node.extras['custom'], 'keep');
    final edited = node.copyWith(address: 'new.example.com', port: 2053);
    final parser = V2ray.parseFromURL(ShareLinkCodec.encode(edited));
    expect(parser.address, 'new.example.com');
    expect(parser.port, 2053);
    expect(ShareLinkCodec.encode(edited), contains('custom=keep'));
  });

  test('trojan password survives special characters', () {
    final node = ShareLinkCodec.decode(links['trojan']!);
    expect(node.secret, 'p@ss');
  });
}
