import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_interstitial_ad.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/domain/usecase/ping.dart';
import '../../../../core/common/entities/config.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/usecase/connect.dart';
import '../../domain/usecase/disconnect.dart';
import '../../domain/usecase/get_vpn_state.dart';

part 'connection_adapter.g.dart';

part 'connection_state.dart';

@Riverpod(keepAlive: true)
class ConnectionAdapter extends _$ConnectionAdapter {
  @override
  ConnectionState build([GlobalKey? familyKey]) {
    _connect = sl<Connect>();
    _getVpnState = sl<GetVpnState>();
    _disconnect = sl<Disconnect>();
    _state = sl<GetVpnState>();
    _cacheHelper = sl<CacheHelper>();
    _ping = sl<Ping>();
    return ConnectionStateInitial();
  }

  late CacheHelper _cacheHelper;
  late Connect _connect;
  late GetVpnState _getVpnState;
  late Disconnect _disconnect;
  late GetVpnState _state;
  late Ping _ping;

  _adParams(ConnectionState connectionState) {
    state = connectionState;
  }


  Future<int> ping(String config) async {
    final result = await _ping.call(config);
    final ping = result.fold(
      (left) {
        return -1;
      },
      (right) {
        return right;
      },
    );
    return ping;
  }

  Future<void> startConnection() async {
    final adService = ref.read(admobAdapterProvider.notifier);
    final config = ref.read(currentConfigProvider);
    if (config == null) {
      return;
    }
    state = ConnectionStateConnecting();
    final params = ConnectionsParams(
      blockedApps: [],
      bypassSubnets: [],
      config: config.configjson,
      proxyOnly: false,
      remark: config.remark,
    );
    final result = await _connect.call(params);
    result.fold(
      (l) {
        state = ConnectionStateError(l.message);
        return;
      },
      (r) async {
        final adParams = LoadInterstitialAdParams(
          () {},
          () {
            _adParams(ConnectionStateConnected(_getVpnState.call, config));
          },
          onAdDismissedFullScreenContent: () {
            state = ConnectionStateConnected(_getVpnState.call, config);
          },
          onAdFailedToShowFullScreenContent: () {
            state = ConnectionStateConnected(_getVpnState.call, config);
          },
          onAdShowedFullScreenContent: () {
            state = ConnectionStateConnected(_getVpnState.call, config);
          },
        );
        await adService.init();

        _cacheHelper.cacheVpnState('CONNECTED');
        await adService.loadInterstitialAd(adParams);
      },
    );
  }

  void stopConnection() {
    _disconnect.call();
    state = ConnectionStateDisconnected();
    _cacheHelper.cacheVpnState('DISCONNECTED');
  }

  ValueNotifier<V2RayStatus> get status => _state.call;
}
