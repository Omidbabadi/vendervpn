// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_configs_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentConfigsList)
final currentConfigsListProvider = CurrentConfigsListProvider._();

final class CurrentConfigsListProvider
    extends $NotifierProvider<CurrentConfigsList, List<Config>> {
  CurrentConfigsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentConfigsListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentConfigsListHash();

  @$internal
  @override
  CurrentConfigsList create() => CurrentConfigsList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Config> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Config>>(value),
    );
  }
}

String _$currentConfigsListHash() =>
    r'059ae75a5cca702d2a9d2c0c653d5a0b9e14b73c';

abstract class _$CurrentConfigsList extends $Notifier<List<Config>> {
  List<Config> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Config>, List<Config>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Config>, List<Config>>,
              List<Config>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
