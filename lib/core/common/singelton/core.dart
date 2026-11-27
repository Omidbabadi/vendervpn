import 'package:flutter/material.dart';

class Cache {
  Cache._internal();

  static final instance = Cache._internal();

  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  bool _isVpnDisconnected = true;

  bool get isVpnDisconnected => _isVpnDisconnected;
  void setVpnDisconnected(bool value) {
    _isVpnDisconnected = value;
  }

  void setThemeMode(ThemeMode theme) {
    themeModeNotifier.value = theme;
  }
}
