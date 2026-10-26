import 'dart:convert';
import 'dart:io';

import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/src/ip/domain/entities/ip_info.dart';

abstract class IpRemoteDatasrc {
  const IpRemoteDatasrc();
  Future<String> ipToCountry([String? ip]);
  Future<IpInfo> fetchIpInfo({
    String? targetHostOrIp,
    int? localHttpProxyPort,
    bool isTunnel = false,
  });
}

class IpRemoteDatasrcImpl implements IpRemoteDatasrc {
  const IpRemoteDatasrcImpl();

  @override
  Future<String> ipToCountry([String? ip]) async {
    final info = await fetchIpInfo(targetHostOrIp: ip);
    return info.countryCode;
  }

  @override
  Future<IpInfo> fetchIpInfo({
    String? targetHostOrIp,
    int? localHttpProxyPort,
    bool isTunnel = false,
  }) async {
    // When querying current client/tunnel exit IP (targetHostOrIp == null):
    // Note: On Android, `V2rayVPNService` calls `builder.addDisallowedApplication(getPackageName())`,
    // which excludes the VPN app's own direct sockets from the TUN interface.
    // Therefore, when `isTunnel` is true, we MUST route through the local V2Ray HTTP proxy
    // inbound (`127.0.0.1:localHttpProxyPort`) so the lookup exits through the V2Ray server
    // instead of the user's real ISP interface.
    if (targetHostOrIp == null || targetHostOrIp.trim().isEmpty) {
      if (isTunnel && localHttpProxyPort != null && localHttpProxyPort > 0) {
        return _queryCurrentExitIp(
          proxyPort: localHttpProxyPort,
          isTunnel: true,
        );
      }
      return _queryCurrentExitIp(
        proxyPort: null,
        isTunnel: isTunnel,
      );
    }

    // When resolving a specific host or IP:
    String resolvedIp = targetHostOrIp.trim();
    if (InternetAddress.tryParse(resolvedIp) == null) {
      try {
        final addrs = await InternetAddress.lookup(
          resolvedIp,
        ).timeout(const Duration(seconds: 4));
        if (addrs.isNotEmpty) {
          resolvedIp = addrs.first.address;
        }
      } catch (_) {}
    }

    return _queryIpWhoIs(
      ipOrNull: resolvedIp,
      proxyPort: null,
      isTunnel: isTunnel,
    );
  }

  Future<IpInfo> _queryCurrentExitIp({
    required int? proxyPort,
    required bool isTunnel,
  }) async {
    try {
      return await _queryIpWhoIs(
        ipOrNull: null,
        proxyPort: proxyPort,
        isTunnel: isTunnel,
      );
    } catch (_) {
      return _queryIpApiFallback(
        proxyPort: proxyPort,
        isTunnel: isTunnel,
      );
    }
  }

  Future<IpInfo> _queryIpWhoIs({
    required String? ipOrNull,
    required int? proxyPort,
    required bool isTunnel,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);
    if (proxyPort != null && proxyPort > 0) {
      client.findProxy = (uri) => 'PROXY 127.0.0.1:$proxyPort';
    }

    try {
      final path =
          (ipOrNull != null && ipOrNull.isNotEmpty) ? '/$ipOrNull' : '/';
      final uri = Uri.parse('https://ipwho.is$path');
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to detect IP location',
          statusCode: response.statusCode,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['success'] == false) {
        throw ServerException(
          message: (data['message'] as String?) ?? 'IP lookup failed',
          statusCode: 400,
        );
      }

      final ip = (data['ip'] as String?) ?? '';
      if (ip.isEmpty) {
        throw const ServerException(
          message: 'Empty IP in response',
          statusCode: 500,
        );
      }
      final countryCode =
          ((data['country_code'] as String?) ??
                  (data['countryCode'] as String?) ??
                  'US')
              .toUpperCase();
      final countryName = (data['country'] as String?) ?? countryCode;
      final city = (data['city'] as String?) ?? '';

      return IpInfo(
        ip: ip,
        countryCode: countryCode,
        countryName: countryName,
        city: city,
        isTunnel: isTunnel,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    } finally {
      client.close();
    }
  }

  Future<IpInfo> _queryIpApiFallback({
    required int? proxyPort,
    required bool isTunnel,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);
    if (proxyPort != null && proxyPort > 0) {
      client.findProxy = (uri) => 'PROXY 127.0.0.1:$proxyPort';
    }

    try {
      final uri = Uri.parse('http://ip-api.com/json/');
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Fallback IP lookup failed',
          statusCode: response.statusCode,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['status'] != 'success') {
        throw const ServerException(
          message: 'Fallback IP lookup unsuccessful',
          statusCode: 400,
        );
      }

      final ip = (data['query'] as String?) ?? '';
      final countryCode =
          ((data['countryCode'] as String?) ?? 'US').toUpperCase();
      final countryName = (data['country'] as String?) ?? countryCode;
      final city = (data['city'] as String?) ?? '';

      return IpInfo(
        ip: ip,
        countryCode: countryCode,
        countryName: countryName,
        city: city,
        isTunnel: isTunnel,
      );
    } finally {
      client.close();
    }
  }
}
