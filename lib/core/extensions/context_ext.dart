import 'package:flutter/material.dart';
import 'package:vendervpn/core/res/styles/pallet.dart';

import '../common/singelton/core.dart';


extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// The app's colour tokens. Falls back to the light/dark seed when the
  /// theme has no [Pallet] (e.g. a bare widget test).
  Pallet get pallet =>
      Theme.of(this).extension<Pallet>() ??
      (isDarkMode ? Pallet.dark : Pallet.light);

  TextTheme get textTheme => Theme.of(this).textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get size => MediaQuery.of(this).size;

  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  Brightness get brightness => MediaQuery.of(this).platformBrightness;

  bool get isDarkMode {
    return switch (Cache.instance.themeModeNotifier.value) {
      ThemeMode.system => MediaQuery.of(this).platformBrightness == Brightness.dark,
      ThemeMode.dark => true,
      _ => false,
    };
  }

}