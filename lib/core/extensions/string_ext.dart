import 'package:flutter/material.dart';

extension StringExt on String {
  ThemeMode get stringToTheme {
    return switch (toLowerCase()) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  bool get stringToBool {
    return switch (toLowerCase()) {
      'true' => true,
      _ => false,
    };
  }
}
