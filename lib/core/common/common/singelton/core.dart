import 'package:flutter/material.dart';

class Cache {
  Cache._internal();

  static final instance = Cache._internal();

  String? _url;

  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  String? get url => _url;

  void setThemeMode(ThemeMode theme) {
    themeModeNotifier.value = theme;
  }

  void setUrl(String? id) {
    _url = id;
  }

  void reset() {
    setUrl(null);
  }
}
