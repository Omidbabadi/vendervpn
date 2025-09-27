import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:flutter/foundation.dart';

class AdManagerController extends Notifier<AdManagerState> {
  @override
  AdManagerState build() => const AdManagerState.initial();

  Future<void> initUnityAds() async {
    if (state.initialized) return;
    if (AdManagerState.addUnitId == 'Platform is not Supported') return;
    debugPrint(AdManagerState.addUnitId);

    try {
      await UnityAds.init(gameId: AdManagerState.addUnitId);
      state = state.copyWith(initialized: true);
      debugPrint('Unity Ads Initialized');
    } catch (e) {
      state = state.copyWith(error: e.toString());
      debugPrint(state.error!);
    }
  }

  Future<void> loadInterstitial() async {
    debugPrint(AdManagerState.interstitialId);

    await UnityAds.load(
      placementId: AdManagerState.interstitialId,
      onComplete: (placementId) {
        state = state.copyWith(interstitialLoaded: true);
        debugPrint('Interstitial Loaded');
      },
      onFailed: (placementId, error, message) {
        state = state.copyWith(interstitialLoaded: false, error: message);
        debugPrint(
          "Load Interstitial Failed:\nPlacementId: $placementId Message: $message",
        );
      },
    );
    if (!state.interstitialLoaded) return;
  }

  Future<void> showIntAd() async {
    if (state.interstitialLoaded == false) {
      debugPrint('${!state.interstitialLoaded}');
      await loadInterstitial();
    }
    await UnityAds.showVideoAd(
      placementId: AdManagerState.interstitialId,
      onStart: (placementId) {
        debugPrint('Video Ad $placementId started');
      },
      onClick: (placementId) => debugPrint('Video Ad $placementId click'),
      onSkipped: (placementId) async {
        await Future.delayed(const Duration(seconds: 3));
        await loadInterstitial();

        state = state.copyWith(adSkipped: true);
        debugPrint('Video Ad $placementId skipped');
      },
      onComplete: (placementId) async {
        await Future.delayed(const Duration(seconds: 3));
        await loadInterstitial();
        
        debugPrint('Video Ad $placementId completed');
        state = state.copyWith(adCompleted: true, interstitialLoaded: false);
      },
      onFailed: (placementId, error, message) async {
        await Future.delayed(const Duration(seconds: 3));
        await loadInterstitial();
      },
    );
  }

  Future<void> showBannerAd() async {}

}

class AdManagerState {
  final bool initialized;
  final bool interstitialLoaded;
  final bool adCompleted;
  final bool adSkipped;
  final String? error;

  // final String placementId;

  const AdManagerState({
    required this.initialized,
    required this.interstitialLoaded,
    required this.adCompleted,
    required this.adSkipped,
    //required this.placementId,
    this.error,
  });

  const AdManagerState.initial()
    : initialized = false,
      interstitialLoaded = false,
      adCompleted = false,
      adSkipped = false,
      error = null;

  AdManagerState copyWith({
    bool? initialized,
    bool? interstitialLoaded,
    bool? adCompleted,
    bool? adSkipped,
    String? error,
  }) {
    return AdManagerState(
      initialized: initialized ?? this.initialized,
      interstitialLoaded: interstitialLoaded ?? this.interstitialLoaded,
      adCompleted: adCompleted ?? this.adCompleted,
      adSkipped: adSkipped ?? this.adSkipped,
      error: error,
    );
  }

  static String get addUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '5867671';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return '5867670';
    }
    return 'Platform is not Supported';
  }

  static String get interstitialId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Interstitial_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Interstitial_iOS';
    }
    return '';
  }
}
