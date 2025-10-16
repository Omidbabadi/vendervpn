import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/errors/failures.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/unity_ads/data/datascr/unity_ads_datasrc.dart';
import 'package:dartz/dartz.dart';
import 'package:vendervpn/src/unity_ads/domain/repo/unity_ads_repo.dart';

class UnityAdsRepoImpl implements UnityAdsRepo {
  const UnityAdsRepoImpl(this._datasrc);
  final UnityAdsDatasrc _datasrc;

  @override
  ResultFuture<void> showInterstitial(String placementId) async {
    try {
      await _datasrc.showInterstitial(placementId);
      return const Right(null);
    } on UnityException catch (e) {
      return Left(UnityAdsFailure.fromException(e));
    }
  }
  
  @override
  ResultFuture<bool> isInitialize() async {
        try {
      await _datasrc.isInitialize();
      return const Right(true);
    } on UnityException catch (e) {
      return Left(UnityAdsFailure.fromException(e));
    }
  }

}
