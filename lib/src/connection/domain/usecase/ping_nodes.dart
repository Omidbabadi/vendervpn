import 'dart:async';

import 'package:vendervpn/core/common/entities/config.dart';
import 'package:vendervpn/src/connection/domain/usecase/ping.dart';

/// Pings nodes a few at a time. A node that fails or doesn't answer in time
/// gets -1.
class PingNodes {
  const PingNodes(this._ping);

  final Ping _ping;

  static const _batchSize = 3;
  static const _timeout = Duration(milliseconds: 3500);

  /// Returns each node's delay by id. [onResult] gets every result as soon
  /// as it's in, so the list can update while the rest are still running.
  Future<Map<String, int>> call(
    List<Config> nodes, {
    void Function(String id, int delay)? onResult,
  }) async {
    final delays = <String, int>{};
    for (var i = 0; i < nodes.length; i += _batchSize) {
      final batch = nodes.skip(i).take(_batchSize);
      await Future.wait(
        batch.map((node) async {
          final delay = await _pingOne(node.configjson);
          delays[node.id] = delay;
          onResult?.call(node.id, delay);
        }),
      );
    }
    return delays;
  }

  /// Pings a single node, with the same timeout.
  Future<int> single(Config node) => _pingOne(node.configjson);

  Future<int> _pingOne(String config) async {
    try {
      final result = await _ping(config).timeout(_timeout);
      return result.fold<int>((_) => -1, (delay) => delay);
    } on Object {
      return -1;
    }
  }
}
