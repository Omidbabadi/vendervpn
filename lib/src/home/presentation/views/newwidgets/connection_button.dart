import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/utils/core_utils.dart';

import '../../../../connection/presention/adapter/connection_adapter.dart';

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key, required this.pulseController});
  final AnimationController pulseController;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionAdapterProvider().notifier).status;
    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,
      builder: (context, value, _) {
        final color = CoreUtils.isConnectedColor(value.state == 'CONNECTED');

        return SizedBox(
          height: 220,
          width: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow blur
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),

              // Pulse ring
              AnimatedBuilder(
                animation: pulseController,
                builder: (_, __) {
                  final t = pulseController.value;
                  return Transform.scale(
                    scale: 0.95 + (t * 0.15),
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(1 - t),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main button
              GestureDetector(
                onTap: () async {
                  if (value.state == 'CONNECTED') {
                    ref
                        .read(connectionAdapterProvider().notifier)
                        .stopConnection();
                  } else {
                    ref
                        .read(connectionAdapterProvider().notifier)
                        .startConnection();
                  }
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color, color.withOpacity(0.5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power_settings_new,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        value.state == 'CONNECTED' ? 'STOP' : 'TAP TO START',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
