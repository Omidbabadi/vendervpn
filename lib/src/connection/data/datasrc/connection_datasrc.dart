import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/common/singelton/unity_ads_core.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/injection_container.dart';
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
    try{
    await _flutterV2ray.startV2Ray(
      remark: remark,
      config: config,
      blockedApps: blockedApps,
      bypassSubnets: Constants.subnets,
      proxyOnly: proxyOnly,
      notificationDisconnectButtonName: 'Disconnect $remark',
    );
    final ping = await _flutterV2ray.getConnectedServerDelay();
    if(ping == -1){
      //disconnect();
      throw ConnectionException(
        message: 'Error: Server Is Unreachable, Most Likely The Server Is Down. \n Please Choose Another Server Or Check Your Ineternet'
        ,ping: -1
      );
    }
    final adService = sl<UnityAdsService>();
    await adService.initialize();
    if(adService.isInitialized){
     await adService.showInterstitial();
    }} on ConnectionException {
      rethrow;
    }catch(e,s){
      debugPrintStack(stackTrace: s);

      throw const ConnectionException(message: 'There Was An Error While Connecting', ping: -1);
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
