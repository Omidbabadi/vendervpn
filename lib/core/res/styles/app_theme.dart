import 'package:flutter/material.dart';
import 'package:vendervpn/core/res/styles/pallet.dart';

/// The app's light and dark [ThemeData], each carrying its [Pallet].
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: OrbSpectrum.violet,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Pallet.light.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Pallet.light.background,
      foregroundColor: Pallet.light.textPrimary,
      elevation: 0,
    ),
    extensions: const [Pallet.light],
    useMaterial3: true,
  );

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: OrbSpectrum.violet,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Pallet.dark.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Pallet.dark.background,
      foregroundColor: Pallet.dark.textPrimary,
      elevation: 0,
    ),
    extensions: const [Pallet.dark],
    useMaterial3: true,
  );
}
