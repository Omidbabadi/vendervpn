import 'package:flutter/material.dart';

import '../res/styles/colors.dart';

extension TextStyleExt on TextStyle {
  TextStyle get orange => copyWith(color: Colours.warningColor);
  TextStyle get dark => copyWith(color: Colours.lightThemePrimaryTextColor);
  TextStyle get grey => copyWith(color: Colours.darkThemeSecondaryColor);
  TextStyle get white => copyWith(color: Colours.darkThemePrimaryTextColor);
  TextStyle get primary => copyWith(color: Colours.lightThemePrimaryColor);

  TextStyle adaptiveColor(BuildContext context) =>
     copyWith(color: Colours.classicAdabtiveTextColor(context));
}  