import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/core/common/entities/quota_entity.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/quota_repository.dart';

/// Sends cloud usage that hasn't been reported to the server yet.
class FlushCloudUsage extends UsecaseWithOutParams<QuotaEntity> {
  const FlushCloudUsage(this._repo);
  final QuotaRepository _repo;

  @override
  ResultFuture<QuotaEntity> call() => _repo.flushUsage();
}
