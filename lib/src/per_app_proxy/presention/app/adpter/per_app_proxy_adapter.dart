import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:vendervpn/core/common/app/cache_helper.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/per_app_proxy/domain/repo/per_app_proxy_repo.dart';
import 'package:vendervpn/src/per_app_proxy/domain/usecases/get_installed_app.dart';

enum PerAppProxyMode {
  /// Tunnel ONLY the selected apps (all other installed apps are disallowed).
  perApp('per_app'),

  /// Selected apps bypass the VPN tunnel (selected apps are disallowed).
  bypass('bypass');

  const PerAppProxyMode(this.storageKey);
  final String storageKey;

  static PerAppProxyMode fromStorage(String? value) {
    return value == 'bypass' ? PerAppProxyMode.bypass : PerAppProxyMode.perApp;
  }
}

class PerAppProxyState {
  const PerAppProxyState({
    required this.isEnabled,
    required this.mode,
    required this.selectedPackages,
    this.proxyOnly = false,
    this.userApps = const <AppInfo>[],
    this.allApps = const <AppInfo>[],
    this.isLoadingApps = false,
    this.showSystemApps = false,
    this.searchQuery = '',
  });

  final bool isEnabled;
  final PerAppProxyMode mode;
  final Set<String> selectedPackages;
  final bool proxyOnly;
  final List<AppInfo> userApps;
  final List<AppInfo> allApps;
  final bool isLoadingApps;
  final bool showSystemApps;
  final String searchQuery;

  List<AppInfo> get filteredApps {
    final source =
        showSystemApps && allApps.isNotEmpty ? allApps : userApps;
    final query = searchQuery.trim().toLowerCase();

    final filtered =
        source.where((app) {
          if (app.packageName == 'com.vender.vendervpn') return false;
          if (!showSystemApps && app.isSystemApp) return false;
          if (query.isEmpty) return true;
          return app.name.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query);
        }).toList();

    // Sort selected apps first, then alphabetically by display name
    filtered.sort((a, b) {
      final aSelected = selectedPackages.contains(a.packageName);
      final bSelected = selectedPackages.contains(b.packageName);
      if (aSelected != bSelected) {
        return aSelected ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }

  PerAppProxyState copyWith({
    bool? isEnabled,
    PerAppProxyMode? mode,
    Set<String>? selectedPackages,
    bool? proxyOnly,
    List<AppInfo>? userApps,
    List<AppInfo>? allApps,
    bool? isLoadingApps,
    bool? showSystemApps,
    String? searchQuery,
  }) {
    return PerAppProxyState(
      isEnabled: isEnabled ?? this.isEnabled,
      mode: mode ?? this.mode,
      selectedPackages: selectedPackages ?? this.selectedPackages,
      proxyOnly: proxyOnly ?? this.proxyOnly,
      userApps: userApps ?? this.userApps,
      allApps: allApps ?? this.allApps,
      isLoadingApps: isLoadingApps ?? this.isLoadingApps,
      showSystemApps: showSystemApps ?? this.showSystemApps,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final perAppProxyProvider =
    NotifierProvider<PerAppProxyAdapter, PerAppProxyState>(
      PerAppProxyAdapter.new,
    );

class PerAppProxyAdapter extends Notifier<PerAppProxyState> {
  static const String _selfPackage = 'com.vender.vendervpn';

  late final CacheHelper _cacheHelper;
  late final GetInstalledApp _getInstalledApp;
  late final PerAppProxyRepo _repo;

  @override
  PerAppProxyState build() {
    _cacheHelper = sl<CacheHelper>();
    _getInstalledApp = sl<GetInstalledApp>();
    _repo = sl<PerAppProxyRepo>();

    return PerAppProxyState(
      isEnabled: _cacheHelper.perAppProxyEnabled,
      mode: PerAppProxyMode.fromStorage(_cacheHelper.perAppProxyMode),
      selectedPackages: _cacheHelper.perAppProxyApps.toSet(),
      proxyOnly: _cacheHelper.proxyOnlyMode,
    );
  }

  Future<void> setProxyOnly(bool proxyOnly) async {
    state = state.copyWith(proxyOnly: proxyOnly);
    await _cacheHelper.cacheProxyOnlyMode(proxyOnly);
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
    await _cacheHelper.cachePerAppProxyEnabled(enabled);
  }

  Future<void> setMode(PerAppProxyMode mode) async {
    state = state.copyWith(mode: mode);
    await _cacheHelper.cachePerAppProxyMode(mode.storageKey);
  }

  Future<void> toggleApp(String packageName) async {
    if (packageName == _selfPackage) return;
    final updated = {...state.selectedPackages};
    if (updated.contains(packageName)) {
      updated.remove(packageName);
    } else {
      updated.add(packageName);
    }
    state = state.copyWith(selectedPackages: updated);
    await _repo.updateSelectedApps(apps: updated.toList());
  }

  Future<void> clearSelectedApps() async {
    state = state.copyWith(selectedPackages: const <String>{});
    await _repo.updateSelectedApps(apps: const <String>[]);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> setShowSystemApps(bool showSystem) async {
    state = state.copyWith(showSystemApps: showSystem);
    if (showSystem && state.allApps.isEmpty) {
      await loadInstalledApps(includeSystem: true);
    }
  }

  Future<void> loadInstalledApps({
    bool includeSystem = false,
    bool forceRefresh = false,
  }) async {
    if (state.isLoadingApps) return;
    if (!forceRefresh) {
      if (includeSystem && state.allApps.isNotEmpty) return;
      if (!includeSystem && state.userApps.isNotEmpty) return;
    }

    state = state.copyWith(isLoadingApps: true);
    try {
      final result = await _getInstalledApp(
        GetInstalledAppParams(
          excludeSystemApps: !includeSystem,
          withIcon: true,
          excludeNonLaunchableApps: true,
        ),
      );
      result.fold(
        (failure) {
          debugPrint('Failed to load installed apps: ${failure.message}');
        },
        (apps) {
          final cleaned =
              apps.where((a) => a.packageName != _selfPackage).toList();
          if (includeSystem) {
            state = state.copyWith(allApps: cleaned);
          } else {
            state = state.copyWith(userApps: cleaned);
          }
        },
      );
    } finally {
      state = state.copyWith(isLoadingApps: false);
    }
  }

  /// Computes the list of `blockedApps` (disallowed package names) to pass to
  /// Android `VpnService.Builder.addDisallowedApplication`:
  /// - When disabled or `selectedPackages` is empty: returns `[]` (all apps use VPN).
  /// - In [PerAppProxyMode.bypass]: returns `selectedPackages` so selected apps bypass VPN.
  /// - In [PerAppProxyMode.perApp]: returns all installed packages EXCEPT `selectedPackages`
  ///   so ONLY selected apps route through the VPN tunnel.
  Future<List<String>> resolveBlockedAppsForVpn() async {
    final current = state;
    if (!current.isEnabled || current.selectedPackages.isEmpty) {
      return const <String>[];
    }

    if (current.mode == PerAppProxyMode.bypass) {
      return current.selectedPackages.toList();
    }

    // Per-App Proxy mode: disallow every installed package except the selected ones.
    try {
      final allInstalled = await InstalledApps.getInstalledApps(
        detectPlatformType: false,
        excludeSystemApps: false,
        withIcon: false,
        excludeNonLaunchableApps: false,
      );
      final blocked = <String>[];
      for (final app in allInstalled) {
        final pkg = app.packageName.trim();
        if (pkg.isEmpty) continue;
        if (!current.selectedPackages.contains(pkg)) {
          blocked.add(pkg);
        }
      }
      return blocked;
    } catch (e) {
      debugPrint('Failed to resolve per-app proxy package list: $e');
      return const <String>[];
    }
  }
}
