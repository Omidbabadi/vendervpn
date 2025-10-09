import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

import '../../../../core/usecase/usecase.dart';

class GetVpnState
    extends UsecaseWithOutParamsGeter<ValueNotifier<V2RayStatus>> {
  const GetVpnState(this._repo);
  final ConnectionRepo _repo;

  @override
  ValueNotifier<V2RayStatus> get call => _repo.connectionStatus;
}
