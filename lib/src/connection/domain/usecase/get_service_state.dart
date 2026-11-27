import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

/// Asks the plugin whether the VPN service is really running, and how the
/// last session ended if it isn't. Null when the plugin can't answer.
class GetServiceState {
  const GetServiceState(this._repo);
  final ConnectionRepo _repo;

  Future<V2RayServiceState?> call() => _repo.getServiceState();
}
