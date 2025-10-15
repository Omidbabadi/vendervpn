
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/unity_ads/domain/repo/unity_ads_repo.dart';

class ShowInterstitial extends UsecaseWithParams<void, String> {
  const ShowInterstitial(this._repo);
  final UnityAdsRepo _repo;
  @override
  ResultFuture call(params) => _repo.showInterstitial(params);
}
