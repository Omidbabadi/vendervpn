import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/res/media.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/core/utils/core_utils.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adapter = ref.watch(connectionAdapterProvider().notifier);
    final status = adapter.status;
    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,
      builder: (_, value, child) {
        return AvatarGlow(
          glowShape: BoxShape.circle,
          animate: value.state == 'CONNECTED',
          glowColor:
              value.state == 'CONNECTED'
                  ? Colours.connectedColor
                  : Colours.grayColor,
          duration:
              value.state == 'CONNECTED'
                  ? const Duration(milliseconds: 6000)
                  : const Duration(milliseconds: 3500),
          repeat: true,
          glowCount: 4,
          glowRadiusFactor: 0.7,
          curve: Curves.easeOutQuad,
          child: Bounceable(
            onTap: () async {
              if (value.state == "CONNECTED") {
                adapter.stopConnection();
              } else {
                await adapter.startConnection();
              }
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: AnimatedContainer(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
                height: 100,
                width: 100,
                duration: const Duration(milliseconds: 1200),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: CoreUtils.adabtiveColor(
                        context,
                        lightModeColor: Colours.darkBackgroundColor,
                        darkModeColor: Colours.lightBackgroundColor,
                      ),
                      blurRadius: 5,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                  color:
                      value.state == "CONNECTED"
                          ? Colours.connectedColor
                          : Colours.lightBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SvgPicture.asset(
                    alignment: Alignment.bottomCenter,
                    Media.powerIcon,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
