import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/usage_quota/domain/entities/usage_quota.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/usage_quota_repo.dart';

/// Adds [bytes] of traffic used on a cloud node to today's quota.
class AddCloudUsage extends UsecaseWithParams<UsageQuota, int> {
  const AddCloudUsage(this._repo);
  final UsageQuotaRepo _repo;

  @override
  ResultFuture<UsageQuota> call(int bytes) => _repo.addUsage(bytes);
}
