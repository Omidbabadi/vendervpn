import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/src/configs/presention/app/adapter/configs_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/home_view.dart';

import '../../../../core/widgets/app_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('#debug 1: initState: getting prices');
      ref.read(configsAdapterProvider().notifier).getConfigs();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(configsAdapterProvider(), (previous, next) {
      debugPrint(next.runtimeType.toString());
      if (next is ConfigsLoaded) {
        debugPrint('configsLoaded');
        context.go(HomeView.path);
      }
      if (next is ConfigsError) {
        debugPrint('error');
      }
    });
    return Scaffold(body: const AppLogo());
  }
}
