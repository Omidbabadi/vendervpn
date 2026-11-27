import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/services/injection_container.dart';
import 'package:vendervpn/src/usage_quota/domain/repo/cloud_session_meter.dart';

/// The cloud session meter, as a provider so tests can replace it.
final cloudSessionMeterProvider = Provider<CloudSessionMeter>(
  (ref) => sl<CloudSessionMeter>(),
);
