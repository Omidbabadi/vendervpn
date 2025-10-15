import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

abstract class ConnectionDatasrc {
  const ConnectionDatasrc();

  Future<bool> initializeV2Ray();
  Future<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  );
  void disconnect();

  ValueNotifier<V2RayStatus> get connectionStatus;
}

class ConnectionDatasrcImpl implements ConnectionDatasrc {
  const ConnectionDatasrcImpl(this._flutterV2ray, this._status);

  final FlutterV2ray _flutterV2ray;
  final ValueNotifier<V2RayStatus> _status;

  @override
  Future<bool> initializeV2Ray() async {
    await _flutterV2ray.initializeV2Ray(
      notificationIconResourceType: 'mipmap',
      notificationIconResourceName: 'ic_launcher',
    );
    final per = await _flutterV2ray.requestPermission();
    return per;
  }

  @override
  Future<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  ) async {
    await _flutterV2ray.startV2Ray(
      remark: remark,
      config: config,
      blockedApps: blockedApps,
      bypassSubnets: bypassSubnets,
      proxyOnly: proxyOnly,
      notificationDisconnectButtonName: 'Disconnect $remark',
    );
  }

  @override
  void disconnect() {
    _flutterV2ray.stopV2Ray();
  }

  @override
  ValueNotifier<V2RayStatus> get connectionStatus {
    return _status;
  }
}
