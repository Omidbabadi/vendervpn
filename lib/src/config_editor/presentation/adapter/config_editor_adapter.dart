import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';
import 'package:vendervpn/src/config_editor/domain/usecase/build_share_link.dart';
import 'package:vendervpn/src/config_editor/domain/usecase/load_editable_node.dart';
import 'package:vendervpn/src/config_editor/domain/usecase/save_edited_node.dart';

part 'config_editor_state.dart';

final configEditorProvider =
    NotifierProvider.autoDispose<ConfigEditorAdapter, ConfigEditorState>(
      ConfigEditorAdapter.new,
    );

/// Loads one local node into the editor and saves the edited result.
class ConfigEditorAdapter extends Notifier<ConfigEditorState> {
  final _loadEditableNode = sl<LoadEditableNode>();
  final _saveEditedNode = sl<SaveEditedNode>();
  final _buildShareLink = sl<BuildShareLink>();

  Config? _original;

  @override
  ConfigEditorState build() => const ConfigEditorLoading();

  Future<void> load(Config config) async {
    _original = config;
    state = const ConfigEditorLoading();
    final result = await _loadEditableNode.call(config);
    if (!ref.mounted) return;
    state = result.fold(
      (failure) => ConfigEditorLoadFailed(failure.message),
      ConfigEditorReady.new,
    );
  }

  /// Saves [node]. Returns an error message, or null on success.
  Future<String?> save(EditableNode node) async {
    final original = _original;
    if (original == null) return 'The node is still loading.';

    state = ConfigEditorSaving(node);
    final result = await _saveEditedNode.call(
      SaveEditedNodeParams(original: original, node: node),
    );
    if (!ref.mounted) return null;

    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      state = ConfigEditorReady(node);
      return failure.message;
    }

    final saved = result.getOrElse(() => original);
    _original = saved;
    ref.read(localConfigsListProvider.notifier).applySavedConfig(saved);
    if (ref.read(currentConfigProvider)?.id == saved.id) {
      await ref.read(currentConfigProvider.notifier).setCurrentConfig(saved);
    }
    if (ref.mounted) state = ConfigEditorSaved(saved);
    return null;
  }

  Future<Result<String>> shareLink(EditableNode node) =>
      _buildShareLink.call(node);
}
