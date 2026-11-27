import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/src/configs/domain/usecases/get_cached_configs.dart';
import 'package:vendervpn/src/configs/presention/app/adapter/configs_adapter.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/home_view.dart';
import '../../../../core/common/app/cache_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../info_screen/presention/views/status_screen.dart';
import '../../../info_screen/presention/views/utils/status_utils.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cache = sl<CacheHelper>();
      final vpnState = cache.vpnState;
      // Ensure local configs are initialized on startup
      final localConfigs = ref.read(localConfigsListProvider);
      final tunnelUp = vpnState == 'CONNECTED' && await _isTunnelStillUp();
      if (!mounted) return;
      if (tunnelUp) {
        Cache.instance.setVpnDisconnected(false);
        final cached = await sl<GetCachedConfigs>()();
        if (!mounted) return;
        final configList = cached.fold(
          (_) => const <Config>[],
          (configs) => configs,
        );

        final allConfigs = [...configList, ...localConfigs];
        if (allConfigs.isEmpty) {
          ref.read(configsAdapterProvider.notifier).getConfigs();
          return;
        }

        if (configList.isNotEmpty) {
          ref.read(currentConfigsListProvider.notifier).setConfigs(configList);
        }
        final selected = allConfigs.firstWhere(
          (c) => c.id == cache.id,
          orElse: () => allConfigs.first,
        );
        ref.read(currentConfigProvider.notifier).setCurrentConfig(selected);
        ref
            .read(connectionAdapterProvider.notifier)
            .restoreConnectedState(selected);

        if (mounted) {
          context.go(HomeView.path);
          return;
        }
      }
      if (Platform.isAndroid) {
        ref.read(configsAdapterProvider.notifier).getConfigs();
      } else {
        context.go(HomeView.path);
      }
    });
  }

  /// The saved flag says connected; ask the plugin whether the tunnel really
  /// still runs. If it stopped while the app was closed (traffic limit,
  /// notification button, the OS), settle that session and start fresh.
  Future<bool> _isTunnelStillUp() async {
    final connection = ref.read(connectionAdapterProvider.notifier);
    final service = await connection.serviceState();
    if (service == null) return true; // can't tell: keep the old behaviour
    if (service.isRunning) return true;
    await connection.settleStoppedSession(service);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currentThemeProvider);
    ref.listen(configsAdapterProvider, (previous, next) async {
      if (!mounted) return;
      if (next is ConfigsLoaded) {
        context.go(HomeView.path);
      }
      if (next is ConfigsError) {
        context.go(
          StatusScreen.path,
          extra: StatusUtils(next.message, Status.configsError),
        );
      }
    });
    return Scaffold(
      backgroundColor: Colours.scaffoldBg(context),
      body: const Center(child: AppLogo(size: 165)),
    );
  }
}
