import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

import '../repo/admob_repo.dart';

class ShowBannerAd extends UsecaseWithParams<BannerAd?, double> {
  const ShowBannerAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<BannerAd?> call(double param) => _repo.showBannerAd(param);
}
