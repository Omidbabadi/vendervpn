import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendervpn/core/common/common/singelton/core.dart';
import 'package:vendervpn/core/extensions/string_ext.dart';
import 'package:vendervpn/core/extensions/theme_mode_ext.dart';

class CacheHelper {
  const CacheHelper(this._pref);
  final SharedPreferences _pref;

  static const _idKey = 'id';
  static const _isFirstTimer = 'is_first_timer';
  static const _themeMode = 'theme_mode';

  Future<void> cacheId(String id) async {
    await _pref.setString(_idKey, id);
    Cache.instance.setId(id);
  }

  Future<void> cacheIsFirstTimer(bool firstTime) async {
    await _pref.setBool(_isFirstTimer, firstTime);
  }

  Future<void> cacheThemeMode(ThemeMode theme) async {
    await _pref.setString(_themeMode, theme.themeStringValue);
    Cache.instance.setThemeMode(theme);
  }

  bool get firstTimer => _pref.getBool(_isFirstTimer) ?? true;
  String? get id => _pref.getString(_idKey);
  ThemeMode get themeMode =>
      _pref.getString(_themeMode)?.stringToTheme ?? ThemeMode.system;
}
