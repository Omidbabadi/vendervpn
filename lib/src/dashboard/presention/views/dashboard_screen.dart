import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import '../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../core/res/styles/colors.dart';
import '../../../../core/widgets/bottom_appbar.dart';
import '../../../admob/presention/app/adapter/admob_adapter.dart';
import '../utils/dashboard_utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.state, required this.child});
  final GoRouterState state;
  final Widget child;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  IconData _getThemeIcon() {
    final theme = ref.watch(currentThemeProvider);
    return switch (theme) {
      ThemeMode.light => Icons.dark_mode_outlined,
      ThemeMode.dark => Icons.auto_awesome_outlined,
      ThemeMode.system => Icons.light_mode_outlined,
    };
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(currentThemeProvider);
    ref.listen(connectionAdapterProvider(), (p, n) {
      if (n is ConnectionStateConnected) {
                ref.read(admobAdapterProvider.notifier).showBannerAd(context.width);

        CoreUtils.showSnackBar(
          context,
          false,
          title: 'VPN Status',
          message: 'VPN Connected',
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton.filled(
            color: Colours.connectedColor,
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
