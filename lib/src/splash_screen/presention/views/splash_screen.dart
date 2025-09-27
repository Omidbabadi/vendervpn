import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/src/configs/presention/app/adapter/configs_adapter.dart';

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
      if (next is ConfigsLoaded) {
        debugPrint('configsLoaded');
      }
      if (next is ConfigsError) {}
    });
    return Scaffold();
  }
}
