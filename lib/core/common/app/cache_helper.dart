import 'dart:convert';
import 'dart:io';

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
  // v2: the v1 map could hold the user's own country for a node (recorded
  // when the tunnel lookup fell back to the real IP), so it is dropped.
  // v3: keyed by node link instead of address (v2 entries were shared by
  // every node on the same host/CDN and showed the wrong flag).
  static const _ipCountryCache = 'node_country_cache_v3';
  static const _localeKey = 'app_locale';
  static const _perAppProxyEnabledKey = 'per_app_proxy_enabled';
  static const _perAppProxyModeKey = 'per_app_proxy_mode';
  static const _perAppProxyAppsKey = 'per_app_proxy_apps';
  static const _proxyOnlyModeKey = 'proxy_only_mode';
  static const _userAllowedUsage = 'user_allowed_usage';
  static const _cloudUsageQuota = 'cloud_usage_quota';

  /// Session traffic total (upload + download, as V2Ray reports it) already
  /// added to the cloud quota. Lets a restarted app count what was used
  /// while it was closed instead of skipping it.
  static const _cloudTrafficCounted = 'cloud_traffic_counted';

  /// Last quota snapshot from the server (only a cache for the first frame).
  static const _cloudQuotaSnapshot = 'cloud_quota_snapshot_v2';

  /// Usage counted on this device but not yet acknowledged by the server.
  static const _cloudUsageOutbox = 'cloud_usage_outbox';

  /// Appwrite user ID whose session is already bound to this device.
  static const _quotaBoundUserId = 'quota_bound_user_id';

  Map<String, dynamic>? get cloudQuotaSnapshot =>
      _readMap(_cloudQuotaSnapshot);

  Future<void> cacheCloudQuotaSnapshot(Map<String, dynamic> snapshot) async {
    await _pref.setString(_cloudQuotaSnapshot, json.encode(snapshot));
  }

  Map<String, dynamic>? get cloudUsageOutbox => _readMap(_cloudUsageOutbox);

  Future<void> cacheCloudUsageOutbox(Map<String, dynamic> outbox) async {
    await _pref.setString(_cloudUsageOutbox, json.encode(outbox));
  }

  String? get quotaBoundUserId => _pref.getString(_quotaBoundUserId);

  Future<void> cacheQuotaBoundUserId(String? userId) async {
    if (userId == null) {
      await _pref.remove(_quotaBoundUserId);
    } else {
      await _pref.setString(_quotaBoundUserId, userId);
    }
  }

  Map<String, dynamic>? _readMap(String key) {
    final raw = _pref.getString(key);
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(json.decode(raw) as Map);
  }

  int? get cloudTrafficCounted => _pref.getInt(_cloudTrafficCounted);

  Future<void> cacheCloudTrafficCounted(int? total) async {
    if (total == null) {
      await _pref.remove(_cloudTrafficCounted);
    } else {
      await _pref.setInt(_cloudTrafficCounted, total);
    }
  }

  Future<void> cacheCloudUsageQuota(Map<String, dynamic> quota) async {
    await _pref.setString(_cloudUsageQuota, json.encode(quota));
  }

  Map<String, dynamic>? get cloudUsageQuota {
    final raw = _pref.getString(_cloudUsageQuota);
    if (raw == null || raw.isEmpty) return null;
    return Map<String, dynamic>.from(json.decode(raw) as Map);
  }

  Future<void> cacheUserAllowedUsage(String usage) async {
    await _pref.setString(_userAllowedUsage, usage);
  }

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

  /// Countries verified by a tunnel IP lookup, keyed by the node's full link.
  /// Not keyed by address: nodes behind one CDN domain or relay share an
  /// address but exit in different countries.
  Map<String, String> get nodeCountryMap {
    final raw = _pref.getString(_ipCountryCache);
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, String>.from(json.decode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> cacheNodeCountry(String nodeUri, String countryCode) async {
    final map = nodeCountryMap;
    map[nodeUri] = countryCode;
    await _pref.setString(_ipCountryCache, json.encode(map));
  }

  Future<void> cachePermission(bool permission) async {
    await _pref.setBool(_permissionKey, permission);
  }

  Future<void> cacheId(String id) async {
    await _pref.setString(_urlKey, id);
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

  Future<void> cachePerAppProxyEnabled(bool enabled) async {
    await _pref.setBool(_perAppProxyEnabledKey, enabled);
  }

  bool get perAppProxyEnabled => _pref.getBool(_perAppProxyEnabledKey) ?? false;

  Future<void> cachePerAppProxyMode(String mode) async {
    await _pref.setString(_perAppProxyModeKey, mode);
  }

  String get perAppProxyMode =>
      _pref.getString(_perAppProxyModeKey) ?? 'per_app';

  Future<void> cachePerAppProxyApps(List<String> apps) async {
    await _pref.setStringList(_perAppProxyAppsKey, apps);
  }

  List<String> get perAppProxyApps =>
      _pref.getStringList(_perAppProxyAppsKey) ?? const <String>[];

  Future<void> cacheProxyOnlyMode(bool proxyOnly) async {
    await _pref.setBool(_proxyOnlyModeKey, Platform.isIOS ? true : proxyOnly);
  }

  bool get proxyOnlyMode =>
      Platform.isIOS ? true : (_pref.getBool(_proxyOnlyModeKey) ?? false);
}
