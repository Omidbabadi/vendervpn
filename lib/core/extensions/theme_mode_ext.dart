import 'package:flutter/material.dart';

extension ThemeModeExt on ThemeMode {
  String get themeStringValue {
    return switch (this) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      _ => 'system',
    };
  }
}
