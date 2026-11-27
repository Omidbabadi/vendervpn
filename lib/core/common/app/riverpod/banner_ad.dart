import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vendervpn/core/common/entities/banner_ad_handle.dart';

part 'banner_ad.g.dart';

@Riverpod(keepAlive: true)
class LoadedBannerAd extends _$LoadedBannerAd {
  @override
  BannerAdHandle? build() => null;

  void loadBannerAd(BannerAdHandle bannerAd) {
    if (identical(state, bannerAd)) return;
    state?.dispose();
    state = bannerAd;
  }

  void clearBannerAd() {
    state?.dispose();
    state = null;
  }
}
