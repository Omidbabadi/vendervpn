import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Build-time configuration, injected with
/// `flutter run|build --dart-define-from-file=dart_defines.json`.
/// See `dart_defines.example.json` for the keys.
abstract final class AppConfig {
  // --- Appwrite --------------------------------------------------------------
  static const appwriteEndpoint = String.fromEnvironment('APPWRITE_ENDPOINT');
  static const appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
  );

  /// Throws a [StateError] with setup instructions when a required value is
  /// missing, so a misconfigured build fails loudly at startup.
  static void ensureConfigured() {
    final missing = [
      if (appwriteEndpoint.isEmpty) 'APPWRITE_ENDPOINT',
      if (appwriteProjectId.isEmpty) 'APPWRITE_PROJECT_ID',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing build config: ${missing.join(', ')}. Copy '
        'dart_defines.example.json to dart_defines.json, fill it in, and run '
        'with --dart-define-from-file=dart_defines.json',
      );
    }
  }

  // --- AdMob ad units --------------------------------------------------------
  // Release builds use the IDs from the defines file. Debug and profile builds
  // always use Google's public sample IDs, so live ads are never loaded while
  // developing. A release ID that is not set returns null and the ad is skipped.

  static String? get bannerAdUnitId => _pick(
    android: _androidBanner,
    ios: _iosBanner,
    androidSample: 'ca-app-pub-3940256099942544/9214589741',
    iosSample: 'ca-app-pub-3940256099942544/2934735716',
  );

  static String? get interstitialAdUnitId => _pick(
    android: _androidInterstitial,
    ios: _iosInterstitial,
    androidSample: 'ca-app-pub-3940256099942544/1033173712',
    iosSample: 'ca-app-pub-3940256099942544/4411468910',
  );

  static String? get rewardedAdUnitId => _pick(
    android: _androidRewarded,
    ios: _iosRewarded,
    androidSample: 'ca-app-pub-3940256099942544/5224354917',
    iosSample: 'ca-app-pub-3940256099942544/1712485313',
  );

  static const _androidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );
  static const _iosBanner = String.fromEnvironment('ADMOB_IOS_BANNER_ID');
  static const _androidInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
  );
  static const _androidRewarded = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_ID',
  );
  static const _iosRewarded = String.fromEnvironment('ADMOB_IOS_REWARDED_ID');

  static String? _pick({
    required String android,
    required String ios,
    required String androidSample,
    required String iosSample,
  }) {
    final String value;
    if (Platform.isAndroid) {
      value = kReleaseMode ? android : androidSample;
    } else if (Platform.isIOS) {
      value = kReleaseMode ? ios : iosSample;
    } else {
      return null;
    }
    return value.isEmpty ? null : value;
  }
}
