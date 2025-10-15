
import '../../../../core/common/singelton/unity_ads_core.dart';
import '../../../../core/errors/exceptions.dart';

abstract class UnityAdsDatasrc {
  Future<void> showInterstitial(String placementId);
}

class UnityAdsDatasrcImpl implements UnityAdsDatasrc {
  const UnityAdsDatasrcImpl(this._ads);
  final UnityAdsService _ads;

  @override
  Future<void> showInterstitial(String placementId) async {
    try {
      await _ads.showInterstitial(placementId: placementId);
    } on UnityException catch (e) {
      print(e.message);
    }
  }
}
