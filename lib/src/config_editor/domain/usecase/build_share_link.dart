import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/config_editor/domain/entities/editable_node.dart';
import 'package:vendervpn/src/config_editor/domain/repo/config_editor_repo.dart';

/// Builds the share link for an edited node (for copying), without saving.
class BuildShareLink extends UsecaseWithParams<String, EditableNode> {
  const BuildShareLink(this._repo);
  final ConfigEditorRepo _repo;

  @override
  ResultFuture<String> call(EditableNode params) async {
    final error = params.validationError;
    if (error != null) return Left(ConfigEditFailure(message: error));
    return _repo.buildShareLink(params);
  }
}
