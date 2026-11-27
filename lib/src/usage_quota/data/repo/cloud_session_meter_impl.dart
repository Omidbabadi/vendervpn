import 'dart:async';

import 'package:vendervpn/src/usage_quota/data/datasrc/usage_quota_local_datasrc.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/cloud_session_meter.dart';

/// Client-side metering: V2Ray reports the session's total upload +
/// download, and each update counts only the bytes since the previous one.
class CloudSessionMeterImpl implements CloudSessionMeter {
  CloudSessionMeterImpl(this._local);

  final UsageQuotaLocalDatasrc _local;

  int? _lastTotal;
  bool _isTracking = false;

  @override
  bool get isTracking => _isTracking;

  @override
  void start(int sessionTotal) {
    _isTracking = true;
    _lastTotal = sessionTotal;
    unawaited(_local.saveSessionCounted(sessionTotal));
  }

  @override
  void resume() {
    _isTracking = true;
    _lastTotal = _local.sessionCounted;
  }

  @override
  int record(int sessionTotal) {
    if (!_isTracking) return 0;
    // A zero after real totals is a placeholder update, not a restart.
    if (sessionTotal == 0 && (_lastTotal ?? 0) > 0) return 0;

    final last = _lastTotal;
    _lastTotal = sessionTotal;
    unawaited(_local.saveSessionCounted(sessionTotal));
    if (last == null) return 0; // starting point only

    // If V2Ray's counter restarted, everything it reports is new.
    return sessionTotal >= last ? sessionTotal - last : sessionTotal;
  }

  @override
  void stop() {
    if (!_isTracking) return;
    _isTracking = false;
    _lastTotal = null;
    unawaited(_local.saveSessionCounted(null));
  }

  @override
  MeteredSessionEnd end() {
    // The saved total is set on every counted update and removed on a
    // normal stop, so it survives an app restart and marks a cloud session.
    final last = _lastTotal ?? _local.sessionCounted;
    final wasCloud = _isTracking || last != null;
    _isTracking = false;
    _lastTotal = null;
    unawaited(_local.saveSessionCounted(null));
    return (wasCloud: wasCloud, lastCounted: last);
  }

  @override
  Future<void> markEnded(int sessionTotal) =>
      _local.saveSessionCounted(sessionTotal);

  @override
  Future<void> clear() async {
    _isTracking = false;
    _lastTotal = null;
    await _local.saveSessionCounted(null);
  }
}
