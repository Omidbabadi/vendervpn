import 'package:flutter/material.dart';

import 'widgets/connected_config.dart';
import 'widgets/connection_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  static const path = '/home';
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          //TODO: top: height / 12,
          top: 80,
          left: 0,
          right: 0,
          child: ConnectionButton(),
        ),
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
