// ignore_for_file: avoid_public_notifier_properties
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_interstitial_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_interstitial_ad.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategy.dart';
import 'package:vendervpn/src/usage_quota/data/datasrc/usage_quota_local_datasrc.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_outbox.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_quota_model.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/quota_repository.dart';

/// Only the session marker matters for the meter; the rest is inert.
class FakeQuotaLocalDatasrc implements UsageQuotaLocalDatasrc {
  FakeQuotaLocalDatasrc({this.sessionCounted});

  @override
  int? sessionCounted;

  @override
  Future<void> saveSessionCounted(int? total) async => sessionCounted = total;

  @override
  UsageQuotaModel? get snapshot => null;

  @override
  Future<void> saveSnapshot(UsageQuotaModel quota) async {}

  @override
  UsageOutbox get outbox => const UsageOutbox();

  @override
  Future<void> saveOutbox(UsageOutbox outbox) async {}
}

/// An in-memory quota server. Records every call so tests can assert that
/// local nodes never reach it.
class FakeQuotaRepository implements QuotaRepository {
  FakeQuotaRepository({this.free = 1000, this.used = 0});

  static const perAdBytes = 500;

  int free;
  int used;
  int pending = 0;
  int bonus = 0;
  int bonusesLeft = 3;

  /// Returned by [addRewardBonus] instead of a bonus, when set.
  Failure? bonusFailure;

  final calls = <String>[];

  /// Every [addUsage] amount, in order.
  final added = <int>[];

  QuotaEntity get current => QuotaEntity(
    day: '2026-11-27',
    usedBytes: used,
    bonusBytes: bonus,
    freeBytes: free,
    bonusPerAdBytes: perAdBytes,
    maxBonusesPerDay: 3,
    bonusesLeftToday: bonusesLeft,
    resetsAt: null,
    serverTime: null,
    fetchedAt: DateTime.now(),
    pendingBytes: pending,
  );

  @override
  QuotaEntity cachedQuota() {
    calls.add('cachedQuota');
    return current;
  }

  @override
  ResultFuture<QuotaEntity> getQuota() async {
    calls.add('getQuota');
    return Right(current);
  }

  @override
  ResultFuture<QuotaEntity> addUsage(int bytes) async {
    calls.add('addUsage');
    added.add(bytes);
    pending += bytes;
    return Right(current);
  }

  @override
  ResultFuture<QuotaEntity> flushUsage() async {
    calls.add('flushUsage');
    used += pending;
    pending = 0;
    return Right(current);
  }

  @override
  ResultFuture<QuotaEntity> addRewardBonus() async {
    calls.add('addRewardBonus');
    final failure = bonusFailure;
    if (failure != null) return Left(failure);
    bonus += perAdBytes;
    bonusesLeft--;
    return Right(current);
  }
}

/// Ads that load and close at once, and count how often they were asked for.
class FakeAdmobAdapter extends AdmobAdapter {
  bool interstitialLoadSucceeds = true;
  int interstitialLoads = 0;
  int interstitialShows = 0;
  int rewardedLoads = 0;
  int rewardedShows = 0;

  @override
  AdmobState build() => const AdmobInit();

  @override
  Future<void> loadInterstitialAd(LoadInterstitialAdParams params) async {
    interstitialLoads++;
    interstitialLoadSucceeds ? params.onAdLoaded() : params.onAdFailed();
  }

  @override
  Future<void> showInterstitialAd(ShowInterstitialAdParams params) async {
    interstitialShows++;
    params.onAdShowedFullScreenContent();
    params.onAdDismissedFullScreenContent();
  }

  @override
  Future<bool> loadRewardedAd() async {
    rewardedLoads++;
    return true;
  }

  @override
  Future<bool> showRewardedAd() async {
    rewardedShows++;
    return true;
  }
}

/// Stands in for the connection adapter.
class FakeConnectionHost implements ConnectionHost {
  final _status = ValueNotifier<VpnStatus>(
    const VpnStatus(state: VpnConnectionState.connected),
  );

  int stops = 0;
  int quotaExceeded = 0;

  @override
  ValueListenable<VpnStatus> get status => _status;

  @override
  Future<void> stopConnection() async => stops++;

  @override
  void showQuotaExceeded() => quotaExceeded++;

  /// The engine reports a session total of [total] bytes.
  void report(int total, {bool limitReached = false}) {
    _status.value = VpnStatus(
      state:
          limitReached
              ? VpnConnectionState.disconnected
              : VpnConnectionState.connected,
      upload: total,
      isTrafficLimitReached: limitReached,
    );
  }

  void dispose() => _status.dispose();
}

/// Lets pending async work (unawaited futures, microtasks) finish.
Future<void> settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
