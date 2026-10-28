import 'package:flutter/material.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // High-contrast dark pill in light mode, sleek elevated pill in dark mode
    final activePillColor =
        isDark ? const Color(0xFF222228) : const Color(0xFF141416);
    final inactiveCircleColor =
        isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04);
    final inactiveIconColor = Colours.classicAdabtiveTextColor(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: 46,
        padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 13),
        decoration: BoxDecoration(
          color: selected ? activePillColor : inactiveCircleColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing gradient orb when selected (like the "Ask Pulse" icon), plain icon when unselected
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 28 : 20,
              height: selected ? 28 : 20,
              decoration:
                  selected
                      ? BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6FD8), // Pink/Magenta
                            Color(0xFF7B42F6), // Violet (or Colours.orbViolet)
                            Color(
                              0xFF42E695,
                            ), // Emerald accent (or Colours.orbEmerald)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colours.orbViolet.withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                      : null,
              child: Icon(
                icon,
                size: selected ? 15 : 20,
                color: selected ? Colors.white : inactiveIconColor,
              ),
            ),

            // Animated label that expands only for the selected item
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child:
                  selected
                      ? Padding(
                        padding: const EdgeInsets.only(left: 10, right: 4),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
