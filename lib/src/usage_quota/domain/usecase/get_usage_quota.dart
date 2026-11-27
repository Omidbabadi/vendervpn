import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/quota_repository.dart';

class GetUsageQuota extends UsecaseWithOutParams<QuotaEntity> {
  const GetUsageQuota(this._repo);
  final QuotaRepository _repo;

  @override
  ResultFuture<QuotaEntity> call() => _repo.getQuota();
}
