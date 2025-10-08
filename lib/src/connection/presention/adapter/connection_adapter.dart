import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';

import '../../../../core/common/entities/config.dart';
import '../../../../core/services/injection_container.dart';
import '../../domain/usecase/connect.dart';
import '../../domain/usecase/disconnect.dart';
import '../../domain/usecase/get_vpn_state.dart';

part 'connection_adapter.g.dart';

part 'connection_state.dart';

@riverpod
class ConnectionAdapter extends _$ConnectionAdapter {
  @override
  ConnectionState build([GlobalKey? familyKey]) {
    _connect = sl<Connect>();
    _getVpnState = sl<GetVpnState>();
    _disconnect = sl<Disconnect>();
    _state = sl<GetVpnState>();
    return ConnectionStateInitial();
  }

  late Connect _connect;
  late GetVpnState _getVpnState;
  late Disconnect _disconnect;
  late GetVpnState _state;

  Future<void> startConnection() async {
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
      },
      (r) {
        state = ConnectionStateConnected(_getVpnState.call, config);
      },
    );
  }

  void stopConnection() {
    _disconnect.call();
    state = ConnectionStateDisconnected();
  }

  ValueNotifier<V2RayStatus> get status => _state.call;
}
