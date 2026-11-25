import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';
import 'package:vendervpn/src/config_editor/domain/repo/config_editor_repo.dart';

/// Opens a local node for editing. Cloud nodes are managed by the server
/// and can't be edited.
class LoadEditableNode extends UsecaseWithParams<EditableNode, Config> {
  const LoadEditableNode(this._repo);
  final ConfigEditorRepo _repo;

  @override
  ResultFuture<EditableNode> call(Config params) async {
    if (params.importedFrom == 'cloud') {
      return Left(
        const ConfigEditFailure(message: "Cloud nodes can't be edited."),
      );
    }
    return _repo.loadNode(params);
  }
}
