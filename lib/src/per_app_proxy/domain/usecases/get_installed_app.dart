import 'package:installed_apps/app_info.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/src/per_app_proxy/domain/repo/per_app_proxy_repo.dart';

import '../../../../core/utils/typedefs.dart';

class GetInstalledApp
    extends UsecaseWithParams<List<AppInfo>, GetInstalledAppParams> {
  const GetInstalledApp(this._repo);
  final PerAppProxyRepo _repo;
  @override
  ResultFuture<List<AppInfo>> call(GetInstalledAppParams params) =>
      _repo.getInstalledApps(
        excludeSystemApps: params.excludeSystemApps,
        withIcon: params.withIcon,
        excludeNonLaunchableApps: params.excludeNonLaunchableApps,
      );
}

class GetInstalledAppParams {
  final bool excludeSystemApps;
  final bool withIcon;
  final bool excludeNonLaunchableApps;

  const GetInstalledAppParams({
    this.excludeSystemApps = false,
    this.withIcon = false,
    this.excludeNonLaunchableApps = false,
  });
}
