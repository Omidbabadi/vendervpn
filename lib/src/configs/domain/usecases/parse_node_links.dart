import 'package:equatable/equatable.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

/// Turns share links into nodes; links that don't parse are skipped.
class ParseNodeLinks
    extends UsecaseWithParams<List<Config>, ParseNodeLinksParams> {
  const ParseNodeLinks(this._repo);
  final LocalNodesRepo _repo;

  @override
  ResultFuture<List<Config>> call(ParseNodeLinksParams params) =>
      _repo.parseLinks(
        links: params.links,
        importedFrom: params.importedFrom,
        idScope: params.idScope,
      );
}

class ParseNodeLinksParams extends Equatable {
  const ParseNodeLinksParams({
    required this.links,
    required this.importedFrom,
    this.idScope,
  });

  final List<String> links;

  /// Saved as the nodes' `importedFrom`, e.g. `clipboard` or `sub:<name>`.
  final String importedFrom;

  /// Scopes node ids to a source, so one link in two subscriptions makes
  /// two nodes.
  final String? idScope;

  @override
  List<Object?> get props => [links, importedFrom, idScope];
}
