import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';

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
    return ConnectionStateInitial();
  }

  late CacheHelper _cacheHelper;
  late Connect _connect;
  late GetVpnState _getVpnState;
  late Disconnect _disconnect;
  late GetVpnState _state;

  Future<void> startConnection({bool isStartup = (false)}) async {
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
        if(isStartup){
        ref.read(admobAdapterProvider.notifier).init();
        }        await Future.delayed(Duration(seconds: 2));

        ref.read(admobAdapterProvider.notifier).loadInterstitialAd();
        _cacheHelper.cacheVpnState('CONNECTED');

        await Future.delayed(Duration(seconds: 5));

        state = ConnectionStateConnected(_getVpnState.call, config);
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
