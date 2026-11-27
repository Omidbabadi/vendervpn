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
    extends $NotifierProvider<LoadedBannerAd, BannerAd?> {
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
  Override overrideWithValue(BannerAd? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BannerAd?>(value),
    );
  }
}

String _$loadedBannerAdHash() => r'a5928d1f99e75bd0097595aca83546af93fe4063';

abstract class _$LoadedBannerAd extends $Notifier<BannerAd?> {
  BannerAd? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BannerAd?, BannerAd?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BannerAd?, BannerAd?>,
              BannerAd?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
