import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

import '../repo/ip_repo.dart';

class GetUserCountry extends UsecaseWithParams<String,String> {
  const GetUserCountry(this._repo);
  final IpRepo _repo;
  @override
  ResultFuture<String> call(String ip) => _repo.ipToCountry(ip);
}
