import 'package:flutter/material.dart';

import '../common/singelton/core.dart';


extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);

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