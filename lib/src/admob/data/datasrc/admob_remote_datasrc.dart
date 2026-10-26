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
    VoidCallback onAdFailed,
  );
  Future<void> showInterstitialAd({
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
    required VoidCallback onAdShowedFullScreenContent,
  });
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
      debugPrint('Ad mob Initialized ');
    } catch (e) {
      throw AdmobException(null, message: 'Admob initialization failed');
    }
  }

  @override
  Future<void> loadInterstitialAd(
    VoidCallback onAdLoaded,
    VoidCallback onAdFailed,
  ) async {
    final completer = Completer<void>();

    void attemptLoad() {
      try {
        InterstitialAd.load(
          adUnitId: CoreUtils.interstitialAdId!,
          request: request,
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              _interstitialAd = ad;
              _numInterstitialLoadAttempts = 0;
              _interstitialAd!.setImmersiveMode(true);

              onAdLoaded();
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
            onAdFailedToLoad: (LoadAdError error) {
              _numInterstitialLoadAttempts += 1;
              _interstitialAd = null;
              Cache.instance.setInterstitialAd(null);

              if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
                attemptLoad();
                return;
              }
              _numInterstitialLoadAttempts = 0;
              debugPrint(error.message);
              onAdFailed();

              if (!completer.isCompleted) {
                completer.completeError(
                  AdmobException(error, message: error.message),
                );
              }
            },
          ),
        );
      } catch (e) {
        _numInterstitialLoadAttempts = 0;
        onAdFailed();
        if (!completer.isCompleted) {
          completer.completeError(AdmobException(null, message: e.toString()));
        }
      }
    }

    attemptLoad();
    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        _numInterstitialLoadAttempts = 0;
        onAdFailed();
        throw const AdmobException(
          null,
          message: 'Interstitial ad load timed out',
        );
      },
    );
  }

  @override
  Future<void> showInterstitialAd({
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
    required VoidCallback onAdShowedFullScreenContent,
  }) async {
    if (_interstitialAd == null) {
      onAdFailedToShowFullScreenContent();
      return;
    }

    final completer = Completer<void>();
    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent:
            (InterstitialAd ad) => onAdShowedFullScreenContent(),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _interstitialAd = null;
          onAdDismissedFullScreenContent();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _interstitialAd = null;
          onAdFailedToShowFullScreenContent();
          if (!completer.isCompleted) {
            completer.completeError(
              AdmobException(error, message: error.message),
            );
          }
        },
      );
      await _interstitialAd!.show();
      await completer.future;
    } on AdmobException {
      rethrow;
    } catch (e) {
      _interstitialAd = null;
      onAdFailedToShowFullScreenContent();
      throw AdmobException(null, message: e.toString());
    }
  }

  @override
  Future<void> showBannerAd(double width) async {
    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
        width.truncate(),
      );

      if (size == null) {
        throw const AdmobException(
          null,
          message: 'Unable to get width of anchored banner',
        );
      }
      final adUnitId = CoreUtils.bannerAdUnitId ?? Constants.androidBannerAdIdTest;
      final completer = Completer<void>();
      await BannerAd(
        size: size,
        adUnitId: adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            Cache.instance.setBannerAd(ad as BannerAd);
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onAdClicked: (ad) {
            debugPrint('Ad Clicked');
          },
          onAdFailedToLoad: (ad, loadError) {
            ad.dispose();
            debugPrint('Banner Ad Failed To Load: ${loadError.message}');
            if (!completer.isCompleted) {
              completer.completeError(
                AdmobException(
                  loadError,
                  message: 'Banner Ad Failed To Load: ${loadError.message}',
                ),
              );
            }
          },
        ),
        request: const AdRequest(),
      ).load();
      await completer.future;
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
