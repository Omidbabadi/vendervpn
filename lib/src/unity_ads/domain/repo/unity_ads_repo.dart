import 'package:vendervpn/core/utils/typedefs.dart';

abstract class UnityAdsRepo {
  const UnityAdsRepo();

  ResultFuture<void> showInterstitial(String placementId);
  ResultFuture<bool> isInitialize();
}
