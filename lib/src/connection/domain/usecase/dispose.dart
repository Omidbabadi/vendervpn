import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

import '../../../../core/usecase/usecase.dart';

class Dispose extends UsecaseWithOutParamsNotFuture<void> {
  const Dispose(this._repo);
  final ConnectionRepo _repo;

  @override
  void call() => _repo.dispose();
}
