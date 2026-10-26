import 'package:flutter/material.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';

import '../../utils/core_utils.dart';

abstract class Colours {
  // ─── Cirus Luminous Light & Obsidian Dark Canvas ───
  static const Color lightBackgroundColor = Color(0xFFF7F8FC);
  static const Color darkBackgroundColor = Color(0xFF06070B);

  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color darkCardSurface = Color(0xFF10131C);

  static const Color lightThemePrimaryTextColor = Color(0xFF151926);
  static const Color darkThemePrimaryTextColor = Color(0xFFF8FAFC);

  static const Color subtitleGrey = Color(0xFF8A93A6);

  // ─── Iridescent Orb Face Spectrum ───
  static const Color orbCoral = Color(0xFFFF3B6B);
  static const Color orbRose = Color(0xFFF43F5E);
  static const Color orbMagenta = Color(0xFFD946EF);
  static const Color orbViolet = Color(0xFF8B5CF6);
  static const Color orbCyan = Color(0xFF06B6D4);
  static const Color orbAzure = Color(0xFF3B82F6);
  static const Color orbEmerald = Color(0xFF10B981);

  // Soft Status Pills
  static const Color pastelAmberBg = Color(0xFFFFF4E5);
  static const Color pastelAmberFg = Color(0xFFD97706);

  static const Color pastelLilacBg = Color(0xFFF3E8FF);
  static const Color pastelLilacFg = Color(0xFF7C3AED);

  static const Color pastelRoseBg = Color(0xFFFFE4E8);
  static const Color pastelRoseFg = Color(0xFFE11D48);

  static const Color pastelMintBg = Color(0xFFD1FAE5);
  static const Color pastelMintFg = Color(0xFF059669);

  static Color scaffoldBg(BuildContext context) => CoreUtils.adabtiveColor(
    context,
    lightModeColor: lightBackgroundColor,
    darkModeColor: darkBackgroundColor,
  );

  static Color classicAdabtiveTextColor(BuildContext context) =>
      CoreUtils.adabtiveColor(
        context,
        lightModeColor: lightThemePrimaryTextColor,
        darkModeColor: darkThemePrimaryTextColor,
      );

  static Color cardSurface(BuildContext context) => CoreUtils.adabtiveColor(
    context,
    lightModeColor: lightCardSurface,
    darkModeColor: darkCardSurface,
  );

  static Color softChipBg(BuildContext context) => CoreUtils.adabtiveColor(
    context,
    lightModeColor: const Color(0xFFF1F3F9),
    darkModeColor: const Color(0xFF1A1F2E),
  );

  static Color subtleBorder(BuildContext context) => CoreUtils.adabtiveColor(
    context,
    lightModeColor: const Color(0xFFECEEF6),
    darkModeColor: const Color(0xFF1E2333),
  );

  static List<BoxShadow> softCardShadow(BuildContext context) {
    final isDark = context.isDarkMode;
    return [
      BoxShadow(
        color:
            isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF1E293B).withValues(alpha: 0.055),
        blurRadius: 28,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
