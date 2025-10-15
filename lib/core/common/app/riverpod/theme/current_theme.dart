import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../services/injection_container.dart';
import '../../../singelton/core.dart';
import '../../cache_helper.dart';

part "current_theme.g.dart";

@Riverpod(keepAlive: true)
class CurrentTheme extends _$CurrentTheme {
   final ValueNotifier<ThemeMode> _notifier = Cache.instance.themeModeNotifier;
  @override
  ThemeMode build() {
    final initialThemeMode = sl<CacheHelper>().themeMode;
  
    _notifier.addListener(_onThemeChanged);

    ref.onDispose(() {
      _notifier.removeListener(_onThemeChanged);
    });

    return initialThemeMode;
  }

   void _onThemeChanged() {
      state = _notifier.value;
  }


  void toggleTheme(ThemeMode theme) {
    final newMode = switch (theme) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    sl<CacheHelper>().cacheThemeMode(newMode);
  }

  
}
