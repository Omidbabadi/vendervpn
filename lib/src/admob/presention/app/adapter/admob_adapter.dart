import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_interstitial_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_interstitial_ad.dart';

import '../../../../../core/services/injection_container.dart';
import '../../../domain/usecase/init.dart';

part 'admob_adapter.g.dart';
part 'admob_state.dart';

@Riverpod(keepAlive: true)
class AdmobAdapter extends _$AdmobAdapter {
  @override
  AdmobState build() {
    _init = sl<Init>();
    _loadInterstitialAd = sl<LoadInterstitialAd>();
    _showInterstitialAd = sl<ShowInterstitialAd>();
    return const AdmobInit();
  }

  late Init _init;
  late LoadInterstitialAd _loadInterstitialAd;
  late ShowInterstitialAd _showInterstitialAd;
  Future<void> init() async {
    state = const AdmobInitialzing();
    final result = await _init.call();
    result.fold(
      (left) {
        state = AdmobError(left.message);
      },
      (right) {
        debugPrint('Admob initialized successfully');
        state = const AdmobInitialzed();
      },
    );
  }

  Future<void> loadInterstitialAd() async {
    state = const InterstitialAdLoading();
    final result = await _loadInterstitialAd.call();
    result.fold(
      (left) {
        state = AdmobError(left.message);
      },
      (right) {
        state = InterstitialAdLoaded();
      },
    );
  }

  Future<void> showInterstitialAd() async {
    state = const InterstitialAdShowing();
    final result = await _showInterstitialAd.call();
    result.fold((left) {
      state = AdmobError(left.message);
    }, (right) {
      state = const InterstitialAdShowed();
    });
  }
}
