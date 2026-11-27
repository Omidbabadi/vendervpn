import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/add_cloud_usage.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/add_reward_bonus.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/flush_cloud_usage.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/get_cached_usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/usecase/get_usage_quota.dart';
import 'package:vendervpn/core/utils/app_log.dart';

/// TEMPORARY (testing): rewarded ads are simulated and the bonus comes from
/// the server's test endpoint without ad verification. Turn this off together
/// with TEST_BONUS_ENABLED on the server once AdMob verification exists.
const bool kFakeRewardedAds = true;

/// Whether a cloud node may connect right now.
enum QuotaGate { allowed, exceeded, unavailable }

final usageQuotaProvider = NotifierProvider<UsageQuotaAdapter, UsageQuota>(
  UsageQuotaAdapter.new,
);

/// Holds today's cloud-node quota for the UI and the connection flow.
class UsageQuotaAdapter extends Notifier<UsageQuota> {
  /// Usage is reported at most this long after it was counted...
  static const _reportDelay = Duration(seconds: 60);

  /// ...or right away once this much is waiting.
  static const _reportThreshold = 25 * 1024 * 1024;

  /// A snapshot this recent is trusted at connect time without a refresh.
  static const _freshFor = Duration(minutes: 2);
  static const _connectCheckTimeout = Duration(seconds: 8);

  final _getUsageQuota = sl<GetUsageQuota>();
  final _getCachedUsageQuota = sl<GetCachedUsageQuota>();
  final _addCloudUsage = sl<AddCloudUsage>();
  final _flushCloudUsage = sl<FlushCloudUsage>();
  final _addRewardBonus = sl<AddRewardBonus>();

  Timer? _reportTimer;
  Timer? _rolloverTimer;

  @override
  UsageQuota build() {
    ref.onDispose(() {
      _reportTimer?.cancel();
      _rolloverTimer?.cancel();
    });
    final cached = _getCachedUsageQuota.call();
    _scheduleRollover(cached);
    Future.microtask(refresh);
    return cached;
  }

  /// Sends unreported usage, then reloads from the server. Returns false if
  /// the server couldn't be reached (the current state is kept).
  Future<bool> refresh() async => _apply(await _getUsageQuota.call());

  /// Connect-time check. Uses a recent snapshot, otherwise asks the server.
  /// If the server can't be reached, a snapshot from today is still used;
  /// with none, the connection is blocked.
  Future<QuotaGate> checkBeforeConnect() async {
    if (!state.isFresh(_freshFor)) {
      final loaded = await refresh().timeout(
        _connectCheckTimeout,
        onTimeout: () => false,
      );
      if (!ref.mounted) return QuotaGate.unavailable;
      if (!loaded && !state.isCurrent()) return QuotaGate.unavailable;
    }
    return state.isExceeded ? QuotaGate.exceeded : QuotaGate.allowed;
  }

  /// Counts cloud traffic. It's reported to the server in batches.
  Future<void> addUsage(int bytes) async {
    final ok = _apply(await _addCloudUsage.call(bytes));
    if (!ok || !ref.mounted) return;
    if (state.pendingBytes >= _reportThreshold) {
      unawaited(flush());
    } else {
      _reportTimer ??= Timer(_reportDelay, () {
        _reportTimer = null;
        unawaited(flush());
      });
    }
  }

  /// Reports counted usage now (on disconnect, or when the app goes to the
  /// background). If it fails the usage stays saved for the next try.
  Future<void> flush() async {
    _reportTimer?.cancel();
    _reportTimer = null;
    _apply(await _flushCloudUsage.call());
  }

  /// Asks the server for the rewarded-ad bonus. Returns null on success,
  /// otherwise a message for the user.
  Future<String?> grantRewardBonus() async {
    final result = await _addRewardBonus.call();
    return result.fold(
      (failure) {
        appLog('Reward bonus error: ${failure.errorMessage}');
        return _bonusErrorMessage(failure);
      },
      (quota) {
        _set(quota);
        return null;
      },
    );
  }

  static String _bonusErrorMessage(Failure failure) {
    return switch (failure.statusCode) {
      429 => 'You already got the most extra data for today.',
      403 => 'Extra data is turned off right now.',
      _ => "Couldn't add extra data. Check your connection and try again.",
    };
  }

  bool _apply(Result<UsageQuota> result) {
    return result.fold(
      (failure) {
        appLog('Usage quota error: ${failure.errorMessage}');
        return false;
      },
      (quota) {
        _set(quota);
        return true;
      },
    );
  }

  void _set(UsageQuota quota) {
    if (!ref.mounted) return;
    final newDay = quota.resetsAt != state.resetsAt;
    state = quota;
    if (newDay) _scheduleRollover(quota);
  }

  /// Reloads just after the server's midnight so the meter resets.
  void _scheduleRollover(UsageQuota quota) {
    _rolloverTimer?.cancel();
    final resetsAt = quota.localResetsAt;
    if (resetsAt == null) return;
    final wait =
        resetsAt.difference(DateTime.now()) + const Duration(seconds: 3);
    if (wait.isNegative) return;
    _rolloverTimer = Timer(wait, () => unawaited(refresh()));
  }
}
