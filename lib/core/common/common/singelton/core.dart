import 'package:flutter/material.dart';

class Cache {
  Cache._internal();

  static final instance = Cache._internal();

  String? _id;

  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  String? get id => _id;

  void setThemeMode(ThemeMode theme) {
    themeModeNotifier.value = theme;
  }

  void setId(String? id) {
    _id = id;
  }

  void reset() {
    setId(null);
  }
}
