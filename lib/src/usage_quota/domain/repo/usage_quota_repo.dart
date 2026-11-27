import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';

abstract class UsageQuotaRepo {
  const UsageQuotaRepo();

  /// Last known quota (cached snapshot plus unreported usage), no network.
  UsageQuota cachedQuota();

  /// Sends unreported usage, then loads today's quota from the server.
  ResultFuture<UsageQuota> getQuota();

  /// Counts [bytes] locally. It's sent to the server by [flushUsage].
  ResultFuture<UsageQuota> addUsage(int bytes);

  /// Sends unreported usage to the server now.
  ResultFuture<UsageQuota> flushUsage();

  ResultFuture<UsageQuota> addRewardBonus();
}
