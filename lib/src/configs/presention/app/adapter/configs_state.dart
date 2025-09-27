part of 'configs_adapter.dart';

sealed class ConfigsState extends Equatable {
  const ConfigsState();

  @override
  List<Object?> get props => [];
}

final class ConfigsInitial extends ConfigsState {
  const ConfigsInitial();
}

final class ConfigsLoading extends ConfigsState {
  const ConfigsLoading();
}

final class ConfigsLoaded extends ConfigsState {
  const ConfigsLoaded(this.configs);

  final List<Config> configs;

  @override
  @override
  List<Object?> get props => configs;
}

final class ConnectedConfig extends ConfigsState {
  const ConnectedConfig(this.config);
  final Config config;

  @override
  List<Object?> get props => [config];
}

final class ConfigsError extends ConfigsState {
  const ConfigsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
