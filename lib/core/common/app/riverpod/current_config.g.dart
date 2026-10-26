// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentConfig)
final currentConfigProvider = CurrentConfigProvider._();

final class CurrentConfigProvider
    extends $NotifierProvider<CurrentConfig, Config?> {
  CurrentConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentConfigHash();

  @$internal
  @override
  CurrentConfig create() => CurrentConfig();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Config? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Config?>(value),
    );
  }
}

String _$currentConfigHash() => r'fc2c52bd2d40c76e999c4049dfcc3c0f0ed6629d';

abstract class _$CurrentConfig extends $Notifier<Config?> {
  Config? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Config?, Config?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Config?, Config?>,
              Config?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
