import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/configs_repo.dart';

class GetConfigs extends UsecaseWithOutParams<List<Config>> {
  const GetConfigs(this._repo);
  final ConfigsRepo _repo;

  @override
  ResultFuture<List<Config>> call() => _repo.getConfigs();
}
