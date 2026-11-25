import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/data/datasrc/usage_quota_local_datasrc.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_quota_model.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

class UsageQuotaRepoImpl implements UsageQuotaRepo {
  const UsageQuotaRepoImpl(this._localDatasrc);
  final UsageQuotaLocalDatasrc _localDatasrc;

  @override
  ResultFuture<UsageQuota> getQuota() async {
    try {
      final quota = await _localDatasrc.getQuota();
      return Right(quota);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    }
  }

  @override
  ResultFuture<UsageQuota> addUsage(int bytes) async {
    try {
      final quota = await _localDatasrc.getQuota();
      final updated = UsageQuotaModel.fromEntity(quota.withUsage(bytes));
      await _localDatasrc.saveQuota(updated);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    }
  }

  @override
  ResultFuture<UsageQuota> addRewardBonus() async {
    try {
      final quota = await _localDatasrc.getQuota();
      final updated = UsageQuotaModel.fromEntity(quota.withRewardBonus());
      await _localDatasrc.saveQuota(updated);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    }
  }
}
