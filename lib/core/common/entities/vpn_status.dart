import 'package:equatable/equatable.dart';

/// Where the tunnel is, as last reported by the VPN engine.
enum VpnConnectionState { connected, connecting, disconnected, unknown }

/// A live snapshot of the VPN session, pushed about once a second while
/// connected. Engine-agnostic: the data layer maps the plugin's status to it.
class VpnStatus extends Equatable {
  const VpnStatus({
    this.duration = '00:00:00',
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.upload = 0,
    this.download = 0,
    this.state = VpnConnectionState.disconnected,
    this.isTrafficLimitReached = false,
  });

  /// Session length as 'HH:MM:SS'.
  final String duration;

  /// Bytes per second.
  final int uploadSpeed;
  final int downloadSpeed;

  /// Session totals in bytes.
  final int upload;
  final int download;

  final VpnConnectionState state;

  /// True when the engine stopped the tunnel because the traffic limit given
  /// at connect time was used up.
  final bool isTrafficLimitReached;

  int get totalTraffic => upload + download;

  @override
  List<Object?> get props => [
    duration,
    uploadSpeed,
    downloadSpeed,
    upload,
    download,
    state,
    isTrafficLimitReached,
  ];
}
