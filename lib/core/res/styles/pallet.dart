import 'package:flutter/material.dart';

/// Every raw colour value used by the theme, defined once. Read these only
/// from [Pallet], [OrbSpectrum] and the legacy `Colours` aliases.
abstract final class PalletSeeds {
  static const lightBackground = Color(0xFFF7F8FC);
  static const darkBackground = Color(0xFF06070B);

  static const lightCardSurface = Color(0xFFFFFFFF);
  static const darkCardSurface = Color(0xFF10131C);

  static const lightSoftChipBg = Color(0xFFF1F3F9);
  static const darkSoftChipBg = Color(0xFF1A1F2E);

  static const lightSubtleBorder = Color(0xFFECEEF6);
  static const darkSubtleBorder = Color(0xFF1E2333);

  static const lightTextPrimary = Color(0xFF151926);
  static const darkTextPrimary = Color(0xFFF8FAFC);

  static const subtitleGrey = Color(0xFF8A93A6);

  /// `0xFF1E293B` at alpha 0.055 (exactly what `.withValues(alpha:)` gave).
  static const lightShadow = Color.from(
    alpha: 0.055,
    red: 0x1E / 255,
    green: 0x29 / 255,
    blue: 0x3B / 255,
  );

  /// Black at alpha 0.35.
  static const darkShadow = Color.from(
    alpha: 0.35,
    red: 0,
    green: 0,
    blue: 0,
  );

  static const pastelAmberBg = Color(0xFFFFF4E5);
  static const pastelAmberFg = Color(0xFFD97706);
  static const pastelLilacBg = Color(0xFFF3E8FF);
  static const pastelLilacFg = Color(0xFF7C3AED);
  static const pastelRoseBg = Color(0xFFFFE4E8);
  static const pastelRoseFg = Color(0xFFE11D48);
  static const pastelMintBg = Color(0xFFD1FAE5);
  static const pastelMintFg = Color(0xFF059669);
}

/// The iridescent orb colours. The same in light and dark mode.
abstract final class OrbSpectrum {
  static const coral = Color(0xFFFF3B6B);
  static const rose = Color(0xFFF43F5E);
  static const magenta = Color(0xFFD946EF);
  static const violet = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF06B6D4);
  static const azure = Color(0xFF3B82F6);
  static const emerald = Color(0xFF10B981);
}

/// Background and foreground of a status pill.
@immutable
class PillTone {
  const PillTone({required this.bg, required this.fg});

  final Color bg;
  final Color fg;

  static PillTone lerp(PillTone a, PillTone b, double t) => PillTone(
    bg: Color.lerp(a.bg, b.bg, t)!,
    fg: Color.lerp(a.fg, b.fg, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is PillTone && other.bg == bg && other.fg == fg;

  @override
  int get hashCode => Object.hash(bg, fg);
}

/// Light/dark colour tokens, registered on [ThemeData.extensions].
/// Read with `context.pallet`.
@immutable
class Pallet extends ThemeExtension<Pallet> {
  const Pallet({
    required this.background,
    required this.cardSurface,
    required this.softChipBg,
    required this.subtleBorder,
    required this.textPrimary,
    required this.textSubtle,
    required this.shadow,
    required this.accent,
    required this.connected,
    required this.pillWarning,
    required this.pillAccent,
    required this.pillDanger,
    required this.pillSuccess,
  });

  static const light = Pallet(
    background: PalletSeeds.lightBackground,
    cardSurface: PalletSeeds.lightCardSurface,
    softChipBg: PalletSeeds.lightSoftChipBg,
    subtleBorder: PalletSeeds.lightSubtleBorder,
    textPrimary: PalletSeeds.lightTextPrimary,
    textSubtle: PalletSeeds.subtitleGrey,
    shadow: PalletSeeds.lightShadow,
    accent: OrbSpectrum.violet,
    connected: OrbSpectrum.emerald,
    pillWarning: _amber,
    pillAccent: _lilac,
    pillDanger: _rose,
    pillSuccess: _mint,
  );

  static const dark = Pallet(
    background: PalletSeeds.darkBackground,
    cardSurface: PalletSeeds.darkCardSurface,
    softChipBg: PalletSeeds.darkSoftChipBg,
    subtleBorder: PalletSeeds.darkSubtleBorder,
    textPrimary: PalletSeeds.darkTextPrimary,
    textSubtle: PalletSeeds.subtitleGrey,
    shadow: PalletSeeds.darkShadow,
    accent: OrbSpectrum.violet,
    connected: OrbSpectrum.emerald,
    // Same as light for now; dark-mode pill tones come in 6d.
    pillWarning: _amber,
    pillAccent: _lilac,
    pillDanger: _rose,
    pillSuccess: _mint,
  );

  static const _amber = PillTone(
    bg: PalletSeeds.pastelAmberBg,
    fg: PalletSeeds.pastelAmberFg,
  );
  static const _lilac = PillTone(
    bg: PalletSeeds.pastelLilacBg,
    fg: PalletSeeds.pastelLilacFg,
  );
  static const _rose = PillTone(
    bg: PalletSeeds.pastelRoseBg,
    fg: PalletSeeds.pastelRoseFg,
  );
  static const _mint = PillTone(
    bg: PalletSeeds.pastelMintBg,
    fg: PalletSeeds.pastelMintFg,
  );

  final Color background;
  final Color cardSurface;
  final Color softChipBg;
  final Color subtleBorder;
  final Color textPrimary;
  final Color textSubtle;
  final Color shadow;
  final Color accent;
  final Color connected;
  final PillTone pillWarning;
  final PillTone pillAccent;
  final PillTone pillDanger;
  final PillTone pillSuccess;

  /// The soft shadow under cards.
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow,
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
  ];

  @override
  Pallet copyWith({
    Color? background,
    Color? cardSurface,
    Color? softChipBg,
    Color? subtleBorder,
    Color? textPrimary,
    Color? textSubtle,
    Color? shadow,
    Color? accent,
    Color? connected,
    PillTone? pillWarning,
    PillTone? pillAccent,
    PillTone? pillDanger,
    PillTone? pillSuccess,
  }) {
    return Pallet(
      background: background ?? this.background,
      cardSurface: cardSurface ?? this.cardSurface,
      softChipBg: softChipBg ?? this.softChipBg,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSubtle: textSubtle ?? this.textSubtle,
      shadow: shadow ?? this.shadow,
      accent: accent ?? this.accent,
      connected: connected ?? this.connected,
      pillWarning: pillWarning ?? this.pillWarning,
      pillAccent: pillAccent ?? this.pillAccent,
      pillDanger: pillDanger ?? this.pillDanger,
      pillSuccess: pillSuccess ?? this.pillSuccess,
    );
  }

  @override
  Pallet lerp(covariant ThemeExtension<Pallet>? other, double t) {
    if (other is! Pallet) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return Pallet(
      background: c(background, other.background),
      cardSurface: c(cardSurface, other.cardSurface),
      softChipBg: c(softChipBg, other.softChipBg),
      subtleBorder: c(subtleBorder, other.subtleBorder),
      textPrimary: c(textPrimary, other.textPrimary),
      textSubtle: c(textSubtle, other.textSubtle),
      shadow: c(shadow, other.shadow),
      accent: c(accent, other.accent),
      connected: c(connected, other.connected),
      pillWarning: PillTone.lerp(pillWarning, other.pillWarning, t),
      pillAccent: PillTone.lerp(pillAccent, other.pillAccent, t),
      pillDanger: PillTone.lerp(pillDanger, other.pillDanger, t),
      pillSuccess: PillTone.lerp(pillSuccess, other.pillSuccess, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Pallet &&
      other.background == background &&
      other.cardSurface == cardSurface &&
      other.softChipBg == softChipBg &&
      other.subtleBorder == subtleBorder &&
      other.textPrimary == textPrimary &&
      other.textSubtle == textSubtle &&
      other.shadow == shadow &&
      other.accent == accent &&
      other.connected == connected &&
      other.pillWarning == pillWarning &&
      other.pillAccent == pillAccent &&
      other.pillDanger == pillDanger &&
      other.pillSuccess == pillSuccess;

  @override
  int get hashCode => Object.hash(
    background,
    cardSurface,
    softChipBg,
    subtleBorder,
    textPrimary,
    textSubtle,
    shadow,
    accent,
    connected,
    pillWarning,
    pillAccent,
    pillDanger,
    pillSuccess,
  );
}
