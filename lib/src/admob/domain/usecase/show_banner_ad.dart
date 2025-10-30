import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

import '../repo/admob_repo.dart';

class ShowBannerAd extends UsecaseWithParams<void, double> {
  const ShowBannerAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<void> call(double param) => _repo.showBannerAd(param);
}
