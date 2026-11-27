import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

/// The last known quota, without a network call (for the first frame).
class GetCachedUsageQuota extends UsecaseWithOutParamsNotFuture<UsageQuota> {
  const GetCachedUsageQuota(this._repo);
  final UsageQuotaRepo _repo;

  @override
  UsageQuota call() => _repo.cachedQuota();
}
