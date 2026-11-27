part of 'connection_adapter.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

final class ConnectionStateInitial extends ConnectionState {
  const ConnectionStateInitial();
}

final class ConnectionStateConnecting extends ConnectionState {
  const ConnectionStateConnecting();
}

final class ConnectionStateConnected extends ConnectionState {
  const ConnectionStateConnected(this.vpnState, this.config);
  final Config config;
  final ValueListenable<VpnStatus> vpnState;

  @override
  List<Object?> get props => [vpnState, config];
}

final class ConnectionStateDisconnected extends ConnectionState {
  const ConnectionStateDisconnected();
}

/// Today's free data for cloud nodes is used up. The UI offers a rewarded ad.
final class ConnectionStateQuotaExceeded extends ConnectionState {
  const ConnectionStateQuotaExceeded(this.at);

  /// When it happened. Each tap on connect gives a new value, so the
  /// prompt opens again even if the previous state was the same.
  final DateTime at;

  @override
  List<Object?> get props => [at];
}

/// A connection attempt failed. The UI turns [code] into text with
/// `connectionErrorText`.
final class ConnectionStateError extends ConnectionState {
  const ConnectionStateError(this.code, {this.detail});

  final ConnectionErrorCode code;

  /// The engine's own message, for [ConnectionErrorCode.connectFailed].
  final String? detail;

  @override
  List<Object?> get props => [code, detail];
}
