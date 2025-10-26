// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// import '../../errors/exceptions.dart';
// import '../../utils/consts.dart';

// class UnityAdsService {
//   UnityAdsService._internal();
//   static final UnityAdsService _instance = UnityAdsService._internal();
//   factory UnityAdsService() => _instance;
//   int i = 0;
//   bool _isInitialized = false;
//   //bool _isInterstitialLoaded = false;
//   bool get isInitialized => _isInitialized;

//   Future<void> initialize({bool testMode = false}) async {
//     if (!_isInitialized) {
//       try {
//         return Future.delayed(Duration.zero, () {
//           UnityAds.init(
//             gameId: Constants.unityGameId,
//             testMode: false,
//             onComplete: () {
//               _isInitialized = true;
//               print('✅ Unity Ads initialized successfully');
//             },
//             onFailed: (error, message) {
//               throw UnityException(
//                 message: '❌ Unity Ads initialization failed: $error - $message',
//                 unityAdsInitializationError: error,
//               );
//             },
//           );
//         });
//       } on UnityException {
//         rethrow;
//       } catch (e) {
//         throw const UnityException(message: 'Unity Ads Not Initialized');
//       }
//     } else {
//       print('Unity Ads already initialized');
//     }
//   }

//   Future<void> loadInterstitial() async {
//     debugPrint('loadInterstitial started');
//     if (!_isInitialized) {
//       print('⚠️ Unity Ads not initialized yet');
//       await initialize();
//     }
//     try {
//       return Future.delayed(Duration.zero, () {
//         UnityAds.load(
//           placementId: Constants.interstitialAndroid,
//           onComplete: (placementId) async {
//             await showInterstitial();
//             print('✅ Ad loaded: $placementId');
//           },
//           onFailed: (placementId, error, message) {
//             Future.delayed(Duration(seconds: 10), () {
//               i++;
//               print('retries $i');
//               UnityAds.load(placementId: placementId);
//             });

//             print('❌ Failed to load ad: $placementId - $error - $message');
//             throw UnityException(
//               message: '❌ Failed to load ad: $placementId - $error - $message',
//               unityAdsLoadError: error,
//             );
//           },
//         );
//       });
//     } on UnityException {
//       rethrow;
//     } catch (e) {
//       throw UnityException(message: 'Something Goes Wrong So No Ads Loaded');
//     }
//   }

//   Future<void> showInterstitial() async {
//     try {
//       return Future.delayed(Duration.zero, () {
//         UnityAds.showVideoAd(
//           placementId: Constants.interstitialAndroid,
//           onStart: (placementId) => print('▶️ Ad started: $placementId'),
//           onClick: (placementId) => print('👆 Ad clicked: $placementId'),
//           onSkipped: (placementId) => print('⏩ Ad skipped: $placementId'),
//           onComplete: (placementId) => print('🏁 Ad completed: $placementId'),
//           onFailed: (placementId, error, message) {
//             print('❌ Failed to load ad: $placementId - $error - $message');

//             throw UnityException(
//               message: '❌ Ad failed: $placementId - $error - $message',
//               unityAdsShowError: error,
//             );
//           },
//         );
//       });
//     } on UnityException {
//       rethrow;
//     } catch (e) {
//       throw UnityException(message: 'Something Goes Wrong So No Ads Showed');
//     }
//   }

//   UnityBannerAd showBannerAd() {
//     try {
//       return UnityBannerAd(
//         placementId: Constants.bannerAndroid,
//         onLoad: (placementId) => print('Banner loaded: $placementId'),
//         onClick: (placementId) => print('Banner clicked: $placementId'),
//         onShown: (placementId) => print('Banner shown: $placementId'),
//         onFailed: (placementId, error, message) {
//           if (error == UnityAdsBannerError.noFill) {
//             Future.delayed(Duration(seconds: 30), () {
//               print('Banner Ad $placementId failed: $error $message');
//               UnityAds.load(placementId: placementId);
//             });
//           }
//           throw UnityException(
//             message: 'Banner Ad $placementId failed: $error $message',
//           );
//         },
//       );
//     } on UnityException {
//       rethrow;
//     } catch (e) {
//       throw const UnityException(
//         message: 'Somthing Goes Wrong So No Baner Ad Been Loaded',
//       );
//     }
//   }
// }
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobSingelton {
  AdMobSingelton._internal();
  factory AdMobSingelton() => _instance;
  static final AdMobSingelton _instance = AdMobSingelton._internal();
  bool _isInitialized = false;
  final mobileAds = MobileAds.instance;
  bool get isInitialized => _isInitialized;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;
  Future<void> initialize() async {
    await mobileAds.initialize();
    InterstitialAd.load(
      adUnitId:
          Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/1033173712'
              : 'ca-app-pub-3940256099942544/4411468910',
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            initialize();
          }
        },
      ),
    );
    _isInitialized = true;
  }

 void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        initialize();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        initialize();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

}
