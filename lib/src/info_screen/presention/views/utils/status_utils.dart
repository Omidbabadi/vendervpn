import 'package:vendervpn/src/info_screen/presention/views/status_screen.dart';

class StatusUtils {
  const StatusUtils(this.message, this.status);

  final String message;
  final Status status;

  StatusUtils copyWith({String? message, Status? status}) =>
      StatusUtils(message ?? this.message, status ?? this.status);
}
