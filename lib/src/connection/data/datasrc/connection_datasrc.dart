import 'dart:async';

import 'package:flutter_v2ray/flutter_v2ray.dart';

import '../../../../core/common/entities/v2ray_state.dart';

abstract class ConnectionDatasrc {
  const ConnectionDatasrc();
  void dispose();
  Future<bool> initializeV2Ray();
  Future<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  );
  void disconnect();
  
  Stream<V2RayState> get connectionStatus;
}

class ConnectionDatasrcImpl implements ConnectionDatasrc {
  const ConnectionDatasrcImpl(
    this._flutterV2ray,
    this._connectionStatusController,
  );

  final FlutterV2ray _flutterV2ray;
  final StreamController<V2RayState> _connectionStatusController;

  @override
  void dispose() {
    _connectionStatusController.close();
  }

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
  Stream<V2RayState> get connectionStatus => _connectionStatusController.stream;
}
