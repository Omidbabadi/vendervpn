import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/singelton/core.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/consts.dart';

abstract class ConnectionDatasrc {
  const ConnectionDatasrc();

  Future<void> initialize();
  Future<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  );
  Future<void> disconnect();
  Future<int> ping(String config);
  ValueNotifier<V2RayStatus> get connectionStatus;
  Future<bool> requestPermission();
}

class ConnectionDatasrcImpl implements ConnectionDatasrc {
  ConnectionDatasrcImpl(this._v2ray, this._status);

  final V2ray _v2ray;
  final ValueNotifier<V2RayStatus> _status;
  bool _isInitialized = false;

  @override
  Future<bool> requestPermission() async {
    try {
      final per = await _v2ray.requestPermission();
      if (per == false) {
        throw ConnectionException(message: 'Permission Denied', ping: -1);
      } else {
        return per;
      }
    } on ConnectionException {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);

      throw ConnectionException(message: 'Error: ${e.toString()}', ping: -1);
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _v2ray.initialize(
        notificationIconResourceType: 'mipmap',
        notificationIconResourceName: 'ic_launcher',
      );
      _isInitialized = true;
    } on ConnectionException {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);

      throw const ConnectionException(
        message: 'There Was An Error While Connecting',
        ping: -1,
      );
    }
  }

  @override
  Future<int> ping(String config) async {
    try {
      final ping = await _v2ray.getServerDelay(config: config);
      if (ping == -1) {
        throw ConnectionException(
          message:
              "Server Is Unreachable \n Please Choose Another Server Or Check Your Network",
          ping: -1,
        );
      }
      return ping;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);

      throw const ConnectionException(
        message: 'There Was An Error While Connecting',
        ping: -1,
      );
    }
  }

  @override
  Future<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  ) async {
    try {
      final ping = await _v2ray.getServerDelay(config: config);

      if (ping == -1) {
        throw ConnectionException(
          message:
              "Server Is Unreachable \n Please Choose Another Server Or Check Your Network",
          ping: -1,
        );
      }

      Cache.instance.setVpnDisconnected(false);
      await _v2ray.startV2Ray(
        remark: remark,
        config: config,
        blockedApps: blockedApps,
        bypassSubnets: Constants.subnets,
        proxyOnly: proxyOnly,
        notificationDisconnectButtonName: 'Disconnect $remark',
      );
    } on ConnectionException {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);

      throw const ConnectionException(
        message: 'There Was An Error While Connecting',
        ping: -1,
      );
    }
  }

  @override
  Future<void> disconnect() async {
    Cache.instance.setVpnDisconnected(true);
    _status.value = V2RayStatus();
    await _v2ray.stopV2Ray();
    _status.value = V2RayStatus();
  }

  @override
  ValueNotifier<V2RayStatus> get connectionStatus {
    return _status;
  }
}
