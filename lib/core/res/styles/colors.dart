import 'package:flutter/material.dart';

import '../../utils/core_utils.dart';

abstract class Colours {
  static const Color lightBackgroundColor = Color(0xFFf6f6f8);
  static const Color darkBackgroundColor = Color(0xFF18181b);
  static const Color lightThemePrimaryTextColor = Color(0xff2A2B2A);
  static const Color darkThemePrimaryTextColor = Color(0xffF4F1DE);
  static const Color primary = Color(0xFF22c55e);
  static const Color primaryDark = Color(0xFF16a34a);

  static const Color onWightColor = Color(0xFFffffff);
  static const Color onBlackColor = Color(0xFF27272a);
  static const Color lightThemePrimaryColor = Color(0xFF0E1116);
  static const Color darkThemeSecondaryColor = Color(0xFFDAD4EF);
  static const Color grayColor = Color(0xff9DA3A4);
  static const Color warningColor = Color(0xffED7D3A);
  static const Color lightModeListTileColor = Color(0xffFAF9FE);
  static const Color daarkModeListTileColor = Color(0xff3A3E3B);

  static Color classicAdabtiveTextColor(BuildContext context) =>
      CoreUtils.adabtiveColor(
        context,
        lightModeColor: lightThemePrimaryTextColor,
        darkModeColor: darkThemePrimaryTextColor,
      );
}
