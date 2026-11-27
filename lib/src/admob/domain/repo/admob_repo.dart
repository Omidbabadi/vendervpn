import 'package:vendervpn/core/common/entities/banner_ad_handle.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class AdmobRepo {
  ResultFuture<void> init();
  ResultFuture<void> loadInterstitialAd(
    void Function() onAdLoaded,
    void Function() onAdFailed,
  );
  ResultFuture<void> showInterstitialAd({
    required void Function() onAdDismissedFullScreenContent,
    required void Function() onAdFailedToShowFullScreenContent,
    required void Function() onAdShowedFullScreenContent,
  });
  ResultFuture<BannerAdHandle> showBannerAd(double width);
  ResultFuture<void> loadRewardedAd();

  /// Right(true) if the user watched the ad to the end.
  ResultFuture<bool> showRewardedAd();
}
