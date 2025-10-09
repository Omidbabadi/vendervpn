import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class ConnectionRepo {
  ResultFuture<bool> initializeV2Ray();
  ResultFuture<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  );
  void disconnect();

  ValueNotifier<V2RayStatus> get connectionStatus;
}
