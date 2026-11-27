import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/core/utils/v2ray_import_helper.dart';

String _b64(String s) => base64Encode(utf8.encode(s));

void main() {
  group('extractLinksFromPayload', () {
    test('keeps only supported links from plain lines', () {
      expect(
        V2rayImportHelper.extractLinksFromPayload(
          'vless://a\nnot a link\r\n  ss://b  \n',
        ),
        ['vless://a', 'ss://b'],
      );
    });

    test('decodes a base64 payload', () {
      expect(
        V2rayImportHelper.extractLinksFromPayload(
          _b64('vmess://x\ntrojan://y\n# comment'),
        ),
        ['vmess://x', 'trojan://y'],
      );
    });

    test('returns nothing for empty or garbage input', () {
      expect(V2rayImportHelper.extractLinksFromPayload(''), isEmpty);
      expect(V2rayImportHelper.extractLinksFromPayload('   '), isEmpty);
      expect(V2rayImportHelper.extractLinksFromPayload('hello world'), isEmpty);
    });
  });

  group('protocolOf', () {
    test('folds the hysteria2 aliases into HY2', () {
      expect(V2rayImportHelper.protocolOf('hy://h'), 'HY2');
      expect(V2rayImportHelper.protocolOf('hy2://h'), 'HY2');
      expect(V2rayImportHelper.protocolOf('hysteria2://h'), 'HY2');
      expect(V2rayImportHelper.protocolOf('hysteria://h'), 'HYSTERIA');
    });

    test('upper-cases other schemes and falls back to V2RAY', () {
      expect(V2rayImportHelper.protocolOf('vless://h'), 'VLESS');
      expect(V2rayImportHelper.protocolOf('no scheme'), 'V2RAY');
    });
  });

  group('countryFromRemarkFlag', () {
    test('reads the first flag emoji', () {
      expect(V2rayImportHelper.countryFromRemarkFlag('🇩🇪 Fast'), 'DE');
      expect(V2rayImportHelper.countryFromRemarkFlag('x 🇳🇱 🇩🇪'), 'NL');
    });

    test('ignores country names in plain text and empty remarks', () {
      expect(V2rayImportHelper.countryFromRemarkFlag('UK server'), isNull);
      expect(V2rayImportHelper.countryFromRemarkFlag(''), isNull);
      expect(V2rayImportHelper.countryFromRemarkFlag(null), isNull);
    });
  });

  group('parseShadowsocksCredentials', () {
    test('SIP002 with base64 userinfo', () {
      final link = 'ss://${_b64('aes-256-gcm:pass')}@1.2.3.4:8388#remark';
      final r = V2rayImportHelper.parseShadowsocksCredentials(link)!;
      expect(r.method, 'aes-256-gcm');
      expect(r.password, 'pass');
      expect(
        r.normalizedUri,
        'ss://${_b64('aes-256-gcm:pass')}@1.2.3.4:8388#remark',
      );
    });

    test('SIP002 with plain userinfo and query parameters', () {
      final r = V2rayImportHelper.parseShadowsocksCredentials(
        'ss://chacha20-ietf-poly1305:secret@host:443/?outline=1',
      )!;
      expect(r.method, 'chacha20-ietf-poly1305');
      expect(r.password, 'secret');
      expect(
        r.normalizedUri,
        'ss://${_b64('chacha20-ietf-poly1305:secret')}@host:443',
      );
    });

    test('legacy fully base64-encoded link', () {
      final link = 'ss://${_b64('aes-128-gcm:pw@example.com:8388')}#x';
      final r = V2rayImportHelper.parseShadowsocksCredentials(link)!;
      expect(r.method, 'aes-128-gcm');
      expect(r.password, 'pw');
      expect(r.normalizedUri, 'ss://${_b64('aes-128-gcm:pw')}@example.com:8388#x');
    });

    test('percent-encoded userinfo keeps + and =', () {
      final r = V2rayImportHelper.parseShadowsocksCredentials(
        'ss://2022-blake3-aes-128-gcm:abc%2Bdef%3D@h:1',
      )!;
      expect(r.method, '2022-blake3-aes-128-gcm');
      expect(r.password, 'abc+def=');
    });

    test('SS-2022 psk1:psk2 is normalized to standard padded base64', () {
      final r = V2rayImportHelper.parseShadowsocksCredentials(
        'ss://2022-blake3-aes-256-gcm:AAA-_B:CCCC@h:1',
      )!;
      expect(r.method, '2022-blake3-aes-256-gcm');
      expect(r.password, 'AAA+/B==:CCCC');
    });

    test('returns null for other schemes', () {
      expect(V2rayImportHelper.parseShadowsocksCredentials('vless://x'), isNull);
    });
  });
}
