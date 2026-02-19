import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/connection/data/datasrc/connection_datasrc.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

class ConnectionRepoImpl implements ConnectionRepo {
  const ConnectionRepoImpl(this._datasrc);

  final ConnectionDatasrc _datasrc;

  @override
  ResultFuture<int> ping(String config) async {
    try {
      final result = await _datasrc.ping(config);
      return Right(result);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure.fromException(e));
    }
  }

  @override
  ResultFuture<bool> initialize() async {
    try {
      final result = await _datasrc.initialize();
      return Right(result);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure.fromException(e));
    }
  }

  @override
  ResultFuture<void> connect(
    String config,
    String remark,
    bool proxyOnly,
    List<String>? bypassSubnets,
    List<String>? blockedApps,
  ) async {
    try {
      await _datasrc.connect(
        config,
        remark,
        proxyOnly,
        bypassSubnets,
        blockedApps,
      );
      return Right(null);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure.fromException(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ValueNotifier<V2RayStatus> get connectionStatus => _datasrc.connectionStatus;

  @override
  void disconnect() {
    _datasrc.disconnect();
  }
}
