import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme colorSchemeLight = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromARGB(255, 56, 255, 245),
  surface: const Color.fromARGB(255, 248, 255, 252),
  onSurface: const Color.fromARGB(255, 110, 107, 109),
  onPrimaryContainer: Colors.black54,
  primaryContainer: const Color.fromARGB(255, 217, 205, 255),
  onSecondary: const Color(0xfff5eff3),
);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: colorSchemeLight,
  brightness: Brightness.light,
  textTheme: GoogleFonts.latoTextTheme(),
);
