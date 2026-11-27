import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/src/usage_quota/data/repo/cloud_session_meter_impl.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeQuotaLocalDatasrc local;
  late CloudSessionMeterImpl meter;

  setUp(() {
    local = FakeQuotaLocalDatasrc();
    meter = CloudSessionMeterImpl(local);
  });

  group('a live session', () {
    test('counts only the bytes since the previous update', () {
      meter.start(100);
      expect(meter.isTracking, isTrue);
      expect(meter.record(150), 50);
      expect(meter.record(400), 250);
      expect(meter.record(400), 0);
      expect(local.sessionCounted, 400);
    });

    test('nothing from before the start counts', () {
      meter.start(5000);
      expect(meter.record(5000), 0);
      expect(meter.record(5010), 10);
    });

    test('a zero after real totals is a placeholder, not a restart', () {
      meter.start(100);
      expect(meter.record(0), 0);
      expect(local.sessionCounted, 100);
      expect(meter.record(130), 30);
    });

    test('a counter restart counts everything the engine reports', () {
      meter.start(500);
      expect(meter.record(800), 300);
      expect(meter.record(200), 200);
      expect(meter.record(260), 60);
    });

    test('records nothing when not tracking', () {
      expect(meter.record(1000), 0);
      expect(local.sessionCounted, isNull);
    });

    test('stop forgets the session and its marker', () {
      meter.start(100);
      meter.record(300);
      meter.stop();
      expect(meter.isTracking, isFalse);
      expect(local.sessionCounted, isNull);
      expect(meter.record(900), 0);
    });
  });

  group('after the app was killed', () {
    test('resume counts everything used since the saved total', () {
      local.sessionCounted = 1000;
      meter.resume();
      expect(meter.isTracking, isTrue);
      expect(meter.record(1500), 500);
      expect(meter.record(1600), 100);
    });

    test('resume with no saved total only takes a starting point', () {
      meter.resume();
      expect(meter.record(700), 0);
      expect(meter.record(750), 50);
    });

    test('end reports a leftover session from its saved marker', () {
      local.sessionCounted = 300;
      final ended = meter.end();
      expect(ended.wasCloud, isTrue);
      expect(ended.lastCounted, 300);
      expect(local.sessionCounted, isNull);
    });
  });

  group('ending a session', () {
    test('end on a live session returns the last counted total', () {
      meter.start(10);
      meter.record(60);
      final ended = meter.end();
      expect(ended.wasCloud, isTrue);
      expect(ended.lastCounted, 60);
      expect(meter.isTracking, isFalse);
      expect(local.sessionCounted, isNull);
    });

    test('end with no session says there was none', () {
      final ended = meter.end();
      expect(ended.wasCloud, isFalse);
      expect(ended.lastCounted, isNull);
    });

    test('markEnded makes a stopped session count as cloud', () async {
      await meter.markEnded(900);
      final ended = meter.end();
      expect(ended.wasCloud, isTrue);
      expect(ended.lastCounted, 900);
    });

    test('clear drops a leftover marker', () async {
      local.sessionCounted = 400;
      await meter.clear();
      expect(local.sessionCounted, isNull);
      expect(meter.end().wasCloud, isFalse);
    });
  });
}
