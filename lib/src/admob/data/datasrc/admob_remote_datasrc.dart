import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/consts.dart';
import 'package:vendervpn/core/utils/core_utils.dart';

abstract class AdmobRemoteDatasrc {
  Future<void> init();
  Future<void> loadInterstitialAd(
    VoidCallback onAdLoaded,
    VoidCallback onAdFailed, {
    required VoidCallback onAdShowedFullScreenContent,
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
  });
  Future<void> showInterstitialAd();
  Future<void> showBannerAd(double width);
  Future<void> loadRewardedAd();
  Future<void> showRewardedAd();
}

class AdmobRemoteDatasrcImpl implements AdmobRemoteDatasrc {
  AdmobRemoteDatasrcImpl(this._interstitialAd);
  static final _mobileAds = MobileAds.instance;

  static final AdRequest request = AdRequest(nonPersonalizedAds: false);

  InterstitialAd? _interstitialAd;

  int _numInterstitialLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;

  @override
  Future<void> init() async {
    try {
      await _mobileAds.initialize();
      debugPrint('Ad mob Initialized');
    } catch (e) {
      throw AdmobException(null, message: 'Admob initialization failed');
    }
  }

  @override
  Future<void> loadInterstitialAd(
    VoidCallback onAdLoaded,
    VoidCallback onAdFailed, {

    required VoidCallback onAdShowedFullScreenContent,
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
  }) async {
    try {
      InterstitialAd.load(
        adUnitId: CoreUtils.interstitialAdId!,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            _showInterstitialAd(
              onAdShowedFullScreenContent,
              onAdDismissedFullScreenContent,
              onAdFailedToShowFullScreenContent,
            );
            onAdLoaded();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            Cache.instance.setInterstitialAd(null);

            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              init();
            }
            debugPrint(error.message);
            onAdFailed();

            throw AdmobException(error, message: error.message);
          },
        ),
      );
    } on AdmobException {
      rethrow;
    } catch (e) {
      throw AdmobException(null, message: e.toString());
    }
  }

  _showInterstitialAd(
    VoidCallback onAdDismissedFullScreenContent,
    VoidCallback onAdFailedToShowFullScreenContent,
    VoidCallback onAdShowedFullScreenContent,
  ) {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(

      

      onAdShowedFullScreenContent:
          (InterstitialAd ad) => onAdShowedFullScreenContent,
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        onAdDismissedFullScreenContent();
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        onAdFailedToShowFullScreenContent();
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
    );
    _interstitialAd!.show();
  }

  @override
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent:
          (InterstitialAd ad) => debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        init();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
    );
    _interstitialAd!.show();
  }

  @override
  Future<void> showBannerAd(double width) async {
    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            width.truncate(),
          );

      if (size == null) {
        throw AdmobException(
          null,
          message: 'Unable to get width of anchored banner',
        );
      }
      await BannerAd(
        size: AdSize.fullBanner,
        adUnitId: Constants.androidBannerAdIdTest,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            Cache.instance.setBannerAd(ad as BannerAd);
          },
          onAdClicked: (ad) {
            debugPrint('Ad Clicked');
          },
          onAdFailedToLoad: (ad, loadError) {
            throw AdmobException(
              loadError,
              message: 'Banner Ad Failed To Load: ${loadError.message}',
            );
          },
        ),
        request: const AdRequest(),
      ).load();
    } on AdmobException {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw AdmobException(null, message: e.toString());
    }
  }

  @override
  Future<void> loadRewardedAd() async {
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: Constants.androidRewardedAdTest,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete();
          Cache.instance.setRewardedAd(ad);
        },

        onAdFailedToLoad: (error) {
          completer.completeError(error.message);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<void> showRewardedAd() async {
    final ad = Cache.instance.rewardedAd;
    if (ad == null) {
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Ad showed full screen content.');
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('Ad failed to show full screen content with error: $err');

        ad.dispose();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Ad was dismissed.');
        ad.dispose();
      },
      onAdImpression: (ad) {
        debugPrint('Ad recorded an impression.');
      },
      onAdClicked: (ad) {
        debugPrint('Ad was clicked.');
      },
    );
    ad.show(
      onUserEarnedReward: (ad, reward) {
        Cache.instance.resetRewardedAd();
      },
    );
  }
}
