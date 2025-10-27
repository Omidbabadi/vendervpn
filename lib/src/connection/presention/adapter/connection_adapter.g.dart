// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectionAdapterHash() => r'4878962f2a26acf62bb78f28d0d390170b7b3a7b';

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

abstract class _$ConnectionAdapter extends BuildlessNotifier<ConnectionState> {
  late final GlobalKey<State<StatefulWidget>>? familyKey;

  ConnectionState build([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]);
}

/// See also [ConnectionAdapter].
@ProviderFor(ConnectionAdapter)
const connectionAdapterProvider = ConnectionAdapterFamily();

/// See also [ConnectionAdapter].
class ConnectionAdapterFamily extends Family<ConnectionState> {
  /// See also [ConnectionAdapter].
  const ConnectionAdapterFamily();

  /// See also [ConnectionAdapter].
  ConnectionAdapterProvider call([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]) {
    return ConnectionAdapterProvider(
      familyKey,
    );
  }

  @override
  ConnectionAdapterProvider getProviderOverride(
    covariant ConnectionAdapterProvider provider,
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
  String? get name => r'connectionAdapterProvider';
}

/// See also [ConnectionAdapter].
class ConnectionAdapterProvider
    extends NotifierProviderImpl<ConnectionAdapter, ConnectionState> {
  /// See also [ConnectionAdapter].
  ConnectionAdapterProvider([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]) : this._internal(
          () => ConnectionAdapter()..familyKey = familyKey,
          from: connectionAdapterProvider,
          name: r'connectionAdapterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$connectionAdapterHash,
          dependencies: ConnectionAdapterFamily._dependencies,
          allTransitiveDependencies:
              ConnectionAdapterFamily._allTransitiveDependencies,
          familyKey: familyKey,
        );

  ConnectionAdapterProvider._internal(
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
  ConnectionState runNotifierBuild(
    covariant ConnectionAdapter notifier,
  ) {
    return notifier.build(
      familyKey,
    );
  }

  @override
  Override overrideWith(ConnectionAdapter Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConnectionAdapterProvider._internal(
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
  NotifierProviderElement<ConnectionAdapter, ConnectionState> createElement() {
    return _ConnectionAdapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectionAdapterProvider && other.familyKey == familyKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, familyKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ConnectionAdapterRef on NotifierProviderRef<ConnectionState> {
  /// The parameter `familyKey` of this provider.
  GlobalKey<State<StatefulWidget>>? get familyKey;
}

class _ConnectionAdapterProviderElement
    extends NotifierProviderElement<ConnectionAdapter, ConnectionState>
    with ConnectionAdapterRef {
  _ConnectionAdapterProviderElement(super.provider);

  @override
  GlobalKey<State<StatefulWidget>>? get familyKey =>
      (origin as ConnectionAdapterProvider).familyKey;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
