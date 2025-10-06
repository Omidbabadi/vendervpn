import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

import '../../../../../core/services/injection_container.dart';

class NetworkStats extends StatelessWidget {
  const NetworkStats({super.key});

  @override
  Widget build(BuildContext context) {
    final status = sl<ValueNotifier<V2RayStatus>>();

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,

      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
