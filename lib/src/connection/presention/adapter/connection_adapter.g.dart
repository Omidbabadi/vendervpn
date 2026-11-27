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

String _$connectionAdapterHash() => r'c45210d5f14175d5db1e105323f8df6313f2a527';

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
