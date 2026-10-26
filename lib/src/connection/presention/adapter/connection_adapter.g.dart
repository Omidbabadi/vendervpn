// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectionAdapter)
final connectionAdapterProvider = ConnectionAdapterProvider._();

final class ConnectionAdapterProvider
    extends $NotifierProvider<ConnectionAdapter, ConnectionState> {
  ConnectionAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionAdapterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionAdapterHash();

  @$internal
  @override
  ConnectionAdapter create() => ConnectionAdapter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionState>(value),
    );
  }
}

String _$connectionAdapterHash() => r'eed9dcaae76d79e16376ac785b17b7d7a294d542';

abstract class _$ConnectionAdapter extends $Notifier<ConnectionState> {
  ConnectionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConnectionState, ConnectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionState, ConnectionState>,
              ConnectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
