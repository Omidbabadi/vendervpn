import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:country_flags/country_flags.dart';
import 'package:vendervpn/core/res/styles/colors.dart';

abstract class CoreUtils {
  const CoreUtils();

  static Color adabtiveColor(
    BuildContext context, {
    required Color lightModeColor,
    required Color darkModeColor,
  }) {
    return context.isDarkMode ? darkModeColor : lightModeColor;
  }

  static isConnectedColor(bool isConnected) {
    return isConnected ? Colours.connectedColor : Colours.grayColor;
  }


  static CountryFlag getCountryFlag(String currencyCode) {
    return CountryFlag.fromCountryCode(
      currencyCode,
      theme: ImageTheme(shape: Circle()),
    );
  }
}
