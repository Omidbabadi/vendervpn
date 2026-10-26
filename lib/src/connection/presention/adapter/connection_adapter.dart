import 'dart:async';

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
  }

  Future<int> ping(String config) async {
    final result = await _ping.call(config);
    return result.fold((_) => -1, (right) => right);
  }

  Future<bool> requestPermission() async {
    final vpnPermission = await _requestPermission.call();
    return vpnPermission.fold((_) => false, (_) => true);
  }

  Future<void> startConnection() async {
    final config = ref.read(currentConfigProvider);
    if (config == null) {
      debugPrint('Error: Config Not Found');
      return;
    }

    final attemptId = ++_activeAttemptId;
    _abortedByUserLeavingApp = false;
    _isAdShowingFullScreen = false;
    _isWaitingForAdmob = false;

    state = const ConnectionStateConnecting();

    await _initializeV2ay.call();
    final per = await requestPermission();
    if (!per || !ref.mounted || attemptId != _activeAttemptId) {
      debugPrint('Error: VPN Permission Denied');
      state = const ConnectionStateDisconnected();
      return;
    }

    if (ref.read(ipSessionProvider).beforeTun == null) {
      await ref.read(ipSessionProvider.notifier).lookupBeforeTun();
      if (!ref.mounted || attemptId != _activeAttemptId) return;
    }

    _isWaitingForAdmob = true;

    final params = ConnectionsParams(
      blockedApps: [],
      bypassSubnets: [],
      config: config.configjson,
      proxyOnly: false,
      remark: config.remark,
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

        final adCompletedOrAdmobFailed = await _runAdmobGate(attemptId);
        _isWaitingForAdmob = false;
        _isAdShowingFullScreen = false;

        if (!ref.mounted || attemptId != _activeAttemptId) return;

        if (!_abortedByUserLeavingApp && adCompletedOrAdmobFailed) {
          state = ConnectionStateConnected(status, config);
          await _cacheHelper.cacheVpnState('CONNECTED');
        } else {
          await stopConnection();
        }
      },
    );
  }

  Future<bool> _runAdmobGate(int attemptId) async {
    return true;
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

  Future<void> stopConnection() async {
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
