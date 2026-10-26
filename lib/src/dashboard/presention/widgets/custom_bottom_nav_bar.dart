import 'package:flutter/material.dart';
import 'package:vendervpn/core/res/styles/colors.dart';
import 'package:vendervpn/src/dashboard/presention/widgets/nav_bar_item.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Colours.cardSurface(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colours.subtleBorder(context)),
        boxShadow: [
          ...Colours.softCardShadow(context),
          BoxShadow(
            color: Colours.orbViolet.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: NavBarItem(
              label: 'Home',
              icon: Icons.radio_button_checked_rounded,
              selected: currentIndex == 0,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: NavBarItem(
              label: 'Nodes',
              icon: Icons.dns_outlined,
              selected: currentIndex == 1,
              onTap: () => onSelect(1),
            ),
          ),
          Expanded(
            child: NavBarItem(
              label: 'Setting',
              icon: Icons.tune_rounded,
              selected: currentIndex == 2,
              onTap: () => onSelect(2),
            ),
          ),
        ],
      ),
    );
  }
}
