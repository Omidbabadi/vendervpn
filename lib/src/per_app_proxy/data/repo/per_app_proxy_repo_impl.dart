import 'package:dartz/dartz.dart';
import 'package:installed_apps/app_info.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/src/per_app_proxy/data/datasrs/per_app_proxy_datasrc.dart';

import '../../../../core/utils/typedefs.dart';
import '../../domain/repo/per_app_proxy_repo.dart';

class PerAppProxyRepoImpl implements PerAppProxyRepo {
  const PerAppProxyRepoImpl(this._datasrc);
  final PerAppProxyDatasrc _datasrc;

  @override
  ResultFuture<List<String>> getSelectedApps() async {
    try {
      final apps = await _datasrc.getSelectedApps();
      return Right(apps);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> updateSelectedApps({required List<String> apps}) async {
    try {
      await _datasrc.updateSelectedApps(apps: apps);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<AppInfo>> getInstalledApps({
    required bool excludeSystemApps,
    required bool withIcon,
    required bool excludeNonLaunchableApps,
  }) async {
    try {
      final apps = await _datasrc.getInstalledApp(
        excludeSystemApps: excludeSystemApps,
        withIcon: withIcon,
        excludeNonLaunchableApps: excludeNonLaunchableApps,
      );
      return Right(apps);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
