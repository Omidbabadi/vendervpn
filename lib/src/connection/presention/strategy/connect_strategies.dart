import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/core/common/entities/node_source.dart';
import 'package:vendervpn/src/connection/presention/strategy/cloud_connect_strategy.dart';
import 'package:vendervpn/src/connection/presention/strategy/connect_strategy.dart';
import 'package:vendervpn/src/connection/presention/strategy/local_connect_strategy.dart';
import 'package:vendervpn/src/usage_quota/presention/adapter/cloud_session_meter_provider.dart';

final connectStrategiesProvider = Provider<ConnectStrategies>((ref) {
  final meter = ref.watch(cloudSessionMeterProvider);
  return ConnectStrategies(
    cloud: CloudConnectStrategy(ref, meter),
    local: LocalConnectStrategy(ref, meter),
  );
});

/// Picks the connection steps for a node by its [NodeSource].
class ConnectStrategies {
  const ConnectStrategies({required this.cloud, required this.local});

  final CloudConnectStrategy cloud;
  final LocalConnectStrategy local;

  ConnectStrategy forConfig(Config config) => switch (config.source) {
    NodeSource.cloud => cloud,
    NodeSource.local => local,
  };
}
