import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/configs_list.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/world_map.dart';

import 'widgets/connection_button.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});
  static const path = '/home';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    print('Home View Theme Is: $theme');
    return Stack(
      children: [
        Positioned(top: 10, left: 0, right: 0, child: const WorldMap()),
        Positioned(
          left: 0,
          right: 0,
          top: context.height / 10,
          child: ConnectionButton(),
        ),
        ConfigsList(),
      ],
    );
  }
}
