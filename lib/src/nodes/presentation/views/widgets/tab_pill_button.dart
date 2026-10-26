import 'package:flutter/material.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

class TabPillButton extends StatelessWidget {
  const TabPillButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Colours.classicAdabtiveTextColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colours.cardSurface(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? Colours.softCardShadow(context) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colours.orbEmerald : Colours.subtitleGrey,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? textColor : Colours.subtitleGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
