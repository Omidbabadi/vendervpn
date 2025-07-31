//TO-Do: impelant user Ip and connected Ip

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/l10n/app_localizations.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'dart:ui';

import 'package:vendervpn/widgets/configs_list.dart';
import 'package:vendervpn/widgets/show_snackbar.dart';

class HomePageWidget extends ConsumerWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(userPrefsProvider).isDarkMode;

    const String assetName = 'assets/power_icon.svg';
    final v2rayService = ref.read(v2rayControllerProvider.notifier);
    final height = MediaQuery.of(context).size.height;
    final controller = ref.watch(v2rayControllerProvider);
    final selectedConfig = ref.watch(userPrefsProvider).defaultConfig;

    Future<void> showAdBeforeConnect() async {
      if (selectedConfig != null) {
        await v2rayService.showAdThanConnect(config: selectedConfig);
      } else {
        showSnackBar(
          context,
          true,
          title: AppLocalizations.of(context)!.error,
          message: AppLocalizations.of(context)!.select_config,
        );
        return;
      }
    }

    Future<void> showAdThanDisconnect() async {
      await v2rayService.showAdThanDisconncet();
    }

    return controller.when(
      data: (v2ray) {
        bool systemThemeIsDark =
            MediaQuery.of(context).platformBrightness == Brightness.dark;

        final status = ref.read(v2rayControllerProvider.notifier).status;
        // final coreVrssion =
        //     ref.read(v2rayControllerProvider.notifier).coreVersion;
        return ValueListenableBuilder(
          valueListenable: status,
          builder: (ctx, value, child) {
            return Stack(
              children: [
                SizedBox(
                  height: 480,
                  width: double.infinity,
                  child: Image.asset(
                    isDark || systemThemeIsDark
                        ? 'assets/dark_mode_world_map1.png'
                        : 'assets/world _map.png',
                    fit: BoxFit.none,
                    scale: 2.1,
                  ),
                ),
                Positioned(
                  top: height / 12,
                  left: 0,
                  right: 0,
                  child: AvatarGlow(
                    glowShape: BoxShape.circle,
                    animate: value.state == 'CONNECTED',
                    glowColor:
                        value.state == 'DISCONNECTED'
                            ? Colors.grey.shade600
                            : const Color.fromARGB(20, 33, 255, 181),
                    duration:
                        value.state == 'DISCONNECTED'
                            ? const Duration(milliseconds: 3500)
                            : const Duration(milliseconds: 6000),
                    repeat: true,
                    glowCount: 4,
                    glowRadiusFactor: 0.7,
                    curve: Curves.easeOutQuad,
                    child: Bounceable(
                      curve: Curves.bounceIn,
                      reverseCurve: Curves.bounceIn,
                      scaleFactor: 0.9,
                      onTap:
                          value.state == 'DISCONNECTED'
                              ? () => showAdBeforeConnect()
                              : () => showAdThanDisconnect(),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: AnimatedContainer(
                          padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
                          height: 160,
                          width: 160,
                          duration: const Duration(milliseconds: 1200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                value.state == 'DISCONNECTED'
                                    ? Colors.white
                                    : const Color.fromARGB(255, 31, 226, 161),
                            //borderRadius: BorderRadius.circular(99),
                          ),
                          child: SvgPicture.asset(
                            alignment: Alignment.bottomCenter,
                            assetName,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                DraggableScrollableSheet(
                  // maxChildSize: 0.70,
                  initialChildSize: 0.50,
                  minChildSize: 0.50,
                  builder: (context, controller) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,

                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ConfigsListView(scrollController: controller),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      error: (error, stackTrace) => Text('Error: $error'),

      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
