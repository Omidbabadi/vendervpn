import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/quota_repository.dart';

/// Adds [bytes] of traffic used on a cloud node to today's quota.
class AddCloudUsage extends UsecaseWithParams<QuotaEntity, int> {
  const AddCloudUsage(this._repo);
  final QuotaRepository _repo;

  @override
  ResultFuture<QuotaEntity> call(int bytes) => _repo.addUsage(bytes);
}
