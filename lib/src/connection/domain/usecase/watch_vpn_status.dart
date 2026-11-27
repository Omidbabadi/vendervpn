import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

/// The live VPN session status.
class WatchVpnStatus {
  const WatchVpnStatus(this._repo);
  final ConnectionRepo _repo;

  /// Every status update, delivered synchronously.
  Stream<VpnStatus> call() => _repo.statusStream;

  /// The last reported status, to seed a listener.
  VpnStatus get current => _repo.currentStatus;
}
