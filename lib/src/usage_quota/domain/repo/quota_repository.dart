import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';

abstract class QuotaRepository {
  const QuotaRepository();

  /// Last known quota (cached snapshot plus unreported usage), no network.
  QuotaEntity cachedQuota();

  /// Sends unreported usage, then loads today's quota from the server.
  ResultFuture<QuotaEntity> getQuota();

  /// Counts [bytes] locally. It's sent to the server by [flushUsage].
  ResultFuture<QuotaEntity> addUsage(int bytes);

  /// Sends unreported usage to the server now.
  ResultFuture<QuotaEntity> flushUsage();

  ResultFuture<QuotaEntity> addRewardBonus();
}
