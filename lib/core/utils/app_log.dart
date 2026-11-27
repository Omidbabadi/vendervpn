import 'package:flutter/foundation.dart';

/// Debug-only logger. Prints nothing in profile/release builds, so log
/// messages (and anything interpolated into them) never reach device logs
/// of shipped apps.
void appLog(Object? message) {
  if (kDebugMode) debugPrint('$message');
}

/// Debug-only stack trace logger. See [appLog].
void appLogStack({StackTrace? stackTrace, String? label}) {
  if (kDebugMode) debugPrintStack(stackTrace: stackTrace, label: label);
}
