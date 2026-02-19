import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

class InitializeV2ay extends UsecaseWithOutParams<void> {
  const InitializeV2ay(this._repo);

  final ConnectionRepo _repo;
  @override
  ResultFuture<void> call() => _repo.initialize();
}
