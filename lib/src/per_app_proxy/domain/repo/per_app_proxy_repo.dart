import 'package:vendervpn/core/common/entities/installed_app.dart';

import '../../../../core/utils/typedefs.dart';

abstract class PerAppProxyRepo {
  ResultFuture<List<InstalledApp>> getInstalledApps({
    required bool excludeSystemApps,
    required bool withIcon,
    required bool excludeNonLaunchableApps,
  });
  ResultFuture<void> updateSelectedApps({required List<String> apps});
  ResultFuture<List<String>> getSelectedApps();
}
