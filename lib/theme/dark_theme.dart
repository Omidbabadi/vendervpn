import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

ColorScheme colorSchemeDark = ColorScheme.fromSeed(
  primary: const Color.fromARGB(255, 0, 255, 179),
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 32, 37, 37),
  surfaceDim: const Color.fromARGB(255, 46, 46, 46),
  onSurface: const Color(0xff181818),
  onPrimaryContainer: Colors.black54,
  primaryContainer: const Color(0xffADAEF1),
  onSecondary: const Color(0xfff5eff3),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: colorSchemeDark,
  brightness: Brightness.dark,
  textTheme: GoogleFonts.latoTextTheme().copyWith(
    headlineSmall: const TextStyle(color: Color.fromARGB(255, 223, 223, 223)),
    titleMedium: const TextStyle(color: Color(0xfff5eff3)),
  ),
);
