import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/core/utils/subscription_info_parser.dart';

String _b64(String s) => base64Encode(utf8.encode(s));

void main() {
  group('parseHeader', () {
    test('reads a ; separated header', () {
      final info = SubscriptionInfoParser.parseHeader(
        'upload=100; download=200; total=1000; expire=1700000000',
      )!;
      expect(info.upload, 100);
      expect(info.download, 200);
      expect(info.total, 1000);
      expect(info.expire, 1700000000);
      expect(info.hasTrafficData, isTrue);
      expect(info.announce, isNull);
    });

    test('strips a subscription-userinfo: prefix and accepts , separators', () {
      final info = SubscriptionInfoParser.parseHeader(
        'subscription-userinfo: upload=1, download=2, total=3, expire=0',
      )!;
      expect(info.upload, 1);
      expect(info.download, 2);
      expect(info.total, 3);
      expect(info.expire, 0);
    });

    test('carries a base64 announce without traffic data', () {
      final info = SubscriptionInfoParser.parseHeader(
        null,
        rawAnnounce: 'base64:${_b64('سلام')}',
      )!;
      expect(info.announce, 'سلام');
      expect(info.hasTrafficData, isFalse);
      expect(info.total, 0);
    });

    test('returns null when there is nothing to report', () {
      expect(SubscriptionInfoParser.parseHeader(null), isNull);
      expect(SubscriptionInfoParser.parseHeader('  '), isNull);
      expect(SubscriptionInfoParser.parseHeader('foo=bar'), isNull);
    });
  });

  group('parseAnnounce', () {
    test('strips announce prefixes and keeps plain text', () {
      expect(SubscriptionInfoParser.parseAnnounce('#announce: hello'), 'hello');
      expect(SubscriptionInfoParser.parseAnnounce('announce: hi'), 'hi');
      expect(SubscriptionInfoParser.parseAnnounce('plain'), 'plain');
    });

    test('returns null for blank input', () {
      expect(SubscriptionInfoParser.parseAnnounce(null), isNull);
      expect(SubscriptionInfoParser.parseAnnounce('   '), isNull);
    });
  });

  group('announceFromBody', () {
    test('finds #announce: in a plain body', () {
      expect(
        SubscriptionInfoParser.announceFromBody(
          'vless://a\n#announce: base64:${_b64('Hi there')}',
        ),
        'Hi there',
      );
    });

    test('finds #announce: in a base64 body', () {
      expect(
        SubscriptionInfoParser.announceFromBody(
          _b64('#announce: news\nvless://a'),
        ),
        'news',
      );
    });

    test('returns null when the body has none', () {
      expect(SubscriptionInfoParser.announceFromBody('vless://a'), isNull);
      expect(SubscriptionInfoParser.announceFromBody(''), isNull);
    });
  });
}
