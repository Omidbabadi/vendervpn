import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

/// Sends cloud usage that hasn't been reported to the server yet.
class FlushCloudUsage extends UsecaseWithOutParams<UsageQuota> {
  const FlushCloudUsage(this._repo);
  final UsageQuotaRepo _repo;

  @override
  ResultFuture<UsageQuota> call() => _repo.flushUsage();
}
