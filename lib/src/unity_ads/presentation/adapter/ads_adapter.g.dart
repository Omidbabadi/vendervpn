// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adsAdapterHash() => r'e45aa4720f35680bb9ecd57a2c30fd02f480c068';

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

abstract class _$AdsAdapter extends BuildlessNotifier<AdsState> {
  late final GlobalKey<State<StatefulWidget>>? familyKey;

  AdsState build([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]);
}

/// See also [AdsAdapter].
@ProviderFor(AdsAdapter)
const adsAdapterProvider = AdsAdapterFamily();

/// See also [AdsAdapter].
class AdsAdapterFamily extends Family<AdsState> {
  /// See also [AdsAdapter].
  const AdsAdapterFamily();

  /// See also [AdsAdapter].
  AdsAdapterProvider call([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]) {
    return AdsAdapterProvider(
      familyKey,
    );
  }

  @override
  AdsAdapterProvider getProviderOverride(
    covariant AdsAdapterProvider provider,
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
  String? get name => r'adsAdapterProvider';
}

/// See also [AdsAdapter].
class AdsAdapterProvider extends NotifierProviderImpl<AdsAdapter, AdsState> {
  /// See also [AdsAdapter].
  AdsAdapterProvider([
    GlobalKey<State<StatefulWidget>>? familyKey,
  ]) : this._internal(
          () => AdsAdapter()..familyKey = familyKey,
          from: adsAdapterProvider,
          name: r'adsAdapterProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$adsAdapterHash,
          dependencies: AdsAdapterFamily._dependencies,
          allTransitiveDependencies:
              AdsAdapterFamily._allTransitiveDependencies,
          familyKey: familyKey,
        );

  AdsAdapterProvider._internal(
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
  AdsState runNotifierBuild(
    covariant AdsAdapter notifier,
  ) {
    return notifier.build(
      familyKey,
    );
  }

  @override
  Override overrideWith(AdsAdapter Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdsAdapterProvider._internal(
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
  NotifierProviderElement<AdsAdapter, AdsState> createElement() {
    return _AdsAdapterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdsAdapterProvider && other.familyKey == familyKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, familyKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AdsAdapterRef on NotifierProviderRef<AdsState> {
  /// The parameter `familyKey` of this provider.
  GlobalKey<State<StatefulWidget>>? get familyKey;
}

class _AdsAdapterProviderElement
    extends NotifierProviderElement<AdsAdapter, AdsState> with AdsAdapterRef {
  _AdsAdapterProviderElement(super.provider);

  @override
  GlobalKey<State<StatefulWidget>>? get familyKey =>
      (origin as AdsAdapterProvider).familyKey;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
