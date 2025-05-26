import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:vendervpn/widgets/ad_widget.dart';
import 'dart:ui';

import 'package:vendervpn/widgets/configs_list.dart';

class HomePageWidget extends ConsumerWidget {
  const HomePageWidget({
    super.key,
    required this.connect,
    required this.disConnect,
    required this.delay,
  });
  final void Function() connect;
  final void Function() disConnect;
  final void Function() delay;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final controller = ref.watch(v2rayControllerProvider);
    final selectedConfig = ref.watch(userPrefsProvider).defaultConfig;
    return controller.when(
      data: (v2ray) {
        final status = ref.read(v2rayControllerProvider.notifier).status;
        final coreVrssion =
            ref.read(v2rayControllerProvider.notifier).coreVersion;
        return ValueListenableBuilder(
          valueListenable: status,
          builder: (ctx, value, child) {
            return Stack(
              children: [
                SizedBox(
                  height: 480,
                  width: double.infinity,
                  child: Image.asset(
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? 'assets/dark_mode_world_map1.png'
                        : 'assets/world _map.png',
                    fit: BoxFit.none,
                    scale: 1.7,
                  ),
                ),
                Positioned(
                  top: height / 12,
                  left: 0,
                  right: 0,
                  child: MyCustomWidget(
                    connect: () async {
                      showAdThanConnect(() async {
                        ref
                            .read(v2rayControllerProvider.notifier)
                            .connect(config: selectedConfig!);
                      });
                    },
                    disConnect:
                        () =>
                            ref
                                .read(v2rayControllerProvider.notifier)
                                .disconnect(),
                    isNotConnected: value.state == 'DISCONNECTED',
                  ),
                ),
                DraggableScrollableSheet(
                  maxChildSize: 0.70,
                  initialChildSize: 0.50,
                  minChildSize: 0.50,
                  builder: (context, controller) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        //Theme.of(context).colorScheme.onBackground,
                        // Color.fromARGB(
                        //   255,
                        //   40,
                        //   45,
                        //   53,
                        // ),
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

class MyCustomWidget extends StatefulWidget {
  const MyCustomWidget({
    super.key,
    required this.isNotConnected,
    required this.connect,
    required this.disConnect,
  });
  final bool isNotConnected;

  final void Function() connect;
  final void Function() disConnect;

  @override
  State<MyCustomWidget> createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/power_icon.svg';
    return AvatarGlow(
      glowShape: BoxShape.circle,
      animate: !widget.isNotConnected,
      glowColor:
          widget.isNotConnected
              ? Colors.grey.shade600
              : const Color.fromARGB(20, 33, 255, 181),
      duration:
          widget.isNotConnected
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
        onTap: widget.isNotConnected ? widget.connect : widget.disConnect,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AnimatedContainer(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
            height: 230,
            width: 230,
            duration: const Duration(milliseconds: 1200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  widget.isNotConnected
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
    );
  }
}
