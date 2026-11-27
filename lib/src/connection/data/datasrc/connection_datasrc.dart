import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/src/connection/data/models/vpn_status_mapper.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/consts.dart';
import 'package:vendervpn/core/utils/app_log.dart';

abstract class ConnectionDatasrc {
  const ConnectionDatasrc();

  Future<void> initialize();
  Future<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps, {
    int trafficLimitBytes = 0,
  });
  Future<void> disconnect();
  Future<int> ping(String config);
  Future<bool> requestPermission();

  /// Every status update from the plugin, mapped to [VpnStatus] and
  /// delivered synchronously.
  Stream<VpnStatus> get statusStream;

  /// The last status the plugin reported.
  VpnStatus get currentStatus;

  /// Whether the native service is really running, or null if that can't be
  /// asked (older plugin build, unsupported platform).
  Future<VpnServiceState?> getServiceState();
}

class ConnectionDatasrcImpl implements ConnectionDatasrc {
  /// [status] is fed by the plugin's `onStatusChanged` callback (see the DI
  /// setup); this class turns it into a stream of domain entities.
  ConnectionDatasrcImpl(this._v2ray, this._status) {
    _status.addListener(_forward);
  }

  final V2ray _v2ray;
  final ValueNotifier<V2RayStatus> _status;
  bool _isInitialized = false;

  // Sync so listeners see every update in order, exactly as the plugin sent
  // them (the cloud usage meter counts deltas between updates).
  final _controller = StreamController<VpnStatus>.broadcast(sync: true);

  void _forward() => _controller.add(_status.value.toEntity());

  @override
  Stream<VpnStatus> get statusStream => _controller.stream;

  @override
  VpnStatus get currentStatus => _status.value.toEntity();

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
      appLogStack(stackTrace: s);

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
      appLogStack(stackTrace: s);

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
      appLogStack(stackTrace: s);

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
    List<String>? blockedApps, {
    int trafficLimitBytes = 0,
  }) async {
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
        trafficLimitBytes: trafficLimitBytes,
      );
    } on ConnectionException {
      rethrow;
    } catch (e, s) {
      appLogStack(stackTrace: s);

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
  Future<VpnServiceState?> getServiceState() async {
    try {
      final state = await _v2ray.getServiceState();
      return state.toEntity();
    } catch (e, s) {
      appLogStack(stackTrace: s, label: 'getServiceState failed: $e');
      return null;
    }
  }
}
