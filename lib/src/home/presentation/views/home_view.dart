import 'package:flutter/material.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';

import 'widgets/connected_config.dart';
import 'widgets/connection_button.dart';
import 'widgets/network_stats.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static const path = '/home';
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
     
          top: context.height / 3,
          left: 0,
          right: 0,
          child: ConnectionButton(),
        ),
        Positioned(left: 0, right: 0, top: 20, child: NetworkStats()),
        Positioned(
          bottom: 10,
          right: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConnectedConfigContainer(),
          ),
        ),
      ],
    );
  }
}
