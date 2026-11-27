import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/src/configs/data/models/subscription_item_model.dart';
import 'package:vendervpn/src/configs/data/models/subscription_user_info_model.dart';

void main() {
  group('SubscriptionUserInfoModel', () {
    test('fromMap accepts string-typed numbers and trims announce', () {
      final m = SubscriptionUserInfoModel.fromMap({
        'upload': '10',
        'download': 20,
        'total': '30',
        'expire': '0',
        'announce': '  hi  ',
      });
      expect(m.upload, 10);
      expect(m.download, 20);
      expect(m.total, 30);
      expect(m.expire, 0);
      expect(m.announce, 'hi');
      expect(m.hasTrafficData, isTrue);
    });

    test('blank announce becomes null and bad numbers become 0', () {
      final m = SubscriptionUserInfoModel.fromMap({
        'upload': 'abc',
        'announce': '   ',
        'hasTrafficData': false,
      });
      expect(m.upload, 0);
      expect(m.announce, isNull);
      expect(m.hasTrafficData, isFalse);
    });

    test('toMap round-trips', () {
      const m = SubscriptionUserInfoModel(
        upload: 1,
        download: 2,
        total: 3,
        expire: 4,
        announce: 'news',
        hasTrafficData: true,
      );
      final back = SubscriptionUserInfoModel.fromMap(m.toMap());
      expect(back.upload, 1);
      expect(back.download, 2);
      expect(back.total, 3);
      expect(back.expire, 4);
      expect(back.announce, 'news');
      expect(back.hasTrafficData, isTrue);
    });
  });

  group('SubscriptionItemModel', () {
    test('fromMap fills defaults from the URL', () {
      const url = 'https://sub.example.com/a';
      final m = SubscriptionItemModel.fromMap({
        'url': '  $url ',
        'name': '',
        'intervalHours': '12',
        'lastUpdated': '2026-11-27T10:00:00.000',
        'userInfo': {'upload': 1, 'download': '2'},
      });
      expect(m.url, url);
      expect(m.id, 'sub_${url.hashCode.abs()}');
      expect(m.name, 'sub.example.com');
      expect(m.intervalHours, 12);
      expect(m.lastUpdated, DateTime(2026, 11, 27, 10));
      expect(m.userInfo?.upload, 1);
      expect(m.userInfo?.download, 2);
    });

    test('bad interval falls back to 6 and missing userInfo stays null', () {
      final m = SubscriptionItemModel.fromMap({
        'url': 'https://x.test',
        'intervalHours': 'abc',
      });
      expect(m.intervalHours, 6);
      expect(m.userInfo, isNull);
    });

    test('toMap round-trips', () {
      final m = SubscriptionItemModel(
        id: 'sub_1',
        name: 'Mine',
        url: 'https://x.test/s',
        intervalHours: 24,
        lastUpdated: DateTime(2026, 11, 27, 9, 30),
        userInfo: const SubscriptionUserInfoModel(
          upload: 5,
          download: 6,
          total: 7,
          expire: 8,
        ),
      );
      final back = SubscriptionItemModel.fromMap(m.toMap());
      expect(back.id, 'sub_1');
      expect(back.name, 'Mine');
      expect(back.url, 'https://x.test/s');
      expect(back.intervalHours, 24);
      expect(back.lastUpdated, DateTime(2026, 11, 27, 9, 30));
      expect(back.userInfo?.total, 7);
      expect(back.userInfo?.expire, 8);
    });
  });
}
