import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/riverpod/providers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManagerController extends Notifier<AdManagerState> {
  late InterstitialAd? _interstitialAd;
  late BannerAd? _bannerAd;

  @override
  AdManagerState build() {
    return const AdManagerState.initial();
  }

  Future<void> initAdMob() async {
    //if (!state.initialized) return;
    await MobileAds.instance
        .initialize()
        .then((InitializationStatus status) {
          debugPrint('AD mobo init succssesful');
          state = state.copyWith(initialized: true);
        })
        .catchError((e) {
          state = state.copyWith(error: e.toString());
          debugPrint('#ATTENTION: ${state.error}');
        });
  }

  Future<void> loadInterstitialAd() async  {
    if (!state.initialized) {
      state = state.copyWith(error: 'not initialized');
      debugPrint(state.error);
    }
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      //adUnitId: 'ca-app-pub-3785233012063626/6389192603',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          state = state.copyWith(interstitialLoaded: true);
          debugPrint('AD loaded');
        },
        onAdFailedToLoad: (error) {
          state = state.copyWith(error: ' ${error.code} ${error.message}');
          debugPrint('#####AdLoad Failed#####\n#########');
          debugPrint(state.error);
        },
      ),
    );
  }
  void showAd(){
    if(!state.initialized){
      debugPrint('#info: ad mob not init');
      return;
    }
    InterstitialAd.load(adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        request: AdRequest(),

        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad){
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad){
              ad.dispose();
              _interstitialAd = ad;
              state = state.copyWith(interstitialLoaded: false);
              debugPrint('ad Dissmised');

            }
          );
        }, onAdFailedToLoad: (err){
          debugPrint(err.message);
        }));
  }
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      debugPrint('show ad method Started');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          state = state.copyWith(interstitialLoaded: false);
          debugPrint('ad Dissmised');
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          state = state.copyWith(error: error.message);
          debugPrint('ad failed to show');
        },
      );
    } else {
      debugPrint('Ad not loaded');
    }
  }
}

class AdManagerState {
  final bool initialized;
  final bool interstitialLoaded;
  final bool adCompleted;
  final bool adSkipped;
  final String? error;

  const AdManagerState({
    required this.initialized,
    required this.interstitialLoaded,
    required this.adCompleted,
    required this.adSkipped,
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
}
