import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/configs/data/datasrc/configs_datasrc.dart';
import 'package:vendervpn/src/configs/domain/repo/configs_repo.dart';

class ConfigsRepoImpl implements ConfigsRepo {
  const ConfigsRepoImpl(this._datasrc);
  final ConfigsRemoteDatasrc _datasrc;

  @override
  ResultFuture<List<Config>> getConfigs() async {
    try {
      final configs = await _datasrc.getConfigs();
      return Right(configs);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
