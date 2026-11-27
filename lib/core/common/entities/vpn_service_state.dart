import 'package:equatable/equatable.dart';

/// Whether the native VPN service runs right now, and how the last session
/// ended if it doesn't. Asked for (unlike [VpnStatus], which is pushed), so
/// the app can learn the real state after it was closed or backgrounded.
class VpnServiceState extends Equatable {
  const VpnServiceState({
    required this.isRunning,
    this.isTrafficLimitReached = false,
    this.upload = 0,
    this.download = 0,
    this.stoppedAt,
  });

  final bool isRunning;

  /// The last session was stopped because its traffic limit was used up.
  final bool isTrafficLimitReached;

  /// Upload / download totals when the last session stopped (bytes).
  final int upload;
  final int download;

  /// When the last session stopped, or null if unknown.
  final DateTime? stoppedAt;

  int get totalTraffic => upload + download;

  @override
  List<Object?> get props => [
    isRunning,
    isTrafficLimitReached,
    upload,
    download,
    stoppedAt,
  ];
}
