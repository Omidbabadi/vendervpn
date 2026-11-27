import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

/// Asks whether the VPN service is really running, and how the last session
/// ended if it isn't. Null when the engine can't answer.
class GetServiceState {
  const GetServiceState(this._repo);
  final ConnectionRepo _repo;

  Future<VpnServiceState?> call() => _repo.getServiceState();
}
