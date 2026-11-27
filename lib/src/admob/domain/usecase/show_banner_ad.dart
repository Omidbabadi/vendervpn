import 'package:vendervpn/core/common/entities/banner_ad_handle.dart';
import 'package:vendervpn/core/usecase/usecase.dart';
import 'package:vendervpn/core/utils/typedefs.dart';

import '../repo/admob_repo.dart';

class ShowBannerAd extends UsecaseWithParams<BannerAdHandle, double> {
  const ShowBannerAd(this._repo);
  final AdmobRepo _repo;

  @override
  ResultFuture<BannerAdHandle> call(double param) => _repo.showBannerAd(param);
}
