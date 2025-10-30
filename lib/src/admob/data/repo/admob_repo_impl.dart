import 'package:dartz/dartz.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/errors/exceptions.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/repo/admob_repo.dart';

import '../../../../core/errors/failures.dart';
import '../datasrc/admob_remote_datasrc.dart';

class AdmobRepoImpl implements AdmobRepo {
  const AdmobRepoImpl(this._remoteDatasrc);

  final AdmobRemoteDatasrc _remoteDatasrc;

  @override
  ResultFuture<void> init() async {
    try {
      await _remoteDatasrc.init();
      return Right(null);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    }
  }

  @override
  ResultFuture<void> loadInterstitialAd() async {
    try {
      await _remoteDatasrc.loadInterstitialAd();
      return Right(null);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    }
  }

  @override
  ResultFuture<void> showInterstitialAd() async {
    try {
      await _remoteDatasrc.showInterstitialAd();
      return Right(null);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    }
  }

  @override
  ResultFuture<BannerAd?> showBannerAd(double width) async {
    try {
      final bannerAd = await _remoteDatasrc.showBannerAd(width);
      if (bannerAd == null) {
        throw AdmobException(null, message: 'Banner Ad Failed to Load');
      }
      return Right(bannerAd);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    }
  }
}
