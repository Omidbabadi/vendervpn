import 'package:installed_apps/installed_apps.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';

abstract class PerAppProxyDatasrc {
  Future<List<AppInfo>> getInstalledApp({
    required bool excludeSystemApps,
    required bool withIcon,
    required bool excludeNonLaunchableApps,
  });

  Future<void> updateSelectedApps({required List<String> apps});
  Future<List<String>> getSelectedApps();
}

class PerAppProxyDatasrcImpl implements PerAppProxyDatasrc {
  const PerAppProxyDatasrcImpl(this._cacheHelper);
  final CacheHelper _cacheHelper;

  @override
  Future<List<AppInfo>> getInstalledApp({
    required bool excludeSystemApps,
    required bool withIcon,
    required bool excludeNonLaunchableApps,
  }) async {
    return await InstalledApps.getInstalledApps(
      detectPlatformType: false,
      excludeNonLaunchableApps: excludeNonLaunchableApps,
      excludeSystemApps: excludeSystemApps,
      withIcon: withIcon,
    );
  }

  @override
  Future<List<String>> getSelectedApps() async {
    return _cacheHelper.perAppProxyApps;
  }

  @override
  Future<void> updateSelectedApps({required List<String> apps}) async {
    await _cacheHelper.cachePerAppProxyApps(apps);
  }
}
