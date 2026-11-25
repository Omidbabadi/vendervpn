import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';
import 'package:vendervpn/src/admob/domain/repo/admob_repo.dart';

/// Shows the loaded rewarded ad. Right(true) means the reward was earned.
class ShowRewardedAd extends UsecaseWithOutParams<bool> {
  const ShowRewardedAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<bool> call() => _repo.showRewardedAd();
}
