import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/consts.dart';

abstract class AdmobRemoteDatasrc {
  Future<void> init();
  Future<void> loadInterstitialAd();
  Future<void> showInterstitialAd();
}

class AdmobRemoteDatasrcImpl implements AdmobRemoteDatasrc {
   AdmobRemoteDatasrcImpl(this._interstitialAd,);
  static final _mobileAds = MobileAds.instance;

  static final AdRequest request = AdRequest(
    
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

   int maxFailedLoadAttempts = 3;

  @override
  Future<void> init() async {
    try {
      final status = await _mobileAds.initialize();
      print(status.adapterStatuses['com.google.android.gms.ads.MobileAds']!.state);
      print('Admob initialized');
    } catch (e) {
      throw AdmobException(message: 'Admob initialization failed');
    }
  }

  @override
  Future<void> loadInterstitialAd() async{
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
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            init();
          }
        },
      ),
    );
    } on AdmobException {
      rethrow;
    } catch (e) {
      throw AdmobException(message: e.toString());
    }
  }

  @override
  Future<void> showInterstitialAd() {
    // TODO: implement showInterstitialAd
    throw UnimplementedError();
  }
}
