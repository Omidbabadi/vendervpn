// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admob_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdmobAdapter)
final admobAdapterProvider = AdmobAdapterProvider._();

final class AdmobAdapterProvider
    extends $NotifierProvider<AdmobAdapter, AdmobState> {
  AdmobAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'admobAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$admobAdapterHash();

  @$internal
  @override
  AdmobAdapter create() => AdmobAdapter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdmobState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdmobState>(value),
    );
  }
}

String _$admobAdapterHash() => r'9913d02f928c9fb2d55f8d68ef744a59f9bdf119';

abstract class _$AdmobAdapter extends $Notifier<AdmobState> {
  AdmobState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AdmobState, AdmobState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdmobState, AdmobState>,
              AdmobState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
