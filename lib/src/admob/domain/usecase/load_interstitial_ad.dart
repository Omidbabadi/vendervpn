import 'package:flutter/widgets.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/repo/admob_repo.dart';

class LoadInterstitialAd extends UsecaseWithParams<void,VoidCallback> {
  const LoadInterstitialAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<void> call(VoidCallback onAdShown) => _repo.loadInterstitialAd(onAdShown);
}
