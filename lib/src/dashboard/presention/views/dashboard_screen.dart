import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vendervpn/core/common/app/riverpod/banner_ad.dart';
import 'package:vendervpn/src/admob/presention/app/adapter/admob_adapter.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/dashboard/presention/widgets/custom_bottom_nav_bar.dart';
import 'package:vendervpn/src/home/presentation/views/home_view.dart';
import 'package:vendervpn/src/info_screen/presention/views/utils/status_utils.dart';
import 'package:vendervpn/src/nodes/presentation/views/nodes_view.dart';
import 'package:vendervpn/src/settings/presentation/views/settings_view.dart';

import '../../../../core/common/app/riverpod/theme/current_theme.dart';
import '../../../../core/res/styles/colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../info_screen/presention/views/status_screen.dart';
import '../utils/dashboard_utils.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.state, required this.child});
  final GoRouterState state;
  final Widget child;

  IconData _getThemeIcon(ThemeMode theme) {
    return switch (theme) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.auto_awesome_rounded,
    };
  }

  int _activeIndex(String location) {
    if (location.startsWith(NodesView.path)) return 1;
    if (location.startsWith(SettingsView.path)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    final connectionState = ref.watch(connectionAdapterProvider);
    final isConnected = connectionState is ConnectionStateConnected;
    final location = state.uri.path;
    final currentIndex = _activeIndex(location);
    final scaffoldBg = Colours.scaffoldBg(context);
    final surfaceColor = Colours.cardSurface(context);
    final textColor = Colours.classicAdabtiveTextColor(context);

    ref.listen(connectionAdapterProvider, (p, next) {
      if (next is ConnectionStateConnecting) {
        context.go(
          StatusScreen.path,
          extra: StatusUtils(
            AppLocalizations.of(context)!.connecting,
            Status.connecting,
          ),
        );
      } else if (next is ConnectionStateConnected) {
        // Only initialize & load Banner Ad AFTER V2Ray TUN has started and connected!
        final width = MediaQuery.sizeOf(context).width;
        ref.read(admobAdapterProvider.notifier).showBannerAd(width);
      } else if (next is ConnectionStateDisconnected) {
        ref.read(loadedBannerAdProvider.notifier).clearBannerAd();
      }
    });

    return Scaffold(
      key: DashboardUtils.scaffoldKey,
      backgroundColor: scaffoldBg,
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ─── Top Minimalist Header (Matches Reference Image 1) ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top-left circular status/shield button with notification dot
                      GestureDetector(
                        onTap: () {
                          context.go(
                            StatusScreen.path,
                            extra: StatusUtils(
                              isConnected
                                  ? AppLocalizations.of(context)!.succesful
                                  : AppLocalizations.of(context)!.idle,
                              isConnected ? Status.success : Status.idle,
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colours.subtleBorder(context),
                                ),
                                boxShadow: Colours.softCardShadow(context),
                              ),
                              child: Icon(
                                Icons.shield_outlined,
                                size: 19,
                                color: textColor.withValues(alpha: 0.8),
                              ),
                            ),
                            Positioned(
                              top: 1,
                              right: 1,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color:
                                      isConnected
                                          ? Colours.orbEmerald
                                          : Colours.orbCoral,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: surfaceColor,
                                    width: 1.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Top-right circular theme toggle button (like Reference Image 1 top-right icon)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(currentThemeProvider.notifier)
                              .toggleTheme(currentTheme);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colours.subtleBorder(context),
                            ),
                            boxShadow: Colours.softCardShadow(context),
                          ),
                          child: Icon(
                            _getThemeIcon(currentTheme),
                            size: 19,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(child: child),
              ],
            ),
          ),

          // ─── Custom Floating 3-Tab Bottom Navigation Bar ("Home, Nodes, Setting") ───
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: CustomBottomNavBar(
              currentIndex: currentIndex,
              onSelect: (idx) {
                HapticFeedback.selectionClick();
                switch (idx) {
                  case 0:
                    context.go(HomeView.path);
                  case 1:
                    context.go(NodesView.path);
                  case 2:
                    context.go(SettingsView.path);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
