import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// A stable ID for this device that survives reinstalling the app, so the
/// server keeps one daily quota per device.
///
/// Android: ANDROID_ID (per signing key and user since Android 8; survives a
/// reinstall, changes on factory reset).
/// iOS: a random UUID kept in the Keychain, which outlives the app.
class DeviceIdentity {
  DeviceIdentity(this._storage);
  final FlutterSecureStorage _storage;

  static const _channel = MethodChannel('vendervpn/device');
  static const _storageKey = 'quota_device_id';

  /// Returned by a batch of old Android devices, so it identifies nothing.
  static const _brokenAndroidId = '9774d56d682e549c';

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  String? _cached;

  String get platform => Platform.isIOS ? 'ios' : 'android';

  Future<String> deviceId() async => _cached ??= await _load();

  Future<String> _load() async {
    if (Platform.isAndroid) {
      try {
        final id = await _channel.invokeMethod<String>('androidId');
        if (id != null && id.length >= 8 && id != _brokenAndroidId) return id;
      } on PlatformException {
        // Fall back to a stored UUID below.
      } on MissingPluginException {
        // Same.
      }
    }
    final stored = await _storage.read(key: _storageKey, iOptions: _iosOptions);
    if (stored != null && stored.length >= 8) return stored;
    final created = const Uuid().v4();
    await _storage.write(
      key: _storageKey,
      value: created,
      iOptions: _iosOptions,
    );
    return created;
  }
}
