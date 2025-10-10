import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/services/injection_container.dart';

import '../../../../../core/res/styles/colors.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final status = sl<ValueNotifier<V2RayStatus>>();

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,

      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color:
                value.state == "CONNECTED"
                    ? const Color.fromARGB(255, 33, 255, 181)
                    : Colours.grayColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(value.state, textAlign: TextAlign.center),
          ),
        );
      },
    );
  }
}
