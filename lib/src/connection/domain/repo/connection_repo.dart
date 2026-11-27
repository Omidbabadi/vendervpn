import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class ConnectionRepo {
  ResultFuture<void> initialize();
  ResultFuture<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps, {
    int trafficLimitBytes = 0,
  });
  Future disconnect();
  ResultFuture<int> ping(String config);
  ResultFuture<bool> requestPermission();

  /// Live session status. Events are delivered synchronously, in the order
  /// the engine reports them.
  Stream<VpnStatus> get statusStream;

  /// The last status the engine reported.
  VpnStatus get currentStatus;

  /// The real native service state, or null if it can't be asked.
  Future<VpnServiceState?> getServiceState();
}
