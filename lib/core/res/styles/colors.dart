import 'package:flutter/material.dart';
import 'package:vendervpn/core/extensions/context_ext.dart';
import 'package:vendervpn/core/res/styles/pallet.dart';

/// Legacy colour access, kept while call sites move to `context.pallet`
/// (phase 6b–6d). Values come from [PalletSeeds] / [OrbSpectrum]; removed in 6e.
abstract class Colours {
  // ─── Cirus Luminous Light & Obsidian Dark Canvas ───
  static const Color lightBackgroundColor = PalletSeeds.lightBackground;
  static const Color darkBackgroundColor = PalletSeeds.darkBackground;

  static const Color lightCardSurface = PalletSeeds.lightCardSurface;
  static const Color darkCardSurface = PalletSeeds.darkCardSurface;

  static const Color lightThemePrimaryTextColor = PalletSeeds.lightTextPrimary;
  static const Color darkThemePrimaryTextColor = PalletSeeds.darkTextPrimary;

  static const Color subtitleGrey = PalletSeeds.subtitleGrey;

  // ─── Iridescent Orb Face Spectrum ───
  static const Color orbCoral = OrbSpectrum.coral;
  static const Color orbRose = OrbSpectrum.rose;
  static const Color orbMagenta = OrbSpectrum.magenta;
  static const Color orbViolet = OrbSpectrum.violet;
  static const Color orbCyan = OrbSpectrum.cyan;
  static const Color orbAzure = OrbSpectrum.azure;
  static const Color orbEmerald = OrbSpectrum.emerald;

  // Soft Status Pills
  static const Color pastelAmberBg = PalletSeeds.pastelAmberBg;
  static const Color pastelAmberFg = PalletSeeds.pastelAmberFg;

  static const Color pastelLilacBg = PalletSeeds.pastelLilacBg;
  static const Color pastelLilacFg = PalletSeeds.pastelLilacFg;

  static const Color pastelRoseBg = PalletSeeds.pastelRoseBg;
  static const Color pastelRoseFg = PalletSeeds.pastelRoseFg;

  static const Color pastelMintBg = PalletSeeds.pastelMintBg;
  static const Color pastelMintFg = PalletSeeds.pastelMintFg;

  /// Picks light or dark exactly as before (no theme-switch animation), so
  /// these helpers look the same until their callers move to `context.pallet`.
  static Pallet _p(BuildContext context) =>
      context.isDarkMode ? Pallet.dark : Pallet.light;

  static Color scaffoldBg(BuildContext context) => _p(context).background;

  static Color classicAdabtiveTextColor(BuildContext context) =>
      _p(context).textPrimary;

  static Color cardSurface(BuildContext context) => _p(context).cardSurface;

  static Color softChipBg(BuildContext context) => _p(context).softChipBg;

  static Color subtleBorder(BuildContext context) => _p(context).subtleBorder;

  static List<BoxShadow> softCardShadow(BuildContext context) =>
      _p(context).cardShadow;
}
