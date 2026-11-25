part of 'config_editor_adapter.dart';

sealed class ConfigEditorState extends Equatable {
  const ConfigEditorState();

  @override
  List<Object?> get props => [];
}

final class ConfigEditorLoading extends ConfigEditorState {
  const ConfigEditorLoading();
}

final class ConfigEditorReady extends ConfigEditorState {
  const ConfigEditorReady(this.node);
  final EditableNode node;

  @override
  List<Object?> get props => [node];
}

final class ConfigEditorSaving extends ConfigEditorState {
  const ConfigEditorSaving(this.node);
  final EditableNode node;

  @override
  List<Object?> get props => [node];
}

final class ConfigEditorSaved extends ConfigEditorState {
  const ConfigEditorSaved(this.config);
  final Config config;

  @override
  List<Object?> get props => [config.id, config.uri];
}

final class ConfigEditorLoadFailed extends ConfigEditorState {
  const ConfigEditorLoadFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
