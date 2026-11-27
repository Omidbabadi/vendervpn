import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

class SaveLocalNodes extends UsecaseWithParams<void, List<Config>> {
  const SaveLocalNodes(this._repo);
  final LocalNodesRepo _repo;

  @override
  ResultFuture<void> call(List<Config> params) => _repo.saveNodes(params);
}
