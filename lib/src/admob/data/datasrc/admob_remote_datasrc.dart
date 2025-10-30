import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/consts.dart';

abstract class AdmobRemoteDatasrc {
  Future<void> init();
  Future<void> loadInterstitialAd();
  Future<void> showInterstitialAd();
  Future<void> showBannerAd(double width);
}

class AdmobRemoteDatasrcImpl implements AdmobRemoteDatasrc {
  AdmobRemoteDatasrcImpl(this._interstitialAd);
  static final _mobileAds = MobileAds.instance;

  static final AdRequest request = AdRequest(nonPersonalizedAds: true);

  InterstitialAd? _interstitialAd;

  int _numInterstitialLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;

  @override
  Future<void> init() async {
    try {
      final status = await _mobileAds.initialize();
      print(
        status
            .adapterStatuses['com.google.android.gms.ads.MobileAds']!
            .description,
      );
      print('Admob initialized');
    } catch (e) {
      throw AdmobException(null, message: 'Admob initialization failed');
    }
  }

  @override
  Future<void> loadInterstitialAd() async {
    try {
      InterstitialAd.load(
        adUnitId:
            Platform.isAndroid
                ? Constants.androidAdMobAdUnitId
                : Constants.iosAdMobAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
            showInterstitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              init();
            }

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

  @override
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      await loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent:
          (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        init();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        init();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
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
      print(size.height);
      await BannerAd(
        size: size,
        adUnitId: Constants.androidBannerAdId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            Cache.instance.setBannerAd(ad as BannerAd);
          },
          onAdClicked: (ad) {
            debugPrint('Ad Clicked');
          },
          onAdFailedToLoad: (ad, loadError) {
            print(loadError.message);
            throw AdmobException(
              loadError,
              message: 'Banner Ad Failed To Load: ${loadError.message}',
            );
          },
        ),
        request: request,
      ).load();
    } on AdmobException {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw AdmobException(null, message: e.toString());
    }
  }
}
