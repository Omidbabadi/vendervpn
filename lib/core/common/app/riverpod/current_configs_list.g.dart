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
    r'cae1cc6c30b3f59761f6f2b36ce45aa30aed3150';

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
