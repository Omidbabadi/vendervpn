import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';

import '../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../core/res/styles/colors.dart';

import '../../../../core/widgets/bottom_appbar.dart';
import '../utils/dashboard_utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.state, required this.child});
  final GoRouterState state;
  final Widget child;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectionAdapterProvider(), (previous, next) {
      if (next is ConnectionStateConnected) {}
    });
    final currentTheme = ref.watch(currentThemeProvider);
    IconData _getThemeIcon() {
      return switch (currentTheme) {
        ThemeMode.light => Icons.dark_mode_outlined,
        ThemeMode.dark => Icons.auto_awesome_outlined,
        ThemeMode.system => Icons.light_mode_outlined,
      };
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton.filled(
            onPressed: () {
              ref.read(currentThemeProvider.notifier).toggleTheme(currentTheme);
            },
            icon: Icon(
              _getThemeIcon(),
              color: Colours.darkThemePrimaryTextColor,
            ),
          ),
        ],
        elevation: 0,
        centerTitle: true,
        title: const Text('VENDER VPN'),
        bottom: AppBarBottom(),
      ),
      key: DashboardUtils.scaffoldKey,
      body: widget.child,
    );
  }
}
