import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

/// Asks the server for the rewarded-ad bonus (amount set by BONUS_BYTES).
class AddRewardBonus extends UsecaseWithOutParams<UsageQuota> {
  const AddRewardBonus(this._repo);
  final UsageQuotaRepo _repo;

  @override
  ResultFuture<UsageQuota> call() => _repo.addRewardBonus();
}
