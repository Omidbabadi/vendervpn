import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/repo/admob_repo.dart';

class LoadInterstitialAd
    extends UsecaseWithParams<void, LoadInterstitialAdParams> {
  const LoadInterstitialAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<void> call(LoadInterstitialAdParams params) =>
      _repo.loadInterstitialAd(
        params.onAdLoaded,
        params.onAdFailed,
            onAdShowedFullScreenContent:     params.onAdShowedFullScreenContent,

       onAdDismissedFullScreenContent: params.onAdDismissedFullScreenContent,
      onAdFailedToShowFullScreenContent:  params.onAdFailedToShowFullScreenContent,
      );
}

class LoadInterstitialAdParams {
  const LoadInterstitialAdParams(
    this.onAdLoaded,
    this.onAdFailed,
    {
      required this.onAdShowedFullScreenContent,
    required this.onAdDismissedFullScreenContent,
    required this.onAdFailedToShowFullScreenContent}
  );
  final VoidCallback onAdLoaded;
  final VoidCallback onAdFailed;
  final VoidCallback onAdShowedFullScreenContent;
  final VoidCallback onAdDismissedFullScreenContent;
  final VoidCallback onAdFailedToShowFullScreenContent;
}
