import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/quota_repository.dart';

/// The last known quota, without a network call (for the first frame).
class GetCachedUsageQuota extends UsecaseWithOutParamsNotFuture<QuotaEntity> {
  const GetCachedUsageQuota(this._repo);
  final QuotaRepository _repo;

  @override
  QuotaEntity call() => _repo.cachedQuota();
}
