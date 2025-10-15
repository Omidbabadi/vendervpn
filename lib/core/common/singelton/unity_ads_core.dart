import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsService {
  UnityAdsService._internal();
  static final UnityAdsService _instance = UnityAdsService._internal();
  factory UnityAdsService() => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize({
    required String gameId,
    bool testMode = false,
  }) async {
    if (_isInitialized) return;

    await UnityAds.init(
      gameId: gameId,
      testMode: testMode,
      onComplete: () {
        _isInitialized = true;
        print('✅ Unity Ads initialized successfully');
      },
      onFailed: (error, message) {
        print('❌ Unity Ads initialization failed: $error - $message');
      },
    );
  }

  Future<void> showInterstitial({required String placementId}) async {
    if (!_isInitialized) {
      print('⚠️ Unity Ads not initialized yet');
      return;
    }

    await UnityAds.load(
      placementId: placementId,
      onComplete: (placementId) async {
        print('✅ Ad loaded: $placementId');

        await UnityAds.showVideoAd(
          placementId: placementId,
          onStart: (placementId) => print('▶️ Ad started: $placementId'),
          onClick: (placementId) => print('👆 Ad clicked: $placementId'),
          onSkipped: (placementId) => print('⏩ Ad skipped: $placementId'),
          onComplete: (placementId) => print('🏁 Ad completed: $placementId'),
          onFailed:
              (placementId, error, message) =>
                  print('❌ Ad failed: $placementId - $error - $message'),
        );
      },
      onFailed: (placementId, error, message) {
        if (error == UnityAdsLoadError.noFill) {
          Future.delayed(Duration(seconds: 30), () {
            print('retrying');
            UnityAds.load(placementId: placementId);
          });
        }
        print('❌ Failed to load ad: $placementId - $error - $message');
      },
    );
  }

  UnityBannerAd showBannerAd(String placementId) {
    return UnityBannerAd(
      placementId: placementId,
      onLoad: (placementId) => print('Banner loaded: $placementId'),
      onClick: (placementId) => print('Banner clicked: $placementId'),
      onShown: (placementId) => print('Banner shown: $placementId'),
      onFailed: (placementId, error, message) {
        if (error == UnityAdsBannerError.noFill) {
                 Future.delayed(Duration(seconds: 30), () {
                  print('retrying');
                  UnityAds.load(placementId: placementId);
                });
              }
        print('Banner Ad $placementId failed: $error $message');
      },
    );
  }
}
