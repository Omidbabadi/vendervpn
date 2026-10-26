import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/core/extensions/string_ext.dart';
import 'package:vendervpn/core/extensions/theme_mode_ext.dart';

class CacheHelper {
  const CacheHelper(this._pref);
  final SharedPreferences _pref;

  static const _urlKey = 'url';
  static const _isFirstTimer = 'is_first_timer';
  static const _themeMode = 'theme_mode';
  static const _permissionKey = 'permission_key';
  static const _vpnStateKey = 'vpn_state_key';
  static const _configs = 'configs';
  static const _localConfigs = 'local_configs';
  static const _subscriptionUrls = 'subscription_urls';
  static const _ipCountryCache = 'ip_country_cache';
  static const _localeKey = 'app_locale';

  Future<void> cacheVpnState(String state) async {
    await _pref.setString(_vpnStateKey, state);
  }

  String get vpnState => _pref.getString(_vpnStateKey) ?? 'DISCONNECTED';

  Future<void> cacheConfigs(List<Map<String, String>> configs) async {
    final encoded = configs.map(json.encode).toList();
    await _pref.setStringList(_configs, encoded);
  }

  List<Map<String, dynamic>> get configs {
    final list = _pref.getStringList(_configs);
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
  }

  Future<void> cacheLocalConfigs(List<Map<String, String>> configs) async {
    final encoded = configs.map(json.encode).toList();
    await _pref.setStringList(_localConfigs, encoded);
  }

  List<Map<String, dynamic>> get localConfigs {
    final list = _pref.getStringList(_localConfigs);
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(json.decode(e))).toList();
  }

  Future<void> cacheSubscriptions(List<Map<String, dynamic>> subs) async {
    final encoded = subs.map(json.encode).toList();
    await _pref.setStringList(_subscriptionUrls, encoded);
  }

  List<Map<String, dynamic>> get subscriptions {
    final list = _pref.getStringList(_subscriptionUrls);
    if (list == null) return [];
    final result = <Map<String, dynamic>>[];
    for (final raw in list) {
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          result.add(Map<String, dynamic>.from(decoded));
          continue;
        }
      } catch (_) {
        // Legacy plain URL entry
      }
      if (raw.trim().isNotEmpty) {
        final uri = Uri.tryParse(raw.trim());
        result.add({
          'id': 'sub_${raw.trim().hashCode.abs()}',
          'name': uri?.host.isNotEmpty == true ? uri!.host : 'Subscription',
          'url': raw.trim(),
          'intervalHours': 6,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }
    }
    return result;
  }

  Map<String, String> get ipCountryMap {
    final raw = _pref.getString(_ipCountryCache);
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, String>.from(json.decode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> cacheIpCountry(String hostOrIp, String countryCode) async {
    final map = ipCountryMap;
    map[hostOrIp] = countryCode;
    await _pref.setString(_ipCountryCache, json.encode(map));
  }

  Future<void> cachePermission(bool permission) async {
    await _pref.setBool(_permissionKey, permission);
  }

  Future<void> cacheId(String id) async {
    await _pref.setString(_urlKey, id);
    Cache.instance.setUrl(id);
  }

  Future<void> cacheIsFirstTimer(bool firstTime) async {
    await _pref.setBool(_isFirstTimer, firstTime);
  }

  Future<void> cacheThemeMode(ThemeMode theme) async {
    await _pref.setString(_themeMode, theme.themeStringValue);
    Cache.instance.setThemeMode(theme);
  }

  bool get permission => _pref.getBool(_permissionKey) ?? false;

  bool get firstTimer => _pref.getBool(_isFirstTimer) ?? true;

  String? get id => _pref.getString(_urlKey);

  ThemeMode get themeMode {
    final theme =
        _pref.getString(_themeMode)?.stringToTheme ?? ThemeMode.system;
    Cache.instance.setThemeMode(theme);
    return theme;
  }

  Future<void> cacheLocale(String languageCode) async {
    await _pref.setString(_localeKey, languageCode);
  }

  String get localeCode => _pref.getString(_localeKey) ?? 'en';
}
