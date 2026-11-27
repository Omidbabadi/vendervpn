import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/node_source.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_error.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategies.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategy.dart';
import 'package:vendervpn/src/usage_quota/data/repo/cloud_session_meter_impl.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/add_cloud_usage.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/add_reward_bonus.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/flush_cloud_usage.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/get_cached_usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/get_usage_quota.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/cloud_session_meter_provider.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeQuotaRepository repo;
  late FakeQuotaLocalDatasrc local;
  late ProviderContainer container;
  late FakeAdmobAdapter ads;
  late FakeConnectionHost host;
  late ConnectStrategies strategies;

  ConnectAttempt liveAttempt() => ConnectAttempt((_) => true);

  setUp(() {
    repo = FakeQuotaRepository(free: 1000);
    local = FakeQuotaLocalDatasrc();
    sl
      ..registerLazySingleton(() => GetUsageQuota(repo))
      ..registerLazySingleton(() => GetCachedUsageQuota(repo))
      ..registerLazySingleton(() => AddCloudUsage(repo))
      ..registerLazySingleton(() => FlushCloudUsage(repo))
      ..registerLazySingleton(() => AddRewardBonus(repo));

    container = ProviderContainer(
      overrides: [
        cloudSessionMeterProvider.overrideWithValue(
          CloudSessionMeterImpl(local),
        ),
        admobAdapterProvider.overrideWith(FakeAdmobAdapter.new),
      ],
    );
    ads = container.read(admobAdapterProvider.notifier) as FakeAdmobAdapter;
    strategies = container.read(connectStrategiesProvider);
    host = FakeConnectionHost();
  });

  tearDown(() async {
    host.dispose();
    container.dispose();
    await sl.reset();
  });

  group('choosing a strategy', () {
    Config node(String importedFrom) =>
        const Config.empty().copyWith(importedFrom: importedFrom);

    test('cloud nodes get the cloud strategy', () {
      final strategy = strategies.forConfig(node(NodeSource.cloudTag));
      expect(strategy.source, NodeSource.cloud);
      expect(strategy, same(strategies.cloud));
    });

    test('imported and subscription nodes get the local strategy', () {
      for (final tag in ['local', 'sub:work', 'clipboard', '']) {
        expect(strategies.forConfig(node(tag)), same(strategies.local));
      }
    });
  });

  group('local nodes', () {
    test('never touch the quota or rewarded ads', () async {
      final strategy = strategies.local;
      expect(
        await strategy.beforeConnect(watchRewardedAd: false),
        ConnectGate.allowed,
      );
      expect(strategy.trafficLimit(watchRewardedAd: false), 0);
      expect(strategy.checksTunnelAfterAdStep, isFalse);
      final adStep = await strategy.afterTunnelUp(
        liveAttempt(),
        watchRewardedAd: false,
      );
      expect(adStep.passed, isTrue);

      strategy.onConnected(host);
      host.report(5000);
      host.report(90000);
      expect(strategy.isTrackingUsage, isFalse);
      strategy.onAppLeaving();
      expect(await strategy.beforeUserDisconnect(connected: true), isTrue);
      strategy.onStopping();
      strategy.onStopped();
      await settle();

      expect(repo.calls, isEmpty);
      expect(container.exists(usageQuotaProvider), isFalse);
      expect(ads.rewardedLoads, 0);
      expect(ads.rewardedShows, 0);
    });

    test('a leftover cloud marker is dropped before connecting', () async {
      local.sessionCounted = 777;
      await strategies.local.beforeConnect(watchRewardedAd: false);
      expect(local.sessionCounted, isNull);
    });

    test('a loaded interstitial is shown on disconnect', () async {
      final strategy = strategies.local;
      strategy.onConnected(host);
      expect(ads.interstitialLoads, 1);
      expect(ads.interstitialShows, 0);

      expect(await strategy.beforeUserDisconnect(connected: true), isTrue);
      expect(ads.interstitialShows, 1);
    });

    test('disconnects at once when no ad loaded', () async {
      ads.interstitialLoadSucceeds = false;
      final strategy = strategies.local;
      strategy.onConnected(host);
      expect(await strategy.beforeUserDisconnect(connected: true), isTrue);
      expect(ads.interstitialShows, 0);
    });

    test('no ad once the session is stopping', () async {
      final strategy = strategies.local;
      strategy.onConnected(host);
      strategy.onStopping();
      expect(await strategy.beforeUserDisconnect(connected: true), isTrue);
      expect(ads.interstitialShows, 0);
    });
  });

  group('cloud nodes', () {
    test('count only new bytes toward the quota', () async {
      strategies.cloud.onConnected(host);
      host.report(100);
      await settle();
      host.report(250);
      await settle();
      expect(repo.added, [100, 150]);
      expect(strategies.cloud.isTrackingUsage, isTrue);
      expect(host.stops, 0);
    });

    test('stop the tunnel once the quota is used up', () async {
      final cloud = strategies.cloud;
      cloud.onConnected(host);
      host.report(600);
      await settle();
      expect(host.stops, 0);

      host.report(1200);
      await settle();
      expect(repo.added, [600, 600]);
      expect(host.stops, 1);
      expect(host.quotaExceeded, 1);
      expect(cloud.isTrackingUsage, isFalse);

      // Updates after the cutoff are not counted.
      host.report(1500);
      await settle();
      expect(repo.added, [600, 600]);
    });

    test('the native traffic limit counts the rest of the allowance', () async {
      strategies.cloud.onConnected(host);
      host.report(300);
      await settle();
      host.report(350, limitReached: true);
      await settle();
      expect(repo.added, [300, 700]);
      expect(host.stops, 1);
      expect(host.quotaExceeded, 1);
    });

    test('a restored session counts what was used while killed', () async {
      local.sessionCounted = 400;
      host.report(900);
      strategies.cloud.onConnected(host, restored: true);
      await settle();
      expect(repo.added, [500]);
    });

    test('the native limit is what is left, never 0 (= unlimited)', () async {
      container.read(usageQuotaProvider);
      final cloud = strategies.cloud;
      expect(cloud.trafficLimit(watchRewardedAd: false), 1000);
      expect(
        cloud.trafficLimit(watchRewardedAd: true),
        1000 + FakeQuotaRepository.perAdBytes,
      );

      repo.used = 1000;
      await container.read(usageQuotaProvider.notifier).refresh();
      expect(cloud.trafficLimit(watchRewardedAd: false), 1);
    });

    test('the interstitial step passes without a rewarded ad', () async {
      final adStep = await strategies.cloud.afterTunnelUp(
        liveAttempt(),
        watchRewardedAd: false,
      );
      expect(adStep.passed, isTrue);
      expect(ads.interstitialShows, 1);
      expect(ads.rewardedLoads, 0);
    });

    test('a finished rewarded ad adds the server bonus', () async {
      final adStep = await strategies.cloud.afterTunnelUp(
        liveAttempt(),
        watchRewardedAd: true,
      );
      expect(adStep.passed, isTrue);
      expect(ads.rewardedShows, 1);
      expect(repo.calls, contains('addRewardBonus'));
    });

    test('a refused bonus fails the ad step with its reason', () async {
      repo.bonusFailure = const ServerFailure(
        message: 'cap',
        statusCode: 429,
      );
      final adStep = await strategies.cloud.afterTunnelUp(
        liveAttempt(),
        watchRewardedAd: true,
      );
      expect(adStep.passed, isFalse);
      expect(adStep.error, ConnectionErrorCode.rewardCapReached);
    });
  });
}
