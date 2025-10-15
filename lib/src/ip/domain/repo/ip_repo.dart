import 'package:vendervpn/core/utils/typedefs.dart';

abstract class IpRepo {
  const IpRepo();

  ResultFuture<String> ipToCountry(String ip);
  
}
