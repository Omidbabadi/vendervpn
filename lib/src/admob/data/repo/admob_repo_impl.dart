import 'dart:ui';

import 'package:dartz/dartz.dart';
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
  ResultFuture<void> loadInterstitialAd(
    VoidCallback onAdLoaded,
    VoidCallback onAdFailed,{
   required VoidCallback onAdShowedFullScreenContent,

  required  VoidCallback onAdDismissedFullScreenContent,
  required  VoidCallback onAdFailedToShowFullScreenContent,}
  ) async {
    try {
      await _remoteDatasrc.loadInterstitialAd(
        onAdLoaded,
        onAdFailed,
       onAdShowedFullScreenContent: onAdShowedFullScreenContent,
       onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
        onAdFailedToShowFullScreenContent:onAdFailedToShowFullScreenContent ,
      );
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
  ResultFuture<void> showBannerAd(double width) async {
    try {
      await _remoteDatasrc.showBannerAd(width);

      return Right(null);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    }
  }

  @override
  ResultFuture<void> loadRewardedAd() async {
    try {
      await _remoteDatasrc.loadRewardedAd();
      return Right(null);
    } catch (e) {
      return Left(
        AdmobFailure.fromException(AdmobException(null, message: 'test')),
      );
    }
  }

  @override
  ResultFuture<void> showRewardedAd() {
    // TODO: implement showRewardedAd
    throw UnimplementedError();
  }
}
