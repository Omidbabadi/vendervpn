import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/entities/node_source.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';
import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_interstitial_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_interstitial_ad.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_error.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategy.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/cloud_session_meter.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

/// Cloud nodes: gated by today's quota, followed by an ad once the tunnel is
/// up, and metered while connected.
class CloudConnectStrategy implements ConnectStrategy {
  CloudConnectStrategy(this._ref, this._meter);

  final Ref _ref;
  final CloudSessionMeter _meter;

  /// The connection being metered, while tracking.
  ConnectionHost? _host;
  bool _flushOnStopped = false;

  UsageQuotaAdapter get _quota => _ref.read(usageQuotaProvider.notifier);
  QuotaEntity get _quotaState => _ref.read(usageQuotaProvider);

  @override
  NodeSource get source => NodeSource.cloud;

  @override
  Future<ConnectGate> beforeConnect({required bool watchRewardedAd}) async {
    if (watchRewardedAd) {
      // The server's MAX_BONUSES_PER_DAY is reached: an ad would add nothing.
      return _quotaState.canEarnBonus
          ? ConnectGate.allowed
          : ConnectGate.quotaExceeded;
    }
    // Over today's limit: don't connect, let the UI offer the rewarded ad.
    // The server decides; with no answer and no snapshot from today we can't
    // know the limit, so the connection is blocked.
    return switch (await _quota.checkBeforeConnect()) {
      QuotaGate.allowed => ConnectGate.allowed,
      QuotaGate.exceeded => ConnectGate.quotaExceeded,
      QuotaGate.unavailable => ConnectGate.quotaUnavailable,
    };
  }

  /// A backstop for the Dart-side check, which can't run while the app is
  /// suspended or killed.
  ///
  /// With [watchRewardedAd] the quota is used up when we connect and the
  /// bonus is only added once the ad finishes (or the tunnel is torn down),
  /// so the limit already includes that bonus.
  @override
  int trafficLimit({required bool watchRewardedAd}) {
    final quota = _quotaState;
    final remaining =
        watchRewardedAd
            ? quota.withRewardBonus().remainingBytes
            : quota.remainingBytes;
    // 0 means "no limit" to the plugin, so never pass it for a cloud node.
    return remaining > 0 ? remaining : 1;
  }

  /// Normally an interstitial. With [watchRewardedAd] (today's free data is
  /// used up) a rewarded ad, and finishing it adds the server's bonus.
  @override
  Future<AdStep> afterTunnelUp(
    ConnectAttempt attempt, {
    required bool watchRewardedAd,
  }) {
    return watchRewardedAd
        ? _runRewardedAdGate(attempt)
        : _runInterstitialGate(attempt);
  }

  /// The tunnel can stop during the ad step (e.g. the native traffic limit
  /// with only a little data left).
  @override
  bool get checksTunnelAfterAdStep => true;

  @override
  Future<void> onTunnelStoppedDuringAdStep(int sessionTotal) =>
      _meter.markEnded(sessionTotal);

  @override
  void onConnected(ConnectionHost host, {bool restored = false}) {
    _stopTracking();
    _host = host;
    if (restored) {
      _meter.resume();
    } else {
      _meter.start(host.status.value.totalTraffic);
    }
    host.status.addListener(_onTrafficUpdate);
    // The status may already hold live totals from the running service.
    if (restored) _onTrafficUpdate();
  }

  @override
  bool get isTrackingUsage => _meter.isTracking;

  /// Report counted usage before the OS may suspend or kill the app.
  @override
  void onAppLeaving() {
    if (_meter.isTracking) unawaited(_quota.flush());
  }

  @override
  Future<bool> beforeUserDisconnect({required bool connected}) async => true;

  @override
  void onStopping() {
    _flushOnStopped = _flushOnStopped || _meter.isTracking;
    _stopTracking();
  }

  /// Sends the session's last counted bytes now that the tunnel is down.
  @override
  void onStopped() {
    if (!_flushOnStopped) return;
    _flushOnStopped = false;
    unawaited(_quota.flush());
  }

  // ─── A session that stopped on its own ───

  /// Ends the meter's session, live or left over from a killed app. Call it
  /// before the session is torn down, then pass the result to
  /// [settleEndedSession].
  MeteredSessionEnd endSession() {
    _host?.status.removeListener(_onTrafficUpdate);
    _host = null;
    return _meter.end();
  }

  /// Counts the usage of a session that stopped while we weren't looking.
  /// Returns true if today's quota is now used up.
  Future<bool> settleEndedSession(
    MeteredSessionEnd ended,
    VpnServiceState service,
  ) async {
    if (!ended.wasCloud) return false;
    final lastCounted = ended.lastCounted;
    if (service.isTrafficLimitReached) {
      // The plugin used the whole allowance we gave it.
      final remaining = _quotaState.remainingBytes;
      if (remaining > 0) await _quota.addUsage(remaining);
    } else if (lastCounted != null) {
      final total = service.totalTraffic;
      if (total > lastCounted) await _quota.addUsage(total - lastCounted);
    }
    if (!_ref.mounted) return false;
    unawaited(_quota.flush());
    return service.isTrafficLimitReached || _quotaState.isExhausted;
  }

  // ─── Usage tracking ───

  void _stopTracking() {
    _host?.status.removeListener(_onTrafficUpdate);
    _host = null;
    _meter.stop();
  }

  void _onTrafficUpdate() {
    final host = _host;
    if (host == null) return;
    final current = host.status.value;
    // The plugin stopped the tunnel itself because the limit we passed at
    // connect time was used up (works even while the app is backgrounded).
    if (current.isTrafficLimitReached) {
      unawaited(_onNativeTrafficLimitReached(host));
      return;
    }
    // Ignore placeholder/disconnected updates (all zeros before the plugin
    // reports the running session), or they'd look like a counter restart.
    if (current.state != VpnConnectionState.connected) return;
    final newBytes = _meter.record(current.totalTraffic);
    if (newBytes > 0) unawaited(_recordUsage(host, newBytes));
  }

  Future<void> _recordUsage(ConnectionHost host, int bytes) async {
    await _quota.addUsage(bytes);
    if (!_ref.mounted || !_meter.isTracking) return;
    if (_quotaState.isExhausted) {
      _stopTracking();
      await host.stopConnection();
      host.showQuotaExceeded();
    }
  }

  Future<void> _onNativeTrafficLimitReached(ConnectionHost host) async {
    if (!_meter.isTracking) return;
    _stopTracking();
    // The plugin counted the whole allowance as used; bring our count in line
    // with it (the last bytes before the stop may not have been reported).
    final remaining = _quotaState.remainingBytes;
    if (remaining > 0) await _quota.addUsage(remaining);
    if (!_ref.mounted) return;
    await host.stopConnection();
    host.showQuotaExceeded();
  }

  // ─── Ad gates (the tunnel is already up) ───

  /// Passes only if the user finished the ad and the server added the bonus.
  Future<AdStep> _runRewardedAdGate(ConnectAttempt attempt) async {
    final ads = _ref.read(admobAdapterProvider.notifier);

    final isLoaded = await ads.loadRewardedAd();
    if (!attempt.isLive) return const AdStep.failed();
    if (!isLoaded || attempt.abortedByUser) return const AdStep.failed();

    // Leaving the app while a full-screen ad is open is expected,
    // so don't treat it as the user abandoning the connection.
    attempt.adShowingFullScreen = true;
    final earnedReward = await ads.showRewardedAd();
    attempt.adShowingFullScreen = false;
    if (!attempt.isLive || !earnedReward) return const AdStep.failed();

    // The server grants the bonus; if it refuses (daily cap) or can't be
    // reached, the tunnel is torn down and the reason shown.
    final error = await _quota.grantRewardBonus();
    if (!attempt.isLive) return const AdStep.failed();
    return switch (error) {
      null => const AdStep.passed(),
      RewardBonusError.capReached => const AdStep.failed(
        ConnectionErrorCode.rewardCapReached,
      ),
      RewardBonusError.disabled => const AdStep.failed(
        ConnectionErrorCode.rewardDisabled,
      ),
      RewardBonusError.failed => const AdStep.failed(
        ConnectionErrorCode.rewardFailed,
      ),
    };
  }

  /// Fails only if the user left the app; an ad that fails to load or show
  /// still lets them connect.
  Future<AdStep> _runInterstitialGate(ConnectAttempt attempt) async {
    final ads = _ref.read(admobAdapterProvider.notifier);
    final gate = Completer<bool>();

    void completeOnce(bool allowConnection) {
      if (!gate.isCompleted) gate.complete(allowConnection);
    }

    unawaited(
      ads.loadInterstitialAd(
        LoadInterstitialAdParams(
          // onAdLoaded
          () {
            if (attempt.abortedByUser || !attempt.isLive) {
              completeOnce(false);
              return;
            }
            unawaited(
              ads.showInterstitialAd(
                ShowInterstitialAdParams(
                  onAdShowedFullScreenContent: () {
                    attempt.adShowingFullScreen = true;
                  },
                  onAdDismissedFullScreenContent: () {
                    attempt.adShowingFullScreen = false;
                    completeOnce(!attempt.abortedByUser);
                  },
                  onAdFailedToShowFullScreenContent: () {
                    attempt.adShowingFullScreen = false;
                    completeOnce(!attempt.abortedByUser);
                  },
                ),
              ),
            );
          },
          // onAdFailed: a load failure still lets them connect.
          () => completeOnce(!attempt.abortedByUser),
        ),
      ),
    );

    return await gate.future ? const AdStep.passed() : const AdStep.failed();
  }
}
