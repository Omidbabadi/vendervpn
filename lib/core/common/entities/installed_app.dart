import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// An app installed on the device, as shown in the per-app proxy list.
class InstalledApp extends Equatable {
  const InstalledApp({
    required this.name,
    required this.packageName,
    required this.isSystemApp,
    this.icon,
  });

  final String name;

  /// Application id, e.g. `com.example.app`.
  final String packageName;

  final bool isSystemApp;

  /// PNG bytes of the icon, or null when not requested or not available.
  final Uint8List? icon;

  @override
  List<Object?> get props => [name, packageName, isSystemApp];
}
