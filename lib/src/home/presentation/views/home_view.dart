import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/configs_list.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/world_map.dart';


import 'widgets/connection_button.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  static const path = '/home';

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {

    ref.watch(currentThemeProvider);
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(top: 30, left: 0, right: 0, child: const WorldMap()),
              Positioned(
                left: 0,
                right: 0,
                top: context.height / 10,
                child: ConnectionButton(),
              ),
              ConfigsList(),
            ],
          ),
        ),
      ],
    );
  }
}
