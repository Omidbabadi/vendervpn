import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';

abstract class CoreUtils {
  const CoreUtils();

  static Color adabtiveColor(
    BuildContext context,{
      required Color lightModeColor,
      required Color darkModeColor
    }
  ){
    return context.isDarkMode ? darkModeColor : lightModeColor;
  }
}
