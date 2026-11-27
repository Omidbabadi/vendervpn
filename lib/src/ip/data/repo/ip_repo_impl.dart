import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/ip/data/datasrc/ip_remote_datasrc.dart';
import 'package:vendervpn/src/ip/domain/entities/ip_info.dart';
import 'package:vendervpn/src/ip/domain/repo/ip_repo.dart';

class IpRepoImpl implements IpRepo {
  const IpRepoImpl(this._remoteDatasrc);
  final IpRemoteDatasrc _remoteDatasrc;

  @override
  ResultFuture<String> ipToCountry([String? ip]) async {
    try {
      final country = await _remoteDatasrc.ipToCountry(ip);
      return Right(country);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultFuture<IpInfo> fetchIpInfo({
    int? localHttpProxyPort,
    bool isTunnel = false,
  }) async {
    try {
      final info = await _remoteDatasrc.fetchIpInfo(
        localHttpProxyPort: localHttpProxyPort,
        isTunnel: isTunnel,
      );
      return Right(info);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}
