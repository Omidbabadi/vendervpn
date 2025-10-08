import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/res/media.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/src/connection/presention/adapter/connection_adapter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/services/injection_container.dart';

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adapter = ref.read(connectionAdapterProvider().notifier);
    final status = sl<ValueNotifier<V2RayStatus>>();
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
              debugPrint(value.state);

              await adapter.startConnection();
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: AnimatedContainer(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
                height: 160,
                width: 160,
                duration: const Duration(milliseconds: 1200),
                decoration: BoxDecoration(
                  color:
                      value.state == "CONNECTED"
                          ? Colours.connectedColor
                          : Colours.grayColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  alignment: Alignment.bottomCenter,
                  Media.powerIcon,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
