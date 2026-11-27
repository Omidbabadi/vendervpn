import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_outbox.dart';
import 'package:vendervpn/src/usage_quota/data/models/usage_quota_model.dart';
import 'package:vendervpn/core/utils/app_log.dart';

/// On-device state for the cloud quota: the last server snapshot (so the UI
/// can render at once) and the usage not yet reported to the server.
abstract class UsageQuotaLocalDatasrc {
  const UsageQuotaLocalDatasrc();

  UsageQuotaModel? get snapshot;
  Future<void> saveSnapshot(UsageQuotaModel quota);

  UsageOutbox get outbox;
  Future<void> saveOutbox(UsageOutbox outbox);
}

class UsageQuotaLocalDatasrcImpl implements UsageQuotaLocalDatasrc {
  const UsageQuotaLocalDatasrcImpl(this._cacheHelper);
  final CacheHelper _cacheHelper;

  @override
  UsageQuotaModel? get snapshot {
    try {
      final map = _cacheHelper.cloudQuotaSnapshot;
      return map == null ? null : UsageQuotaModel.fromMap(map);
    } catch (e) {
      // A corrupt snapshot is only a cache; the server has the real numbers.
      appLog('Ignoring cached quota snapshot: $e');
      return null;
    }
  }

  @override
  Future<void> saveSnapshot(UsageQuotaModel quota) async {
    try {
      await _cacheHelper.cacheCloudQuotaSnapshot(quota.toMap());
    } catch (e) {
      throw CacheException(message: 'Saving quota snapshot failed: $e');
    }
  }

  @override
  UsageOutbox get outbox {
    try {
      final map = _cacheHelper.cloudUsageOutbox;
      return map == null ? const UsageOutbox() : UsageOutbox.fromMap(map);
    } catch (e) {
      appLog('Ignoring unreadable usage outbox: $e');
      return const UsageOutbox();
    }
  }

  @override
  Future<void> saveOutbox(UsageOutbox outbox) async {
    try {
      await _cacheHelper.cacheCloudUsageOutbox(outbox.toMap());
    } catch (e) {
      throw CacheException(message: 'Saving unreported usage failed: $e');
    }
  }
}
