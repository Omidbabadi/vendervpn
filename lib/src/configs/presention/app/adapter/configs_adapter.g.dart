// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configs_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConfigsAdapter)
final configsAdapterProvider = ConfigsAdapterProvider._();

final class ConfigsAdapterProvider
    extends $NotifierProvider<ConfigsAdapter, ConfigsState> {
  ConfigsAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configsAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configsAdapterHash();

  @$internal
  @override
  ConfigsAdapter create() => ConfigsAdapter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigsState>(value),
    );
  }
}

String _$configsAdapterHash() => r'9ed12f658047fbda34505777db92253f52d17302';

abstract class _$ConfigsAdapter extends $Notifier<ConfigsState> {
  ConfigsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConfigsState, ConfigsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConfigsState, ConfigsState>,
              ConfigsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
