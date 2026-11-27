import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vendervpn/core/common/entities/banner_ad_handle.dart';

/// Renders a loaded banner. This is the only UI code that knows the ad SDK
/// (like `mobile_scanner` in the QR sheet, a platform view has to).
class BannerAdView extends StatelessWidget {
  const BannerAdView({required this.handle, super.key});

  final BannerAdHandle handle;

  @override
  Widget build(BuildContext context) {
    final native = handle.native;
    return SizedBox(
      width: handle.width,
      height: handle.height,
      child: native is AdWithView
          ? AdWidget(ad: native)
          : const SizedBox.shrink(),
    );
  }
}
