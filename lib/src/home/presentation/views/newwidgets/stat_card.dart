
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/theme/current_theme.dart';
import 'package:vendervpn/core/res/styles/text.dart';
import 'package:vendervpn/core/utils/core_utils.dart';

import '../../../../../core/res/styles/colors.dart';

class StatCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({super.key, 
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
ref.watch(currentThemeProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CoreUtils.adabtiveColor(
          context,
          lightModeColor: Colours.lightModeListTileColor,
          darkModeColor: Colours.daarkModeListTileColor,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
color: CoreUtils.adabtiveColor(
            context,
            lightModeColor: Colors.grey.shade200,
            darkModeColor: const Color(0xFF242C3D),
          ),        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.paragraphSubTextRegular.copyWith(),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}