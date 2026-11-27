import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/ip/domain/entities/ip_info.dart';
import 'package:vendervpn/src/ip/domain/repo/ip_repo.dart';

class GetIpInfo extends UsecaseWithParams<IpInfo, GetIpInfoParams> {
  const GetIpInfo(this._repo);
  final IpRepo _repo;

  @override
  ResultFuture<IpInfo> call(GetIpInfoParams params) => _repo.fetchIpInfo(
    localHttpProxyPort: params.localHttpProxyPort,
    isTunnel: params.isTunnel,
  );
}

class GetIpInfoParams {
  const GetIpInfoParams({this.localHttpProxyPort, this.isTunnel = false});

  /// Lookup of the user's real IP, outside the tunnel.
  const GetIpInfoParams.direct() : localHttpProxyPort = null, isTunnel = false;

  final int? localHttpProxyPort;
  final bool isTunnel;
}
