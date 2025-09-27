// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configs_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$configsAdapterHash() => r'd272a3244e5ed028c3fc71aa46a1c8fd19b82b6d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ConfigsAdapter
    extends BuildlessAutoDisposeNotifier<ConfigsState> {
  late final GlobalKey<State<StatefulWidget>>? familyKey;

  ConfigsState build([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]);
}

/// See also [ConfigsAdapter].
@ProviderFor(ConfigsAdapter)
const configsAdapterProvider = ConfigsAdapterFamily();

/// See also [ConfigsAdapter].
class ConfigsAdapterFamily extends Family<ConfigsState> {
  /// See also [ConfigsAdapter].
  const ConfigsAdapterFamily();

  /// See also [ConfigsAdapter].
  ConfigsAdapterProvider call([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]) {
    return ConfigsAdapterProvider(
      familyKey,
    );
  }

  @override
  ConfigsAdapterProvider getProviderOverride(
    covariant ConfigsAdapterProvider provider,
  ) {
    return call(
      provider.familyKey,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'configsAdapterProvider';
}

/// See also [ConfigsAdapter].
class ConfigsAdapterProvider
    extends AutoDisposeNotifierProviderImpl<ConfigsAdapter, ConfigsState> {
  /// See also [ConfigsAdapter].
  ConfigsAdapterProvider([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]) : this._internal(
          () => ConfigsAdapter()..familyKey = familyKey,
          from: configsAdapterProvider,
          name: r'configsAdapterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$configsAdapterHash,
          dependencies: ConfigsAdapterFamily._dependencies,
          allTransitiveDependencies:
              ConfigsAdapterFamily._allTransitiveDependencies,
          familyKey: familyKey,
        );

  ConfigsAdapterProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.familyKey,
  }) : super.internal();

  final GlobalKey<State<StatefulWidget>>? familyKey;

  @override
  ConfigsState runNotifierBuild(
    covariant ConfigsAdapter notifier,
  ) {
    return notifier.build(
      familyKey,
    );
  }

  @override
  Override overrideWith(ConfigsAdapter Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConfigsAdapterProvider._internal(
        () => create()..familyKey = familyKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        familyKey: familyKey,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ConfigsAdapter, ConfigsState>
      createElement() {
    return _ConfigsAdapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConfigsAdapterProvider && other.familyKey == familyKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, familyKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ConfigsAdapterRef on AutoDisposeNotifierProviderRef<ConfigsState> {
  /// The parameter `familyKey` of this provider.
  GlobalKey<State<StatefulWidget>>? get familyKey;
}

class _ConfigsAdapterProviderElement
    extends AutoDisposeNotifierProviderElement<ConfigsAdapter, ConfigsState>
    with ConfigsAdapterRef {
  _ConfigsAdapterProviderElement(super.provider);

  @override
  GlobalKey<State<StatefulWidget>>? get familyKey =>
      (origin as ConfigsAdapterProvider).familyKey;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
