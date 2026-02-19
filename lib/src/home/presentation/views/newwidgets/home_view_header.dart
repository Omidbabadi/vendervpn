import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_v2ray_client/flutter_v2ray.dart';
import 'package:vendervpn/core/common/app/riverpod/current_config.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';
import 'package:vendervpn/core/res/styles/text.dart';

import '../../../../../core/res/styles/colors.dart';
import '../../../../../core/services/injection_container.dart';
import '../../../../../core/utils/core_utils.dart';
import '../../../../connection/presention/adapter/connection_adapter.dart';

class HomeViewHeader extends ConsumerWidget {
  const HomeViewHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentThemeProvider);
    final status = sl<ValueNotifier<V2RayStatus>>();
    final config = ref.watch(currentConfigProvider);

    return ValueListenableBuilder<V2RayStatus>(
      valueListenable: status,
      builder: (context, value, _) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colours.primary.withOpacity(0.4)),
                color: CoreUtils.adabtiveColor(
                  context,
                  lightModeColor: Colours.primary.withOpacity(0.20),
                  darkModeColor: Colours.primary,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseDot(),
                  SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      text:
                          value.state == 'CONNECTED'
                              ? 'PROTOCOL: VLESS / XTLS'
                              : 'N/A',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: Colours.daarkModeListTileColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value.state == 'CONNECTED' ? 'Connected' : 'Not Connected',
              style: TextStyles.headerBig.adaptiveColor(context),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: 'Your IP: ',
                style: TextStyle(color: Colors.grey),
                children: [
                  TextSpan(
                    text:
                        config != null && value.state == 'CONNECTED'
                            ? config.address
                            : '0.0.0.0',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.duration,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildBottomNav(bool isDark) {
  return BottomNavigationBar(
    currentIndex: 0,
    selectedItemColor: const Color(0xFF135BEC),
    unselectedItemColor: Colors.grey,
    backgroundColor: isDark ? const Color(0xFF1B2330) : Colors.white,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Servers'),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Logs'),
    ],
  );
}

// ────────────────────────────────────────────────────────────────

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 0, 165, 110),
      ),
    );
  }
}
