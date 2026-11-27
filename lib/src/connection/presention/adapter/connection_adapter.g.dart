// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_adapter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the tunnel lifecycle and holds the connection state. Everything
/// that depends on the node type (quota, ads, metering) is in the
/// [ConnectStrategy] picked for the node, so this class never checks it.

@ProviderFor(ConnectionAdapter)
final connectionAdapterProvider = ConnectionAdapterProvider._();

/// Runs the tunnel lifecycle and holds the connection state. Everything
/// that depends on the node type (quota, ads, metering) is in the
/// [ConnectStrategy] picked for the node, so this class never checks it.
final class ConnectionAdapterProvider
    extends $NotifierProvider<ConnectionAdapter, ConnectionState> {
  /// Runs the tunnel lifecycle and holds the connection state. Everything
  /// that depends on the node type (quota, ads, metering) is in the
  /// [ConnectStrategy] picked for the node, so this class never checks it.
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

String _$connectionAdapterHash() => r'ed68d55feb48895e0c5cbd28b38c4891579674a8';

/// Runs the tunnel lifecycle and holds the connection state. Everything
/// that depends on the node type (quota, ads, metering) is in the
/// [ConnectStrategy] picked for the node, so this class never checks it.

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
