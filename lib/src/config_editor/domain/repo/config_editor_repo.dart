import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';

abstract class ConfigEditorRepo {
  const ConfigEditorRepo();

  /// Reads a stored local node into editable form.
  ResultFuture<EditableNode> loadNode(Config config);

  /// Builds the share link for [node] without saving it.
  ResultFuture<String> buildShareLink(EditableNode node);

  /// Saves [node] over [original] (same id) and returns the updated node.
  ResultFuture<Config> saveNode({
    required Config original,
    required EditableNode node,
  });
}
