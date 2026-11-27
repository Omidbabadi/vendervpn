import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/domain/repo/configs_repo.dart';

/// The cloud nodes saved on the device by the last successful fetch.
class GetCachedConfigs extends UsecaseWithOutParams<List<Config>> {
  const GetCachedConfigs(this._repo);
  final ConfigsRepo _repo;

  @override
  ResultFuture<List<Config>> call() => _repo.getCachedConfigs();
}
