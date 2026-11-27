// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_ad.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoadedBannerAd)
final loadedBannerAdProvider = LoadedBannerAdProvider._();

final class LoadedBannerAdProvider
    extends $NotifierProvider<LoadedBannerAd, BannerAdHandle?> {
  LoadedBannerAdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadedBannerAdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadedBannerAdHash();

  @$internal
  @override
  LoadedBannerAd create() => LoadedBannerAd();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BannerAdHandle? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BannerAdHandle?>(value),
    );
  }
}

String _$loadedBannerAdHash() => r'8403b5bc25b0f21c1ffb1ecfa24e5e46c7e02299';

abstract class _$LoadedBannerAd extends $Notifier<BannerAdHandle?> {
  BannerAdHandle? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BannerAdHandle?, BannerAdHandle?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BannerAdHandle?, BannerAdHandle?>,
              BannerAdHandle?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
