import 'package:flutter/material.dart';

import '../res/styles/colors.dart';
import '../utils/core_utils.dart';

class AppBarBottom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: ColoredBox(
        color: CoreUtils.adabtiveColor(
          context,
          lightModeColor: Colours.darkThemeSecondaryColor,
          darkModeColor: Colors.white,
        ),
        child: const SizedBox(width: double.infinity, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => Size.zero;
}