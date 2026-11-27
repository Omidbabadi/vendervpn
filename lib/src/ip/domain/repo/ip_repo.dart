import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/ip/domain/entities/ip_info.dart';

abstract class IpRepo {
  const IpRepo();

  ResultFuture<String> ipToCountry([String? ip]);

  /// Looks up the current public IP. When [isTunnel] is true the request goes
  /// through the local HTTP proxy inbound on [localHttpProxyPort], so it exits
  /// through the active tunnel.
  ResultFuture<IpInfo> fetchIpInfo({
    int? localHttpProxyPort,
    bool isTunnel = false,
  });
}
