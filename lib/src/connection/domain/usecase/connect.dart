import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/connection/domain/repo/connection_repo.dart';

class Connect extends UsecaseWithParams<void, ConnectionsParams> {
  const Connect(this._repo);
  final ConnectionRepo _repo;

  @override
  ResultFuture<void> call(ConnectionsParams params) => _repo.connect(
    params.config,
    params.remark,
    params.proxyOnly,
    params.bypassSubnets,
    params.blockedApps,
  );
}

class ConnectionsParams {
  const ConnectionsParams({
    required this.config,
    required this.remark,
    required this.proxyOnly,
    required this.bypassSubnets,
    required this.blockedApps,
  });
  final String config;
  final String remark;
  final bool proxyOnly;
  final List<String>? bypassSubnets;
  final List<String>? blockedApps;
}
