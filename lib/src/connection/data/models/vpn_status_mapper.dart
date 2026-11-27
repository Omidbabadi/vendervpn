import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';

/// Maps the plugin's status types to the app's domain entities, so nothing
/// outside the data layer depends on flutter_v2ray_client.
extension V2RayStatusMapper on V2RayStatus {
  VpnStatus toEntity() => VpnStatus(
    duration: duration,
    uploadSpeed: uploadSpeed,
    downloadSpeed: downloadSpeed,
    upload: upload,
    download: download,
    state: _mapState(state),
    isTrafficLimitReached: isTrafficLimitReached,
  );
}

extension V2RayServiceStateMapper on V2RayServiceState {
  VpnServiceState toEntity() => VpnServiceState(
    isRunning: isRunning,
    isTrafficLimitReached: isTrafficLimitReached,
    upload: upload,
    download: download,
    stoppedAt: stoppedAt,
  );
}

VpnConnectionState _mapState(String state) => switch (state) {
  'CONNECTED' => VpnConnectionState.connected,
  'CONNECTING' => VpnConnectionState.connecting,
  'DISCONNECTED' => VpnConnectionState.disconnected,
  _ => VpnConnectionState.unknown,
};
