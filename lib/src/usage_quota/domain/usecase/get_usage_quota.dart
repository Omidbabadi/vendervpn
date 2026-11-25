import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

class GetUsageQuota extends UsecaseWithOutParams<UsageQuota> {
  const GetUsageQuota(this._repo);
  final UsageQuotaRepo _repo;

  @override
  ResultFuture<UsageQuota> call() => _repo.getQuota();
}
