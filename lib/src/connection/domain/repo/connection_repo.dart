import 'package:vendervpn/core/utils/typedefs.dart';

import '../../../../core/common/entities/v2ray_state.dart';

abstract class ConnectionRepo {
  void dispose();
  ResultFuture<bool> initializeV2Ray();
  ResultFuture<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  );
  void disconnect();

  Stream<V2RayState> get connectionStatus;
}
