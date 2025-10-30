import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

abstract class AdmobRepo {
  ResultFuture<void> init();
  ResultFuture<void> loadInterstitialAd();
  ResultFuture<void> showInterstitialAd();
  ResultFuture<BannerAd?> showBannerAd(double width);
}
