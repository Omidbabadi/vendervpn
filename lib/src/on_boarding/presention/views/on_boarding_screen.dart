import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/src/configs/presention/app/adapter/configs_adapter.dart';

import '../on_boarding_screen_info.dart';

class OnBoardingScreen extends ConsumerWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(configsAdapterProvider());
    return const OnBoardingScreenInfo();
  }
}
