import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/app_log.dart';
import 'package:vendervpn/src/connection/domain/usecase/connect.dart';
import 'package:vendervpn/src/connection/domain/usecase/disconnect.dart';
import 'package:vendervpn/src/connection/domain/usecase/get_service_state.dart';
import 'package:vendervpn/src/connection/domain/usecase/initialize_v2ay.dart';
import 'package:vendervpn/src/connection/domain/usecase/request_permission.dart';
import 'package:vendervpn/src/connection/domain/usecase/watch_vpn_status.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_error.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategies.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategy.dart';
import 'package:vendervpn/src/ip/presention/adapter/ip_provider.dart';
import 'package:vendervpn/src/per_app_proxy/presention/app/adpter/per_app_proxy_adapter.dart';

export 'connection_error.dart';

part 'connection_adapter.g.dart';
part 'connection_state.dart';

/// Runs the tunnel lifecycle and holds the connection state. Everything
/// that depends on the node type (quota, ads, metering) is in the
/// [ConnectStrategy] picked for the node, so this class never checks it.
@Riverpod(keepAlive: true)
class ConnectionAdapter extends _$ConnectionAdapter
    with WidgetsBindingObserver
    implements ConnectionHost {
  @override
  ConnectionState build() {
    _connect = sl<Connect>();
    _disconnect = sl<Disconnect>();
    final watchStatus = sl<WatchVpnStatus>();
    _cacheHelper = sl<CacheHelper>();
    _requestPermission = sl<RequestPermission>();
    _initializeV2ay = sl<InitializeV2ay>();
    _getServiceState = sl<GetServiceState>();
    _strategies = ref.read(connectStrategiesProvider);
    _initializeV2ay.call();

    // The stream is synchronous, so the listeners below see every update
    // in the order the engine sent it.
    _status = ValueNotifier<VpnStatus>(watchStatus.current);
    final statusSub = watchStatus().listen((s) => _status.value = s);

    WidgetsBinding.instance.addObserver(this);
    status.addListener(_onServiceStatus);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      status.removeListener(_onServiceStatus);
      statusSub.cancel();
      _status.dispose();
    });

    return const ConnectionStateInitial();
  }

  late Connect _connect;
  late Disconnect _disconnect;
  late CacheHelper _cacheHelper;
  late RequestPermission _requestPermission;
  late InitializeV2ay _initializeV2ay;
  late GetServiceState _getServiceState;
  late ConnectStrategies _strategies;
  late ValueNotifier<VpnStatus> _status;

  /// The node-type steps of the current session, if there is one.
  ConnectStrategy? _active;

  /// The current attempt; null once it's stopped or settled.
  ConnectAttempt? _attempt;
  bool _isWaitingForAd = false;
  bool _isSettlingStop = false;

  /// Live session status for the UI and the usage meter.
  @override
  ValueListenable<VpnStatus> get status => _status;

  bool _isLive(ConnectAttempt attempt) =>
      ref.mounted && identical(attempt, _attempt);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final leaving =
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;
    if (leaving) _active?.onAppLeaving();
    // The tunnel may have stopped while we were in the background.
    if (state == AppLifecycleState.resumed) unawaited(_syncOnResume());

    final attempt = _attempt;
    if (!_isWaitingForAd || attempt == null) return;

    // Leaving the app while the tunnel is up and the ad step is pending
    // abandons the connection, unless a full-screen ad is what's showing.
    final userClosedApp = state == AppLifecycleState.detached;
    final userSwitchedAppBeforeAd =
        !attempt.adShowingFullScreen &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden);

    if (userClosedApp || userSwitchedAppBeforeAd) {
      appLog('Connection aborted: user left the app during the ad step');
      attempt.abortedByUser = true;
      attempt.adShowingFullScreen = false;
      _isWaitingForAd = false;
      unawaited(stopConnection());
    }
  }

  /// The app restarted with the tunnel still up.
  void restoreConnectedState(Config config) {
    final strategy = _strategies.forConfig(config);
    _active = strategy;
    state = ConnectionStateConnected(status, config);
    // Resolve the exit IP so the status card shows the node's real location
    // instead of a stale guess.
    unawaited(ref.read(ipSessionProvider.notifier).lookupAfterTun(config));
    strategy.onConnected(this, restored: true);
  }

  // ─── Real service state ───
  //
  // The saved 'CONNECTED' flag only says the app last saw the tunnel up. The
  // tunnel can stop without the app (traffic limit, notification button, the
  // OS, another VPN), and its stop update is lost if nothing is listening.
  // So on start and resume we ask the plugin, and settle a session that
  // ended while we weren't looking.

  /// Whether the plugin's service really runs. Null = can't tell.
  Future<VpnServiceState?> serviceState() => _getServiceState.call();

  Future<void> _syncOnResume() async {
    if (state is! ConnectionStateConnected || _isWaitingForAd) return;
    final service = await serviceState();
    if (service == null || service.isRunning || !ref.mounted) return;
    if (state is! ConnectionStateConnected) return;
    await settleStoppedSession(service);
  }

  /// A stop update arrived while connected and the app didn't ask for it.
  /// Traffic-limit stops of a metered session are the strategy's to handle.
  void _onServiceStatus() {
    if (state is! ConnectionStateConnected) return;
    // Our own disconnect sets this before it resets the status.
    if (Cache.instance.isVpnDisconnected) return;
    final current = status.value;
    if (current.state != VpnConnectionState.disconnected) return;
    if (current.isTrafficLimitReached && (_active?.isTrackingUsage ?? false)) {
      return;
    }
    unawaited(
      settleStoppedSession(
        VpnServiceState(
          isRunning: false,
          isTrafficLimitReached: current.isTrafficLimitReached,
          upload: current.upload,
          download: current.download,
        ),
      ),
    );
  }

  /// The tunnel already stopped on its own: count the cloud usage of that
  /// session, save the disconnected state and update the UI. Doesn't call the
  /// plugin's stop, since there is nothing left to stop.
  Future<void> settleStoppedSession(VpnServiceState service) async {
    if (_isSettlingStop) return;
    _isSettlingStop = true;
    try {
      // Always the cloud meter: a session left over from a killed app is
      // only known by its saved marker, not by an active strategy.
      final cloud = _strategies.cloud;
      final ended = cloud.endSession();
      _active?.onStopping();
      _active = null;
      _attempt = null;
      _isWaitingForAd = false;
      Cache.instance.setVpnDisconnected(true);
      _status.value = const VpnStatus();
      state = const ConnectionStateDisconnected();
      await _cacheHelper.cacheVpnState('DISCONNECTED');
      if (!ref.mounted) return;
      unawaited(ref.read(ipSessionProvider.notifier).onTunDisconnected());

      final exhausted = await cloud.settleEndedSession(ended, service);
      if (exhausted && ref.mounted) showQuotaExceeded();
    } finally {
      _isSettlingStop = false;
    }
  }

  Future<bool> requestPermission() async {
    final vpnPermission = await _requestPermission.call();
    return vpnPermission.fold((_) => false, (_) => true);
  }

  /// Connects to the selected node.
  ///
  /// [watchRewardedAd]: today's free cloud data is used up and the user
  /// chose to watch a rewarded ad for the server's per-ad bonus.
  Future<void> startConnection({bool watchRewardedAd = false}) async {
    final config = ref.read(currentConfigProvider);
    if (config == null) {
      appLog('Error: Config Not Found');
      return;
    }
    final strategy = _strategies.forConfig(config);

    final gate = await strategy.beforeConnect(watchRewardedAd: watchRewardedAd);
    if (!ref.mounted) return;
    switch (gate) {
      case ConnectGate.quotaExceeded:
        showQuotaExceeded();
        return;
      case ConnectGate.quotaUnavailable:
        state = const ConnectionStateError(
          ConnectionErrorCode.quotaUnavailable,
        );
        return;
      case ConnectGate.allowed:
        break;
    }

    final attempt = ConnectAttempt(_isLive);
    _attempt = attempt;
    _active = strategy;
    _isWaitingForAd = false;
    state = const ConnectionStateConnecting();

    await _initializeV2ay.call();
    if (!attempt.isLive) return;
    final proxyOnly = Platform.isIOS || ref.read(perAppProxyProvider).proxyOnly;
    if (!proxyOnly) {
      final permitted = await requestPermission();
      if (!permitted || !attempt.isLive) {
        appLog('Error: VPN Permission Denied');
        if (ref.mounted) state = const ConnectionStateDisconnected();
        return;
      }
    }

    if (ref.read(ipSessionProvider).beforeTun == null) {
      await ref.read(ipSessionProvider.notifier).lookupBeforeTun();
      if (!attempt.isLive) return;
    }

    _isWaitingForAd = true;
    final blockedApps =
        proxyOnly
            ? const <String>[]
            : await ref
                .read(perAppProxyProvider.notifier)
                .resolveBlockedAppsForVpn();
    if (!attempt.isLive) return;

    final result = await _connect.call(
      ConnectionsParams(
        blockedApps: blockedApps,
        bypassSubnets: [],
        config: config.configjson,
        proxyOnly: proxyOnly,
        remark: config.remark,
        trafficLimitBytes: strategy.trafficLimit(
          watchRewardedAd: watchRewardedAd,
        ),
      ),
    );
    if (!attempt.isLive) return;
    if (attempt.abortedByUser) {
      await stopConnection();
      return;
    }

    await result.fold(
      (failure) async {
        _isWaitingForAd = false;
        state = ConnectionStateError(
          ConnectionErrorCode.connectFailed,
          detail: failure.message,
        );
      },
      (_) => _finishConnect(attempt, strategy, config, watchRewardedAd),
    );
  }

  /// The tunnel is up: run the strategy's ad step, then go connected.
  Future<void> _finishConnect(
    ConnectAttempt attempt,
    ConnectStrategy strategy,
    Config config,
    bool watchRewardedAd,
  ) async {
    unawaited(ref.read(ipSessionProvider.notifier).lookupAfterTun(config));

    // Ads are only requested here, after the tunnel is up.
    final adStep = await strategy.afterTunnelUp(
      attempt,
      watchRewardedAd: watchRewardedAd,
    );
    if (!attempt.isLive) return;
    _isWaitingForAd = false;
    attempt.adShowingFullScreen = false;

    if (attempt.abortedByUser || !adStep.passed) {
      await stopConnection();
      if (watchRewardedAd && !attempt.abortedByUser && ref.mounted) {
        state = ConnectionStateError(
          adStep.error ?? ConnectionErrorCode.adNotCompleted,
        );
      }
      return;
    }

    // The tunnel can stop during the ad step, and its stop update is
    // ignored while connecting, so ask before showing "connected".
    if (strategy.checksTunnelAfterAdStep) {
      final service = await serviceState();
      if (!attempt.isLive) return;
      if (service != null && !service.isRunning) {
        await strategy.onTunnelStoppedDuringAdStep(service.totalTraffic);
        await settleStoppedSession(service);
        return;
      }
    }

    state = ConnectionStateConnected(status, config);
    await _cacheHelper.cacheVpnState('CONNECTED');
    if (!attempt.isLive) return;
    strategy.onConnected(this);
  }

  /// The user tapped disconnect. The strategy may show an ad first.
  Future<void> disconnectByUser() async {
    final strategy = _active;
    if (strategy != null) {
      final proceed = await strategy.beforeUserDisconnect(
        connected: state is ConnectionStateConnected,
      );
      if (!proceed || !ref.mounted) return;
    }
    await stopConnection();
  }

  @override
  Future<void> stopConnection() async {
    final strategy = _active;
    _active = null;
    strategy?.onStopping();
    _attempt = null;
    _isWaitingForAd = false;
    await _disconnect.call();
    state = const ConnectionStateDisconnected();
    await _cacheHelper.cacheVpnState('DISCONNECTED');
    if (!ref.mounted) return;
    unawaited(ref.read(ipSessionProvider.notifier).onTunDisconnected());
    strategy?.onStopped();
  }

  @override
  void showQuotaExceeded() {
    if (ref.mounted) state = ConnectionStateQuotaExceeded(DateTime.now());
  }
}
