import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/config/app_config.dart';
import 'package:vendervpn/core/common/entities/banner_ad_handle.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/app_log.dart';

abstract class AdmobRemoteDatasrc {
  Future<void> init();
  Future<void> loadInterstitialAd(
    void Function() onAdLoaded,
    void Function() onAdFailed,
  );
  Future<void> showInterstitialAd({
    required void Function() onAdDismissedFullScreenContent,
    required void Function() onAdFailedToShowFullScreenContent,
    required void Function() onAdShowedFullScreenContent,
  });
  Future<BannerAdHandle> showBannerAd(double width);
  Future<void> loadRewardedAd();

  /// Returns true if the user watched the ad to the end (earned the reward).
  Future<bool> showRewardedAd();
}

class AdmobRemoteDatasrcImpl implements AdmobRemoteDatasrc {
  AdmobRemoteDatasrcImpl();
  static final _mobileAds = MobileAds.instance;

  static final AdRequest request = AdRequest(nonPersonalizedAds: false);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  int _numInterstitialLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;

  @override
  Future<void> init() async {
    try {
      await _mobileAds.initialize();
      appLog('Ad mob Initialized ');
    } catch (e) {
      throw AdmobException(null, message: 'Admob initialization failed');
    }
  }

  @override
  Future<void> loadInterstitialAd(
    void Function() onAdLoaded,
    void Function() onAdFailed,
  ) async {
    final completer = Completer<void>();

    void attemptLoad() {
      try {
        InterstitialAd.load(
          adUnitId: AppConfig.interstitialAdUnitId!,
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

              if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
                attemptLoad();
                return;
              }
              _numInterstitialLoadAttempts = 0;
              appLog(error.message);
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
    required void Function() onAdDismissedFullScreenContent,
    required void Function() onAdFailedToShowFullScreenContent,
    required void Function() onAdShowedFullScreenContent,
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
          appLog('$ad onAdFailedToShowFullScreenContent: $error');
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
  Future<BannerAdHandle> showBannerAd(double width) async {
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
      final adUnitId = AppConfig.bannerAdUnitId;
      if (adUnitId == null) {
        throw const AdmobException(
          null,
          message: 'No banner ad unit configured',
        );
      }
      final completer = Completer<BannerAd>();
      await BannerAd(
        size: size,
        adUnitId: adUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (completer.isCompleted) {
              ad.dispose();
            } else {
              completer.complete(ad as BannerAd);
            }
          },
          onAdFailedToLoad: (ad, loadError) {
            ad.dispose();
            appLog('Banner Ad Failed To Load: ${loadError.message}');
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
      final banner = await completer.future;
      return BannerAdHandle(
        native: banner,
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        dispose: banner.dispose,
      );
    } on AdmobException {
      rethrow;
    } catch (e, s) {
      appLogStack(stackTrace: s);
      throw AdmobException(null, message: e.toString());
    }
  }

  @override
  Future<void> loadRewardedAd() async {
    final adUnitId = AppConfig.rewardedAdUnitId;
    if (adUnitId == null) {
      throw const AdmobException(
        null,
        message: 'No rewarded ad unit configured',
      );
    }
    final completer = Completer<void>();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          appLog('Rewarded ad failed to load: ${error.message}');
          if (!completer.isCompleted) {
            completer.completeError(
              AdmobException(error, message: error.message),
            );
          }
        },
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw const AdmobException(
          null,
          message: 'Rewarded ad load timed out',
        );
      },
    );
  }

  @override
  Future<bool> showRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) {
      throw const AdmobException(null, message: 'No rewarded ad is loaded');
    }
    // An ad can only be shown once, so forget it right away.
    _rewardedAd = null;

    final completer = Completer<bool>();
    var earnedReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (closedAd) {
        closedAd.dispose();
        if (!completer.isCompleted) completer.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        appLog('Rewarded ad failed to show: $error');
        failedAd.dispose();
        if (!completer.isCompleted) {
          completer.completeError(
            AdmobException(error, message: error.message),
          );
        }
      },
    );

    await ad.show(
      onUserEarnedReward: (shownAd, reward) {
        earnedReward = true;
      },
    );
    // Wait until the user closes the ad.
    return completer.future;
  }
}
