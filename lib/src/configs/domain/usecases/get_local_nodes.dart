import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/src/configs/domain/repo/local_nodes_repo.dart';

/// The user's imported nodes saved on the device.
class GetLocalNodes extends UsecaseWithOutParamsNotFuture<List<Config>> {
  const GetLocalNodes(this._repo);
  final LocalNodesRepo _repo;

  @override
  List<Config> call() => _repo.cachedNodes();
}
