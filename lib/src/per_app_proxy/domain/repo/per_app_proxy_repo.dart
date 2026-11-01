import 'package:installed_apps/installed_apps.dart';

import '../../../../core/utils/typedefs.dart';

abstract class PerAppProxyRepo {
  ResultFuture<List<AppInfo>> getInstalledApps({
    required bool excludeSystemApps,
    required bool withIcon,
    required bool excludeNonLaunchableApps,
  });
  ResultFuture<void> updateSelectedApps({required List<String> apps});
  ResultFuture<List<String>> getSelectedApps();
}
