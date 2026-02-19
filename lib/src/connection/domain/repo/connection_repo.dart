import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class ConnectionRepo {
  ResultFuture<bool> initialize();
  ResultFuture<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  );
  void disconnect();
  ResultFuture<int> ping(String config);
  ValueNotifier<V2RayStatus> get connectionStatus;
}
