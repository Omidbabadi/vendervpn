import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:flutter/foundation.dart';

class V2Ray {
  final FlutterV2ray _flutterV2ray;
  final ValueNotifier<V2RayStatus> status;
  String? coreVersion;

  V2Ray._(this._flutterV2ray, this.status,);

  static Future<V2Ray> create() async {
    final status = ValueNotifier<V2RayStatus>(V2RayStatus());
    final flutterV2ray = FlutterV2ray(
      onStatusChanged:
      
       (s) {
        status.value = s;
      },
    );
    final service = V2Ray._(flutterV2ray, status);

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
    try {
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
    } catch (e) {
      debugPrint(e.toString());
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
