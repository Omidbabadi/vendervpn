import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';
import 'package:vendervpn/src/config_editor/domain/repo/config_editor_repo.dart';

/// Validates an edited local node and saves it in place of the original.
class SaveEditedNode extends UsecaseWithParams<Config, SaveEditedNodeParams> {
  const SaveEditedNode(this._repo);
  final ConfigEditorRepo _repo;

  @override
  ResultFuture<Config> call(SaveEditedNodeParams params) async {
    if (params.original.isCloud) {
      return Left(
        const ConfigEditFailure(message: "Cloud nodes can't be edited."),
      );
    }
    final error = params.node.validationError;
    if (error != null) return Left(ConfigEditFailure(message: error));

    return _repo.saveNode(original: params.original, node: params.node);
  }
}

class SaveEditedNodeParams extends Equatable {
  const SaveEditedNodeParams({required this.original, required this.node});

  final Config original;
  final EditableNode node;

  @override
  List<Object?> get props => [original.id, original.uri, node];
}
