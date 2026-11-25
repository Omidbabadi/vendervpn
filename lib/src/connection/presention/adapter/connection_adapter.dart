import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_interstitial_ad.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/domain/usecase/ping.dart';
import 'package:vendervpn/src/ip/presention/adapter/ip_provider.dart';
import 'package:vendervpn/src/per_app_proxy/presention/app/adpter/per_app_proxy_adapter.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/usage_quota_adapter.dart';

import '../../../../core/common/entities/config.dart';
import '../../../../core/services/injection_container.dart';
import '../../../admob/domain/usecase/load_interstitial_ad.dart';
import '../../domain/usecase/connect.dart';
import '../../domain/usecase/disconnect.dart';
import '../../domain/usecase/get_vpn_state.dart';
import '../../domain/usecase/initialize_v2ay.dart';
import '../../domain/usecase/request_permission.dart';

part 'connection_adapter.g.dart';
part 'connection_state.dart';

@Riverpod(keepAlive: true)
class ConnectionAdapter extends _$ConnectionAdapter
    with WidgetsBindingObserver {
  @override
  ConnectionState build() {
    _connect = sl<Connect>();
    _disconnect = sl<Disconnect>();
    _state = sl<GetVpnState>();
    _cacheHelper = sl<CacheHelper>();
    _ping = sl<Ping>();
    _requestPermission = sl<RequestPermission>();
    _initializeV2ay = sl<InitializeV2ay>();
    _initializeV2ay.call();

    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    return const ConnectionStateInitial();
  }

  late InitializeV2ay _initializeV2ay;
  late RequestPermission _requestPermission;
  late CacheHelper _cacheHelper;
  late Connect _connect;
  late Disconnect _disconnect;
  late GetVpnState _state;
  late Ping _ping;

  bool _isWaitingForAdmob = false;
  bool _isAdShowingFullScreen = false;
  bool _abortedByUserLeavingApp = false;
  int _activeAttemptId = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isWaitingForAdmob) return;

    // If user closes the app or switches to another app while TUN is up and
    // we are waiting on AdMob, immediately stop V2Ray and set state to Disconnected.
    final userClosedApp = state == AppLifecycleState.detached;
    final userSwitchedAppBeforeAd =
        !_isAdShowingFullScreen &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden);

    if (userClosedApp || userSwitchedAppBeforeAd) {
      debugPrint(
        'Connection aborted because user left/closed app during AdMob step ($state)',
      );
      _abortedByUserLeavingApp = true;
      _isWaitingForAdmob = false;
      _isAdShowingFullScreen = false;
      unawaited(stopConnection());
    }
  }

  void restoreConnectedState(Config config) {
    state = ConnectionStateConnected(status, config);
    // App restarted with the tunnel still up: resolve the exit IP so the
    // status card shows the node's real location instead of a stale guess.
    unawaited(ref.read(ipSessionProvider.notifier).lookupAfterTun(config));
    if (_isCloudNode(config)) {
      _startCloudUsageTracking(restoredSession: true);
    } else {
      _preloadDisconnectAd();
    }
  }

  bool _isCloudNode(Config config) => config.importedFrom == 'cloud';

  Future<int> ping(String config) async {
    final result = await _ping.call(config);
    return result.fold((_) => -1, (right) => right);
  }

  Future<bool> requestPermission() async {
    final vpnPermission = await _requestPermission.call();
    return vpnPermission.fold((_) => false, (_) => true);
  }

  /// Connects to the selected node.
  ///
  /// Cloud nodes: normally an interstitial ad is shown after the tunnel is up.
  /// With [watchRewardedAd] (today's free data is used up) a rewarded ad is
  /// shown instead, and finishing it adds 1 GB.
  Future<void> startConnection({bool watchRewardedAd = false}) async {
    final config = ref.read(currentConfigProvider);
    if (config == null) {
      debugPrint('Error: Config Not Found');
      return;
    }
    final isCloudNode = _isCloudNode(config);

    // Over today's limit: don't connect, let the UI offer the rewarded ad.
    if (isCloudNode && !watchRewardedAd) {
      final quota = await ref.read(usageQuotaProvider.notifier).refresh();
      if (!ref.mounted) return;
      if (quota.isExceeded) {
        state = ConnectionStateQuotaExceeded(DateTime.now());
        return;
      }
    }

    final attemptId = ++_activeAttemptId;
    _abortedByUserLeavingApp = false;
    _isAdShowingFullScreen = false;
    _isWaitingForAdmob = false;

    state = const ConnectionStateConnecting();

    await _initializeV2ay.call();
    final proxyOnly =
        Platform.isIOS || ref.read(perAppProxyProvider).proxyOnly;
    if (!proxyOnly) {
      final per = await requestPermission();
      if (!per || !ref.mounted || attemptId != _activeAttemptId) {
        debugPrint('Error: VPN Permission Denied');
        state = const ConnectionStateDisconnected();
        return;
      }
    }

    if (ref.read(ipSessionProvider).beforeTun == null) {
      await ref.read(ipSessionProvider.notifier).lookupBeforeTun();
      if (!ref.mounted || attemptId != _activeAttemptId) return;
    }

    _isWaitingForAdmob = true;

    final blockedApps =
        proxyOnly
            ? const <String>[]
            : await ref
                .read(perAppProxyProvider.notifier)
                .resolveBlockedAppsForVpn();
    if (!ref.mounted || attemptId != _activeAttemptId) return;

    final params = ConnectionsParams(
      blockedApps: blockedApps,
      bypassSubnets: [],
      config: config.configjson,
      proxyOnly: proxyOnly,
      remark: config.remark,
      trafficLimitBytes:
          isCloudNode ? _nativeTrafficLimit(watchRewardedAd) : 0,
    );

    final result = await _connect.call(params);
    if (!ref.mounted || attemptId != _activeAttemptId) return;

    if (_abortedByUserLeavingApp) {
      await stopConnection();
      return;
    }

    await result.fold(
      (l) async {
        _isWaitingForAdmob = false;
        state = ConnectionStateError(l.message);
      },
      (_) async {
        if (ref.mounted) {
          unawaited(
            ref.read(ipSessionProvider.notifier).lookupAfterTun(config),
          );
        }

        // Ads are only requested here, after the tunnel is up.
        final bool adGatePassed;
        if (!isCloudNode) {
          adGatePassed = true; // Local nodes get their own ad flow later.
        } else if (watchRewardedAd) {
          adGatePassed = await _runRewardedAdGate(attemptId);
        } else {
          adGatePassed = await _runAdmobGate(attemptId);
        }
        _isWaitingForAdmob = false;
        _isAdShowingFullScreen = false;

        if (!ref.mounted || attemptId != _activeAttemptId) return;

        if (!_abortedByUserLeavingApp && adGatePassed) {
          state = ConnectionStateConnected(status, config);
          await _cacheHelper.cacheVpnState('CONNECTED');
          if (isCloudNode) {
            _startCloudUsageTracking();
          } else {
            _preloadDisconnectAd();
          }
        } else {
          await stopConnection();
          if (watchRewardedAd && !_abortedByUserLeavingApp) {
            state = const ConnectionStateError(
              'The ad was not completed, so no extra data was added. '
              'Please try again.',
            );
          }
        }
      },
    );
  }

  /// Shows a rewarded ad (the tunnel is already up).
  /// Returns true if the user finished it; the 1 GB bonus is added then.
  Future<bool> _runRewardedAdGate(int attemptId) async {
    final adService = ref.read(admobAdapterProvider.notifier);

    final isLoaded = await adService.loadRewardedAd();
    if (!ref.mounted || attemptId != _activeAttemptId) return false;
    if (!isLoaded || _abortedByUserLeavingApp) return false;

    // Leaving the app while a full-screen ad is open is expected,
    // so don't treat it as the user abandoning the connection.
    _isAdShowingFullScreen = true;
    final earnedReward = await adService.showRewardedAd();
    _isAdShowingFullScreen = false;
    if (!ref.mounted || attemptId != _activeAttemptId) return false;
    if (!earnedReward) return false;

    await ref.read(usageQuotaProvider.notifier).addRewardBonus();
    return true;
  }

  /// Shows an interstitial ad (the tunnel is already up). Returns false only
  /// if the user left the app; an ad that fails to load or show still lets
  /// them connect.
  Future<bool> _runAdmobGate(int attemptId) async {
    final adService = ref.read(admobAdapterProvider.notifier);
    final gateCompleter = Completer<bool>();

    void completeOnce(bool allowConnection) {
      if (!gateCompleter.isCompleted) {
        gateCompleter.complete(allowConnection);
      }
    }

    unawaited(
      adService.loadInterstitialAd(
        LoadInterstitialAdParams(
          // onAdLoaded
          () {
            if (_abortedByUserLeavingApp || attemptId != _activeAttemptId) {
              completeOnce(false);
              return;
            }
            unawaited(
              adService.showInterstitialAd(
                ShowInterstitialAdParams(
                  onAdShowedFullScreenContent: () {
                    _isAdShowingFullScreen = true;
                  },
                  onAdDismissedFullScreenContent: () {
                    _isAdShowingFullScreen = false;
                    completeOnce(!_abortedByUserLeavingApp);
                  },
                  onAdFailedToShowFullScreenContent: () {
                    _isAdShowingFullScreen = false;
                    // AdMob failure to show -> still allow connection unless user left app
                    completeOnce(!_abortedByUserLeavingApp);
                  },
                ),
              ),
            );
          },
          // onAdFailed (AdMob load failure -> allow connection unless user left app)
          () {
            completeOnce(!_abortedByUserLeavingApp);
          },
        ),
      ),
    );

    return gateCompleter.future;
  }

  // ─── Cloud usage tracking ───
  //
  // V2Ray reports the session's total upload + download. Each status update
  // we count only the new bytes since the previous update.

  int? _lastTrafficTotal;
  bool _isTrackingCloudUsage = false;

  /// [restoredSession]: the app restarted while the tunnel kept running in the
  /// background. V2Ray's session totals kept growing meanwhile, so we resume
  /// from the total we had already counted (saved on every update) and the
  /// first update adds everything used while the app was closed. Without a
  /// saved total (older app version) the first update is only a start point.
  void _startCloudUsageTracking({bool restoredSession = false}) {
    _stopCloudUsageTracking();
    if (restoredSession) {
      _lastTrafficTotal = _cacheHelper.cloudTrafficCounted;
    } else {
      _lastTrafficTotal = status.value.upload + status.value.download;
      unawaited(_cacheHelper.cacheCloudTrafficCounted(_lastTrafficTotal));
    }
    _isTrackingCloudUsage = true;
    status.addListener(_onTrafficUpdate);
    // The status may already hold live totals from the running service.
    if (restoredSession) _onTrafficUpdate();
  }

  void _stopCloudUsageTracking() {
    if (!_isTrackingCloudUsage) return;
    _isTrackingCloudUsage = false;
    status.removeListener(_onTrafficUpdate);
    _lastTrafficTotal = null;
    unawaited(_cacheHelper.cacheCloudTrafficCounted(null));
  }

  void _onTrafficUpdate() {
    final current = status.value;
    // The plugin stopped the tunnel itself because the limit we passed at
    // connect time was used up (works even while the app is backgrounded).
    if (current.isTrafficLimitReached) {
      unawaited(_onNativeTrafficLimitReached());
      return;
    }
    // Ignore placeholder/disconnected updates (all zeros before the plugin
    // reports the running session), or they'd look like a counter restart.
    if (current.state != 'CONNECTED') return;
    final total = current.upload + current.download;
    if (total == 0 && (_lastTrafficTotal ?? 0) > 0) return;

    final last = _lastTrafficTotal;
    _lastTrafficTotal = total;
    unawaited(_cacheHelper.cacheCloudTrafficCounted(total));
    if (last == null) return; // starting point only

    // If V2Ray's counter restarted, everything it reports is new.
    final newBytes = total >= last ? total - last : total;
    if (newBytes > 0) unawaited(_recordCloudUsage(newBytes));
  }

  Future<void> _recordCloudUsage(int bytes) async {
    await ref.read(usageQuotaProvider.notifier).addUsage(bytes);
    if (!ref.mounted || !_isTrackingCloudUsage) return;

    if (ref.read(usageQuotaProvider).isExceeded) {
      _stopCloudUsageTracking();
      await stopConnection();
      state = ConnectionStateQuotaExceeded(DateTime.now());
    }
  }

  /// Bytes this cloud session may use before the plugin stops the tunnel
  /// natively. A backstop for the Dart-side check above, which can't run
  /// while the app is suspended or killed.
  ///
  /// With [watchRewardedAd] the quota is used up when we connect and the
  /// bonus is only added once the ad finishes (or the tunnel is torn down),
  /// so the limit already includes that bonus.
  int _nativeTrafficLimit(bool watchRewardedAd) {
    final quota = ref.read(usageQuotaProvider);
    final remaining =
        watchRewardedAd
            ? quota.withRewardBonus().remainingBytes
            : quota.remainingBytes;
    // 0 means "no limit" to the plugin, so never pass it for a cloud node.
    return remaining > 0 ? remaining : 1;
  }

  Future<void> _onNativeTrafficLimitReached() async {
    if (!_isTrackingCloudUsage) return;
    _stopCloudUsageTracking();
    // The plugin counted the whole allowance as used; bring our count in line
    // with it (the last bytes before the stop may not have been reported).
    final remaining = ref.read(usageQuotaProvider).remainingBytes;
    if (remaining > 0) {
      await ref.read(usageQuotaProvider.notifier).addUsage(remaining);
    }
    if (!ref.mounted) return;
    await stopConnection();
    state = ConnectionStateQuotaExceeded(DateTime.now());
  }

  // ─── Local nodes: interstitial on disconnect ───
  //
  // While a local node is connected an interstitial is loaded in the
  // background (AdMob only works with the tunnel up). When the user taps
  // disconnect it is shown first, and the tunnel goes down once it closes.

  bool _disconnectAdReady = false;
  bool _isShowingDisconnectAd = false;

  void _preloadDisconnectAd() {
    _disconnectAdReady = false;
    final attemptId = _activeAttemptId;
    unawaited(
      ref
          .read(admobAdapterProvider.notifier)
          .loadInterstitialAd(
            LoadInterstitialAdParams(
              // onAdLoaded
              () {
                if (attemptId == _activeAttemptId) _disconnectAdReady = true;
              },
              // onAdFailed: just disconnect without an ad later.
              () {
                _disconnectAdReady = false;
              },
            ),
          ),
    );
  }

  /// The user tapped disconnect. On a local node with a loaded ad, show it
  /// first, then stop the tunnel. Otherwise disconnect right away.
  Future<void> disconnectByUser() async {
    if (_isShowingDisconnectAd) return; // ignore taps while the ad is up
    final config = ref.read(currentConfigProvider);
    final showAd =
        state is ConnectionStateConnected &&
        _disconnectAdReady &&
        config != null &&
        !_isCloudNode(config);

    if (showAd) {
      _disconnectAdReady = false;
      _isShowingDisconnectAd = true;
      final adClosed = Completer<void>();
      void finish() {
        if (!adClosed.isCompleted) adClosed.complete();
      }

      unawaited(
        ref
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
      if (!ref.mounted) return;
    }

    await stopConnection();
  }

  Future<void> stopConnection() async {
    _disconnectAdReady = false;
    _stopCloudUsageTracking();
    _activeAttemptId++;
    _isWaitingForAdmob = false;
    _isAdShowingFullScreen = false;
    await _disconnect.call();
    state = const ConnectionStateDisconnected();
    await _cacheHelper.cacheVpnState('DISCONNECTED');
    if (ref.mounted) {
      unawaited(ref.read(ipSessionProvider.notifier).onTunDisconnected());
    }
  }

  ValueNotifier<V2RayStatus> get status => _state.call;
}
