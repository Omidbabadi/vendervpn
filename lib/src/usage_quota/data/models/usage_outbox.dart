import 'dart:math' as math;

import 'package:vendervpn/core/utils/typedefs.dart';

/// Cloud usage counted on this device that the server hasn't confirmed yet.
///
/// New traffic goes into [pendingBytes]. To report, a batch is frozen into
/// the in-flight slot with its own [reportId] and saved before it is sent;
/// retries reuse that ID, so the server never counts a batch twice, even if
/// the app is killed mid-request. Traffic arriving meanwhile stays pending.
class UsageOutbox {
  const UsageOutbox({
    this.pendingBytes = 0,
    this.reportId,
    this.inFlightBytes = 0,
  });

  factory UsageOutbox.fromMap(DataMap map) {
    return UsageOutbox(
      pendingBytes: (map['pendingBytes'] as num?)?.toInt() ?? 0,
      reportId: map['reportId'] as String?,
      inFlightBytes: (map['inFlightBytes'] as num?)?.toInt() ?? 0,
    );
  }

  final int pendingBytes;
  final String? reportId;
  final int inFlightBytes;

  bool get hasInFlight => reportId != null && inFlightBytes > 0;

  /// Everything the server hasn't confirmed: pending plus in flight.
  int get unreportedBytes => pendingBytes + (hasInFlight ? inFlightBytes : 0);

  UsageOutbox add(int bytes) => UsageOutbox(
    pendingBytes: pendingBytes + bytes,
    reportId: reportId,
    inFlightBytes: inFlightBytes,
  );

  /// Moves up to [maxBytes] of pending usage into the in-flight slot.
  UsageOutbox freeze(String id, int maxBytes) {
    final bytes = math.min(pendingBytes, maxBytes);
    return UsageOutbox(
      pendingBytes: pendingBytes - bytes,
      reportId: id,
      inFlightBytes: bytes,
    );
  }

  /// The server confirmed the in-flight batch.
  UsageOutbox acknowledged() => UsageOutbox(pendingBytes: pendingBytes);

  DataMap toMap() => {
    'pendingBytes': pendingBytes,
    'reportId': reportId,
    'inFlightBytes': inFlightBytes,
  };
}
