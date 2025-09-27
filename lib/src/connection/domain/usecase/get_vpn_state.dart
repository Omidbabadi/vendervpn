import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

import '../../../../core/common/entities/v2ray_state.dart';
import '../../../../core/usecase/usecase.dart';

class GetVpnState extends UsecaseWithOutParamsGeter<Stream<V2RayState>> {
  const GetVpnState(this._repo);
  final ConnectionRepo _repo;
  
  @override
  Stream<V2RayState> get call => _repo.connectionStatus;
}
