import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/common/app/riverpod/banner_ad.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/local_configs_list.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/widgets/dot_matrix_text.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:vendervpn/src/home/presentation/views/widgets/connection_status.dart';

import 'widgets/connection_button.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});
  static const path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    final selectedConfig = ref.watch(currentConfigProvider);
    final cloudConfigs = ref.watch(currentConfigsListProvider);
    final localConfigs = ref.watch(localConfigsListProvider);
    final bannerAd = ref.watch(loadedBannerAdProvider);
    final connectionState = ref.watch(connectionAdapterProvider);
    final statusNotifier = ref.watch(connectionAdapterProvider.notifier).status;

    final textColor = Colours.classicAdabtiveTextColor(context);
    final surfaceColor = Colours.cardSurface(context);
    final totalNodes = cloudConfigs.length + localConfigs.length;
    final isConnected = connectionState is ConnectionStateConnected;

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: statusNotifier,
      builder: (context, status, _) {
        final ping = selectedConfig?.ping ?? -1;
        final heroValue =
            isConnected
                ? status.duration
                : (ping > 0
                    ? '$ping'
                    : totalNodes.toString().padLeft(3, '0'));

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── 1. TOP SCORE / SESSION HEADER ───
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isConnected
                              ? Colours.orbEmerald
                              : Colours.orbViolet.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isConnected
                        ? 'Session Duration'
                        : (ping > 0 ? 'Node Latency (ms)' : 'Available Nodes'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colours.subtitleGrey,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DotMatrixText(
                text: heroValue,
                dotSize: isConnected ? 3.2 : 4.2,
                dotSpacing: isConnected ? 1.5 : 1.9,
                charSpacing: isConnected ? 6.0 : 8.5,
                activeColor: textColor,
                inactiveColor: textColor.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 18),

              // ─── 2. CENTER IRIDESCENT FACE ORB + CAPSULE PILL ───
              const ConnectionButton(),
              const SizedBox(height: 22),

              // ─── 3. PRIMARY FLOATING TELEMETRY & NODE CARD ───
              const ConnectionStatus(),

              // ─── 4. NON-OVERLAPPING BANNER AD CARD ───
              if (bannerAd != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colours.subtleBorder(context)),
                    boxShadow: Colours.softCardShadow(context),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: bannerAd.size.height.toDouble(),
                    width: bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
