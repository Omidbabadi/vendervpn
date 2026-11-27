import 'package:flutter/foundation.dart';
import 'package:vendervpn/core/common/entities/node_source.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_error.dart';

/// Whether a node may connect right now.
enum ConnectGate { allowed, quotaExceeded, quotaUnavailable }

/// Outcome of the ad step that runs once the tunnel is up.
class AdStep {
  const AdStep.passed() : passed = true, error = null;
  const AdStep.failed([this.error]) : passed = false;

  final bool passed;

  /// Why it failed, when there's something specific to tell the user.
  final ConnectionErrorCode? error;
}

/// One connection attempt. A newer attempt, a stop or a settled session
/// makes it stale; every async step checks [isLive] before going on.
class ConnectAttempt {
  ConnectAttempt(this._isLive);

  final bool Function(ConnectAttempt attempt) _isLive;

  /// The user left or closed the app while the ad step was pending.
  bool abortedByUser = false;

  /// A full-screen ad is open, so leaving the app is expected.
  bool adShowingFullScreen = false;

  bool get isLive => _isLive(this);
}

/// What a strategy may ask of the connection it runs in.
abstract interface class ConnectionHost {
  ValueListenable<VpnStatus> get status;

  Future<void> stopConnection();

  /// Today's free data ran out mid-session; the tunnel is already down.
  void showQuotaExceeded();
}

/// The node-type specific steps of a connection. The connection adapter
/// runs the tunnel lifecycle and calls these at fixed points, so it never
/// checks the node type itself.
abstract interface class ConnectStrategy {
  NodeSource get source;

  /// Runs before anything starts. Anything but [ConnectGate.allowed] ends
  /// the attempt.
  Future<ConnectGate> beforeConnect({required bool watchRewardedAd});

  /// Bytes the engine may move before it stops the tunnel itself. 0 = none.
  int trafficLimit({required bool watchRewardedAd});

  /// Runs once the tunnel is up (ads can only load over the tunnel).
  Future<AdStep> afterTunnelUp(
    ConnectAttempt attempt, {
    required bool watchRewardedAd,
  });

  /// Whether to ask the engine if the tunnel is still up after the ad step.
  bool get checksTunnelAfterAdStep;

  /// The tunnel stopped during the ad step with [sessionTotal] bytes used.
  Future<void> onTunnelStoppedDuringAdStep(int sessionTotal);

  /// The session is up. [restored]: the app restarted with the tunnel up.
  void onConnected(ConnectionHost host, {bool restored = false});

  /// Whether this session's traffic is being counted right now.
  bool get isTrackingUsage;

  /// The app is going to the background or being closed.
  void onAppLeaving();

  /// The user tapped disconnect. Returns false to ignore the tap.
  Future<bool> beforeUserDisconnect({required bool connected});

  /// The session is being torn down, before the tunnel stops.
  void onStopping();

  /// The tunnel is down.
  void onStopped();
}
