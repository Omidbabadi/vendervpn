import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/consts.dart';

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

  //TODO: make initializtion Here
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
    try {
      final ping = await _flutterV2ray.getServerDelay(config: config);

      if (ping == -1) {
        throw ConnectionException(
          message:
              "Server Is Unreachable \n Please Choose Another Server Or Check Your Network",
          ping: -1,
        );
      }

      await _flutterV2ray.startV2Ray(
        remark: remark,
        config: config,
        blockedApps: blockedApps,
        bypassSubnets: Constants.subnets,
        proxyOnly: proxyOnly,
        notificationDisconnectButtonName: 'Disconnect $remark',
      );

    } on ConnectionException {
      rethrow;
    } on UnityException {
      print('Unity Exception Happen');
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
  void disconnect() {
    _flutterV2ray.stopV2Ray();
  }

  @override
  ValueNotifier<V2RayStatus> get connectionStatus {
    return _status;
  }
}
