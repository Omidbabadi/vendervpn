import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';

abstract class UsageQuotaRepo {
  const UsageQuotaRepo();

  ResultFuture<UsageQuota> getQuota();
  ResultFuture<UsageQuota> addUsage(int bytes);
  ResultFuture<UsageQuota> addRewardBonus();
}
