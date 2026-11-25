import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

/// Adds the rewarded-ad bonus (1 GB) to today's quota.
class AddRewardBonus extends UsecaseWithOutParams<UsageQuota> {
  const AddRewardBonus(this._repo);
  final UsageQuotaRepo _repo;

  @override
  ResultFuture<UsageQuota> call() => _repo.addRewardBonus();
}
