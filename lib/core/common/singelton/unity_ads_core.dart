// ignore_for_file: avoid_print

import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../errors/exceptions.dart';
import '../../utils/consts.dart';

class UnityAdsService {
  UnityAdsService._internal();
  static final UnityAdsService _instance = UnityAdsService._internal();
  factory UnityAdsService() => _instance;

  bool _isInitialized = false;
  //bool _isInterstitialLoaded = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize({bool testMode = false}) async {
    if (!_isInitialized) {
      try {
        return Future.delayed(Duration.zero, () {
          UnityAds.init(
            gameId: Constants.unityGameId,
            testMode: testMode,
            onComplete: () {
              _isInitialized = true;
              print('✅ Unity Ads initialized successfully');
            },
            onFailed: (error, message) {
              throw UnityException(
                message: '❌ Unity Ads initialization failed: $error - $message',
                unityAdsInitializationError: error,
              );
            },
          );
        });
      } on UnityException {
        rethrow;
      } catch (e) {
        throw const UnityException(message: 'Unity Ads Not Initialized');
      }
    } else {
      print('Unity Ads already initialized');
    }
  }

  Future<void> loadInterstitial() async {
    if (!_isInitialized) {
      print('⚠️ Unity Ads not initialized yet');
      await initialize();
    }
    try {
      return Future.delayed(Duration.zero, () {
        UnityAds.load(
          placementId: Constants.interstitialAndroid,
          onComplete: (placementId) async {
            print('✅ Ad loaded: $placementId');
          },
          onFailed: (placementId, error, message) {
            if (error == UnityAdsLoadError.noFill) {
              Future.delayed(Duration(seconds: 30), () {
                print('❌ Failed to load ad: $placementId - $error - $message');
                UnityAds.load(placementId: placementId);
              });
            }
            throw UnityException(
              message: '❌ Failed to load ad: $placementId - $error - $message',
              unityAdsLoadError: error,
            );
          },
        );
      });
    } on UnityException {
      rethrow;
    } catch (e) {
      throw UnityException(message: 'Something Goes Wrong So No Ads Loaded');
    }
  }

  Future<void> showInterstitial() async {
    try {
      return Future.delayed(Duration.zero, () {
        UnityAds.showVideoAd(
          placementId: Constants.interstitialAndroid,
          onStart: (placementId) => print('▶️ Ad started: $placementId'),
          onClick: (placementId) => print('👆 Ad clicked: $placementId'),
          onSkipped: (placementId) => print('⏩ Ad skipped: $placementId'),
          onComplete: (placementId) => print('🏁 Ad completed: $placementId'),
          onFailed: (placementId, error, message) {
            print('❌ Failed to load ad: $placementId - $error - $message');

            throw UnityException(
              message: '❌ Ad failed: $placementId - $error - $message',
              unityAdsShowError: error,
            );
          },
        );
      });
    } on UnityException {
      rethrow;
    } catch (e) {
      throw UnityException(message: 'Something Goes Wrong So No Ads Showed');
    }
  }

  UnityBannerAd showBannerAd() {
    try {
      return UnityBannerAd(
        placementId: Constants.bannerAndroid,
        onLoad: (placementId) => print('Banner loaded: $placementId'),
        onClick: (placementId) => print('Banner clicked: $placementId'),
        onShown: (placementId) => print('Banner shown: $placementId'),
        onFailed: (placementId, error, message) {
          if (error == UnityAdsBannerError.noFill) {
            Future.delayed(Duration(seconds: 30), () {
              print('Banner Ad $placementId failed: $error $message');
              UnityAds.load(placementId: placementId);
            });
          }
          throw UnityException(
            message: 'Banner Ad $placementId failed: $error $message',
          );
        },
      );
    } on UnityException {
      rethrow;
    } catch (e) {
      throw const UnityException(
        message: 'Somthing Goes Wrong So No Baner Ad Been Loaded',
      );
    }
  }
}
