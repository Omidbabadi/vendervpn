import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/src/home/presentation/views/newwidgets/home_view_header.dart';

import 'newwidgets/connection_button.dart';
import 'newwidgets/server_card.dart';
import 'newwidgets/stat_grid.dart';

class XrayVpnScreen extends ConsumerStatefulWidget {
  const XrayVpnScreen({super.key});
  static const path = '/new_home_screen';

  @override
  ConsumerState<XrayVpnScreen> createState() => _XrayVpnScreenState();
}

class _XrayVpnScreenState extends ConsumerState<XrayVpnScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            children: [
              const HomeViewHeader(),
              const SizedBox(height: 24),
              ConnectionButton(pulseController: _pulseController),
              const SizedBox(height: 32),
              const ServerCard(),
              const SizedBox(height: 16),
              const StatGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
