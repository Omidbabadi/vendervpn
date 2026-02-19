import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../repo/connection_repo.dart';

class Ping extends UsecaseWithParams<int, String> {
  const Ping(this._repo);
  final ConnectionRepo _repo;

  @override
  ResultFuture<int> call(String params) => _repo.ping(params);
}
