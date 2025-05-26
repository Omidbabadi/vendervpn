/*

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

class V2rayService {
  final ValueNotifier<V2RayStatus> status;
  final FlutterV2ray flutterV2ray;
  String? coreVersion;
  V2rayService._(this.status, this.flutterV2ray);

  factory V2rayService() {
    final status = ValueNotifier<V2RayStatus>(V2RayStatus());
    final flutterV2ray = FlutterV2ray(
      onStatusChanged: (newSataus) => status.value = newSataus,
    );

    final instance = V2rayService._(status, flutterV2ray);
    instance._initialize();
    return instance;
  }

  Future<void> _initialize() async {
    await flutterV2ray.initializeV2Ray(
      notificationIconResourceName: 'mipmap',
      notificationIconResourceType: 'ic_launcher',
    );

    coreVersion = await flutterV2ray.getCoreVersion();
  }

  Future<void> connect({
    required String config,
    required String remark,
    required bool proxyOnly,
    List<String>? bypassSubnet,
  }) async {
    if (await flutterV2ray.requestPermission()) {
      await flutterV2ray.startV2Ray(
        remark: remark,
        config: config,
        proxyOnly: proxyOnly,
        bypassSubnets: [],
        notificationDisconnectButtonName: 'DISCONNECT',
      );
    } else {
      throw Exception('Permission denied');
    }
  }

  Future<void> disconnect() async {
    await flutterV2ray.stopV2Ray();
  }

  void dispose() {
    status.dispose();
  }
}
 */

import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:flutter/foundation.dart';

class V2rayService {
  final FlutterV2ray _flutterV2ray;
  final ValueNotifier<V2RayStatus> status;
  String? coreVersion;

  V2rayService._(this._flutterV2ray, this.status);

  static Future<V2rayService> create() async {
    final status = ValueNotifier<V2RayStatus>(V2RayStatus());
    final flutterV2ray = FlutterV2ray(onStatusChanged: (s) => status.value = s);
    final service = V2rayService._(flutterV2ray, status);

    await service._initialize();
    return service;
  }

  Future<void> _initialize() async {
    await _flutterV2ray.initializeV2Ray(
      notificationIconResourceType: 'mipmap',
      notificationIconResourceName: 'ic_launcher',
    );
    coreVersion = await _flutterV2ray.getCoreVersion();
  }

  Future<void> connect({
    required String config,
    required String remark,
    required bool proxyOnly,
    List<String>? bypassSubnets,
  }) async {
    if (await _flutterV2ray.requestPermission()) {
      await _flutterV2ray.startV2Ray(
        config: config,
        remark: remark,
        proxyOnly: proxyOnly,
        bypassSubnets: bypassSubnets ?? [],
        notificationDisconnectButtonName: "DISCONNECT",
      );
    } else {
      throw Exception('Permission denied');
    }
  }

  Future<void> disconnect() => _flutterV2ray.stopV2Ray();

  Future<int> getDelay({String? config}) async {
    if (status.value.state == 'CONNECTED') {
      return await _flutterV2ray.getConnectedServerDelay();
    } else {
      if (config == null) {
        throw Exception('Config is required if not connected');
      }
      return await _flutterV2ray.getServerDelay(config: config);
    }
  }

  void dispose() => status.dispose();
}
