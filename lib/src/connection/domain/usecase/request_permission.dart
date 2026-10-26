import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

class RequestPermission extends UsecaseWithOutParams {
  const RequestPermission(this._repo);

  final ConnectionRepo _repo;
  @override
  ResultFuture<bool> call() => _repo.requestPermission();
}
