import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class AdmobRepo {
  ResultFuture<void> init();
  ResultFuture<void> loadInterstitialAd(
    VoidCallback onAdLoaded,
    VoidCallback onAdFailed,
{

    required VoidCallback onAdShowedFullScreenContent,
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
  }
  );
  ResultFuture<void> showInterstitialAd();
  ResultFuture<void> showBannerAd(double width);
  ResultFuture<void> loadRewardedAd();
  ResultFuture<void> showRewardedAd();
}
