import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vendervpn/core/services/injection_container.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final status = sl<ValueNotifier<V2RayStatus>>();

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,

      builder: (context, value, child) {
        return Text(value.state);
      },
    );
  }
}
