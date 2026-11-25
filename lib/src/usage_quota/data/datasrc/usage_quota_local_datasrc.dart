import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_quota_model.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';

/// Stores the cloud usage quota on the device.
/// (Later this can move to a server datasrc without touching the domain.)
abstract class UsageQuotaLocalDatasrc {
  const UsageQuotaLocalDatasrc();

  Future<UsageQuotaModel> getQuota();
  Future<void> saveQuota(UsageQuotaModel quota);
}

class UsageQuotaLocalDatasrcImpl implements UsageQuotaLocalDatasrc {
  const UsageQuotaLocalDatasrcImpl(this._cacheHelper);
  final CacheHelper _cacheHelper;

  @override
  Future<UsageQuotaModel> getQuota() async {
    try {
      final today = UsageQuota.dayOf(DateTime.now());
      final cached = _cacheHelper.cloudUsageQuota;
      if (cached == null) return UsageQuotaModel.empty(today);

      final quota = UsageQuotaModel.fromMap(cached);
      // A new day starts a fresh allowance; yesterday's bonus expires too.
      if (quota.day != today) return UsageQuotaModel.empty(today);
      return quota;
    } catch (e) {
      throw CacheException(message: 'Reading cloud usage failed: $e');
    }
  }

  @override
  Future<void> saveQuota(UsageQuotaModel quota) async {
    try {
      await _cacheHelper.cacheCloudUsageQuota(quota.toMap());
    } catch (e) {
      throw CacheException(message: 'Saving cloud usage failed: $e');
    }
  }
}
