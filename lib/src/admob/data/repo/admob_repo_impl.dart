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
    VoidCallback onAdFailed,
  ) async {
    try {
      await _remoteDatasrc.loadInterstitialAd(onAdLoaded, onAdFailed);
      return Right(null);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    }
  }

  @override
  ResultFuture<void> showInterstitialAd({
    required VoidCallback onAdDismissedFullScreenContent,
    required VoidCallback onAdFailedToShowFullScreenContent,
    required VoidCallback onAdShowedFullScreenContent,
  }) async {
    try {
      await _remoteDatasrc.showInterstitialAd(
        onAdDismissedFullScreenContent: onAdDismissedFullScreenContent,
        onAdFailedToShowFullScreenContent: onAdFailedToShowFullScreenContent,
        onAdShowedFullScreenContent: onAdShowedFullScreenContent,
      );
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
      return const Right(null);
    } catch (e) {
      return Left(
        AdmobFailure.fromException(
          AdmobException(null, message: e.toString()),
        ),
      );
    }
  }

  @override
  ResultFuture<void> showRewardedAd() async {
    try {
      await _remoteDatasrc.showRewardedAd();
      return const Right(null);
    } on AdmobException catch (e) {
      return Left(AdmobFailure.fromException(e));
    } catch (e) {
      return Left(
        AdmobFailure.fromException(
          AdmobException(null, message: e.toString()),
        ),
      );
    }
  }
}
