
import 'package:flutter/material.dart';
import 'package:vendervpn/core/extensions/text_style_ext.dart';

import '../res/styles/colors.dart';
import '../res/styles/text.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.style});
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'VENDER',
        style: style ?? TextStyles.appLogo.white,
        children: [
          TextSpan(
            text: ' VPN',
            style: TextStyle(color: Colours.warningColor),
          ),
        ],
      ),
    );
  }
}
