import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/repo/admob_repo.dart';

class LoadRewardedAd extends UsecaseWithOutParams<void> {
  const LoadRewardedAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<void> call() => _repo.loadRewardedAd();
}
