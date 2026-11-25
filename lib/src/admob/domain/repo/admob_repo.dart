import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class AdmobRepo {
  ResultFuture<void> init();
  ResultFuture<void> loadInterstitialAd(
    VoidCallback onAdLoaded,
    VoidCallback onAdFailed,
  );
  ResultFuture<void> showInterstitialAd({
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
    required VoidCallback onAdShowedFullScreenContent,
  });
  ResultFuture<void> showBannerAd(double width);
  ResultFuture<void> loadRewardedAd();

  /// Right(true) if the user watched the ad to the end.
  ResultFuture<bool> showRewardedAd();
}
