import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/common/entities/vpn_service_state.dart';
import 'package:vendervpn/core/common/entities/vpn_status.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/connection/data/datasrc/connection_datasrc.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

class ConnectionRepoImpl implements ConnectionRepo {
  const ConnectionRepoImpl(this._datasrc);

  final ConnectionDatasrc _datasrc;

  @override
  ResultFuture<bool> requestPermission() async {
    try {
      final result = await _datasrc.requestPermission();
      return Right(result);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure.fromException(e));
    }
  }

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
  ResultFuture<void> initialize() async {
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
    List<String>? blockedApps, {
    int trafficLimitBytes = 0,
  }) async {
    try {
      await _datasrc.connect(
        config,
        remark,
        proxyOnly,
        bypassSubnets,
        blockedApps,
        trafficLimitBytes: trafficLimitBytes,
      );
      return Right(null);
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure.fromException(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  Stream<VpnStatus> get statusStream => _datasrc.statusStream;

  @override
  VpnStatus get currentStatus => _datasrc.currentStatus;

  @override
  Future<void> disconnect() async {
    await _datasrc.disconnect();
  }

  @override
  Future<VpnServiceState?> getServiceState() => _datasrc.getServiceState();
}
