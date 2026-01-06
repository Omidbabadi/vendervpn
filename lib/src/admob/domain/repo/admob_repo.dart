
import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class AdmobRepo {
  ResultFuture<void> init();
  ResultFuture<void> loadInterstitialAd(VoidCallback onAdShown);
  ResultFuture<void> showInterstitialAd();
  ResultFuture<void> showBannerAd(double width);
  ResultFuture<void> loadRewardedAd();
  ResultFuture<void> showRewardedAd();
}
