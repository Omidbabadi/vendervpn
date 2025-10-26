import 'package:vendervpn/core/utils/typedefs.dart';

abstract class AdmobRepo {
  ResultFuture<void> init();
  ResultFuture<void> loadInterstitialAd();
  ResultFuture<void> showInterstitialAd();
}
