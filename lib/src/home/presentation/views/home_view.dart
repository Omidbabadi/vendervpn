import 'package:flutter/material.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';

import 'widgets/connected_config.dart';
import 'widgets/connection_button.dart';
import 'widgets/connection_status.dart';
import 'widgets/network_stats.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static const path = '/home';
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        
        Positioned(
          left: 0,
          right: 0,
          top: context.height / 3.2,
          child: ConnectionButton(),
        ),
        Positioned(top: 10, left: 0, right: 0, child: NetworkStats()),
        Positioned(
          top: context.height / 1.75,
          width: 160,
          child: ConnectionIndicator(),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConnectedConfigContainer(),
          ),
        ),
        
      ],
    );
  }
}
