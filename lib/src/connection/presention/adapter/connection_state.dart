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
  final ValueNotifier<V2RayStatus> vpnState;

  @override
  List<Object?> get props => [vpnState, config];
}

final class ConnectionStateDisconnected extends ConnectionState {
  const ConnectionStateDisconnected();
}

final class ConnectionStateError extends ConnectionState {
  final String message;

  const ConnectionStateError(this.message);

  @override
  List<Object?> get props => [message];
}
