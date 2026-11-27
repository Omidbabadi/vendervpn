import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/entities/node_source.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_interstitial_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_interstitial_ad.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategy.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/cloud_session_meter.dart';

/// Local (user-imported) nodes: no quota, no traffic limit, no ad before
/// connecting. While connected an interstitial is loaded in the background
/// (AdMob only works with the tunnel up) and shown when the user taps
/// disconnect; the tunnel goes down once it closes.
class LocalConnectStrategy implements ConnectStrategy {
  LocalConnectStrategy(this._ref, this._meter);

  final Ref _ref;

  /// Only used to drop a leftover cloud session marker; local traffic is
  /// never counted.
  final CloudSessionMeter _meter;

  bool _disconnectAdReady = false;
  bool _isShowingDisconnectAd = false;

  /// Bumped on every stop, so a late ad callback from an old session is
  /// ignored.
  int _session = 0;

  @override
  NodeSource get source => NodeSource.local;

  /// A leftover cloud marker (e.g. the app was killed mid cloud session)
  /// would make this local session's traffic count as cloud usage.
  @override
  Future<ConnectGate> beforeConnect({required bool watchRewardedAd}) async {
    await _meter.clear();
    return ConnectGate.allowed;
  }

  @override
  int trafficLimit({required bool watchRewardedAd}) => 0;

  /// Local nodes get their own ad flow, on disconnect.
  @override
  Future<AdStep> afterTunnelUp(
    ConnectAttempt attempt, {
    required bool watchRewardedAd,
  }) async => const AdStep.passed();

  /// No limit and no ad step to wait on.
  @override
  bool get checksTunnelAfterAdStep => false;

  @override
  Future<void> onTunnelStoppedDuringAdStep(int sessionTotal) async {}

  @override
  void onConnected(ConnectionHost host, {bool restored = false}) {
    // Local nodes never count toward the cloud quota.
    if (restored) unawaited(_meter.clear());
    _preloadDisconnectAd();
  }

  @override
  bool get isTrackingUsage => false;

  @override
  void onAppLeaving() {}

  /// Shows the preloaded interstitial first, if there is one.
  @override
  Future<bool> beforeUserDisconnect({required bool connected}) async {
    if (_isShowingDisconnectAd) return false; // ignore taps while it's up
    if (!connected || !_disconnectAdReady) return true;

    _disconnectAdReady = false;
    _isShowingDisconnectAd = true;
    final adClosed = Completer<void>();
    void finish() {
      if (!adClosed.isCompleted) adClosed.complete();
    }

    unawaited(
      _ref
          .read(admobAdapterProvider.notifier)
          .showInterstitialAd(
            ShowInterstitialAdParams(
              onAdShowedFullScreenContent: () {},
              onAdDismissedFullScreenContent: finish,
              onAdFailedToShowFullScreenContent: finish,
            ),
          )
          .whenComplete(finish),
    );
    // Safety net in case AdMob never reports the ad closing.
    await adClosed.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {},
    );
    _isShowingDisconnectAd = false;
    return _ref.mounted;
  }

  @override
  void onStopping() {
    _session++;
    _disconnectAdReady = false;
  }

  @override
  void onStopped() {}

  void _preloadDisconnectAd() {
    _disconnectAdReady = false;
    final session = _session;
    unawaited(
      _ref
          .read(admobAdapterProvider.notifier)
          .loadInterstitialAd(
            LoadInterstitialAdParams(
              // onAdLoaded
              () {
                if (session == _session) _disconnectAdReady = true;
              },
              // onAdFailed: just disconnect without an ad later.
              () {
                _disconnectAdReady = false;
              },
            ),
          ),
    );
  }
}
