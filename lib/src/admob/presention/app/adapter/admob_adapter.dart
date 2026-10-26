import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/app/riverpod/banner_ad.dart';
import 'package:vendervpn/core/common/singelton/core.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_interstitial_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/load_rewarded_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_banner_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_interstitial_ad.dart';
import 'package:vendervpn/src/admob/domain/usecase/show_rewarded_ad.dart';

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
    _showBannerAd = sl<ShowBannerAd>();
    _loadRewardedAd = sl<LoadRewardedAd>();
    _showRewardedAd = sl<ShowRewardedAd>();
    return const AdmobInit();
  }

  late Init _init;
  late LoadInterstitialAd _loadInterstitialAd;
  late ShowInterstitialAd _showInterstitialAd;
  late ShowBannerAd _showBannerAd;
  late LoadRewardedAd _loadRewardedAd;
  late ShowRewardedAd _showRewardedAd;

  bool _isInitialized = false;

  /// Strict guard: neither `MobileAds.instance.initialize()` nor any ad request
  /// may run if V2Ray TUN has not started yet.
  bool get _isV2rayStarted => !Cache.instance.isVpnDisconnected;

  Future<bool> init() async {
    if (!_isV2rayStarted) {
      debugPrint('Blocked AdMob init: V2Ray TUN has not started yet.');
      return false;
    }
    if (_isInitialized) return true;

    state = const AdmobInitialzing();
    final result = await _init.call();
    return result.fold(
      (left) {
        state = AdmobError(left.message);
        debugPrint(left.message);
        return false;
      },
      (right) {
        _isInitialized = true;
        debugPrint('Admob initialized successfully over V2Ray TUN');
        state = const AdmobInitialzed();
        return true;
      },
    );
  }

  Future<void> loadInterstitialAd(LoadInterstitialAdParams params) async {
    if (!_isV2rayStarted) {
      debugPrint('Blocked InterstitialAd load: V2Ray TUN has not started yet.');
      params.onAdFailed();
      return;
    }
    final ok = await init();
    if (!ok || !_isV2rayStarted) {
      params.onAdFailed();
      return;
    }
    state = const InterstitialAdLoading();
    final result = await _loadInterstitialAd.call(params);
    result.fold(
      (left) {
        state = AdmobError(left.message);
      },
      (right) {
        state = InterstitialAdLoaded();
      },
    );
  }

  Future<void> showInterstitialAd(ShowInterstitialAdParams params) async {
    if (!_isV2rayStarted) {
      params.onAdFailedToShowFullScreenContent();
      return;
    }
    state = const InterstitialAdShowing();
    final result = await _showInterstitialAd.call(params);
    result.fold(
      (left) {
        state = AdmobError(left.message);
      },
      (right) {
        state = const InterstitialAdShowed();
      },
    );
  }

  Future<void> showBannerAd(double width) async {
    if (!_isV2rayStarted) {
      debugPrint('Blocked BannerAd load: V2Ray TUN has not started yet.');
      return;
    }
    final ok = await init();
    if (!ok || !_isV2rayStarted || !ref.mounted) return;

    final result = await _showBannerAd.call(width);
    if (!ref.mounted || !_isV2rayStarted) return;
    result.fold(
      (failure) {
        debugPrint(failure.message);
      },
      (right) {
        final bannerAd = Cache.instance.bannerAd;
        if (bannerAd != null) {
          ref.read(loadedBannerAdProvider.notifier).loadBannerAd(bannerAd);
        }
      },
    );
  }

  Future<void> loadRewardedAd() async {
    if (!_isV2rayStarted) return;
    final ok = await init();
    if (!ok || !_isV2rayStarted) return;
    state = const RewardedAdLoading();
    final result = await _loadRewardedAd.call();
    result.fold(
      (failure) {
        state = AdmobError(failure.message);
      },
      (_) {
        state = const RewardedAdLoaded();
      },
    );
  }

  Future<void> showRewardedAd() async {
    if (!_isV2rayStarted) return;
    state = const RewardedAdShowing();
    final result = await _showRewardedAd.call();
    result.fold(
      (failure) {
        state = AdmobError(failure.message);
      },
      (_) {
        state = const RewardedAdShowed();
      },
    );
  }
}
