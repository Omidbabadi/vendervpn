import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/extensions/string_ext.dart';
import 'package:vendervpn/src/configs/presention/app/adapter/configs_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/home_view.dart';

import '../../../../core/common/app/cache_helper.dart';
import '../../../../core/common/singelton/unity_ads_core.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../connection/presention/adapter/connection_adapter.dart';
import '../../../info_screen/presention/views/status_screen.dart';
import '../../../info_screen/presention/views/utils/status_utils.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final adService = sl<UnityAdsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cache = sl<CacheHelper>();
      if (cache.vpnState == 'CONNECTED') {
        await adService.initialize();
        await Future.delayed(Duration(seconds: 3));
        final cachedConfigs = cache.configs;
        final configList =
            cachedConfigs.map((e) {
              final V2RayURL parser = FlutterV2ray.parseFromURL(
                e['uri'] as String,
              );
              final fullJson = parser.getFullConfiguration();
              final config = Config(
                configjson: fullJson,
                importedFrom: e['importedFrom'] as String,
                remark: e['remark'] as String,
                port: int.tryParse((e['port'] as String)) ?? 0,
                address: e['address'] as String,
                uri: e['uri'] as String,
                dateAdded: e['dateAdded'] as String,
                id: e['id'] as String,
                isSelected: (e['isSelected'] as String).stringToBool,
                country: e['country'] as String,
              );
              return config;
            }).toList();
        if (configList.isEmpty) {
          ref.read(configsAdapterProvider().notifier).getConfigs();
        }

        ref.read(currentConfigsListProvider.notifier).setConfigs(configList);
        if (mounted) {
          context.go(HomeView.path);
        }
      }
      ref.read(configsAdapterProvider().notifier).getConfigs();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(configsAdapterProvider(), (previous, next) async {
      if (next is ConfigsLoaded) {
        ref.read(connectionAdapterProvider().notifier).startConnection();
        await adService.initialize();
        await Future.delayed(Duration(seconds: 3));
        ref.read(connectionAdapterProvider().notifier).stopConnection();
        if (mounted) {
          context.go(HomeView.path);
        }
      }
      if (next is ConfigsError) {
        debugPrint(next.message);
        if (mounted) {
          context.go(
            StatusScreen.path,
            extra: StatusUtils(next.message, Status.error),
          );
        }
      }
    });
    return Scaffold(body: Center(child: const AppLogo()));
  }
}
