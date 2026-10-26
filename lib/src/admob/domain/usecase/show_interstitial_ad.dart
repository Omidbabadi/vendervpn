import 'dart:ui';

import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/repo/admob_repo.dart';

class ShowInterstitialAd
    extends UsecaseWithParams<void, ShowInterstitialAdParams> {
  const ShowInterstitialAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<void> call(ShowInterstitialAdParams params) =>
      _repo.showInterstitialAd(
        onAdDismissedFullScreenContent: params.onAdDismissedFullScreenContent,
        onAdFailedToShowFullScreenContent:
            params.onAdFailedToShowFullScreenContent,
        onAdShowedFullScreenContent: params.onAdShowedFullScreenContent,
      );
}

class ShowInterstitialAdParams {
  const ShowInterstitialAdParams({
    required this.onAdShowedFullScreenContent,
    required this.onAdDismissedFullScreenContent,
    required this.onAdFailedToShowFullScreenContent,
  });

  final VoidCallback onAdShowedFullScreenContent;
  final VoidCallback onAdDismissedFullScreenContent;
  final VoidCallback onAdFailedToShowFullScreenContent;
}
