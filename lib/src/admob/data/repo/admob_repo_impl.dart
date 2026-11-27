import 'package:dartz/dartz.dart';
import 'package:vendervpn/core/common/entities/banner_ad_handle.dart';
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
    void Function() onAdLoaded,
    void Function() onAdFailed,
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
    required void Function() onAdDismissedFullScreenContent,
    required void Function() onAdFailedToShowFullScreenContent,
    required void Function() onAdShowedFullScreenContent,
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
  ResultFuture<BannerAdHandle> showBannerAd(double width) async {
    try {
      final handle = await _remoteDatasrc.showBannerAd(width);
      return Right(handle);
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
  ResultFuture<bool> showRewardedAd() async {
    try {
      final earnedReward = await _remoteDatasrc.showRewardedAd();
      return Right(earnedReward);
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
