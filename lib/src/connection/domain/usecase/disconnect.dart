import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

class Disconnect extends UsecaseWithOutParamsNotFuture<void> {
  const Disconnect(this._repo);
  final ConnectionRepo _repo;

  @override
  void call() => _repo.disconnect();
}
