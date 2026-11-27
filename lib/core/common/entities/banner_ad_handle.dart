/// A loaded banner ad, passed from the data layer to the one widget that
/// renders it. [native] is the ad SDK's object; only the admob data layer and
/// `BannerAdView` know its real type, so domain and other UI code stay free of
/// the ad SDK.
class BannerAdHandle {
  const BannerAdHandle({
    required this.native,
    required this.width,
    required this.height,
    required this.dispose,
  });

  final Object native;
  final double width;
  final double height;

  /// Frees the native ad. Call once, when the banner is removed.
  final void Function() dispose;
}
