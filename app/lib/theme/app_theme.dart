import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Typographic roles. Archivo = display & prices (tabular), Commissioner = body,
/// Spline Sans Mono = technical labels / eyebrows. `tracking` is expressed in em
/// and converted to logical pixels (`size * tracking`).
class PkText {
  static const List<FontFeature> _tabular = [
    FontFeature.tabularFigures(),
    FontFeature.liningFigures(),
  ];

  static TextStyle display({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w800,
    double tracking = -0.02,
    double height = 1.08,
  }) =>
      GoogleFonts.archivo(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * tracking,
        height: height,
      );

  static TextStyle heading({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w700,
    double tracking = -0.015,
    double height = 1.12,
  }) =>
      GoogleFonts.archivo(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * tracking,
        height: height,
      );

  static TextStyle price({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w800,
    double tracking = -0.015,
    double height = 1.0,
  }) =>
      GoogleFonts.archivo(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * tracking,
        height: height,
        fontFeatures: _tabular,
      );

  static TextStyle body({
    double size = PkFont.base,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) =>
      GoogleFonts.commissioner(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle label({
    double size = PkFont.sm,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double height = 1.3,
  }) =>
      GoogleFonts.commissioner(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle mono({
    double size = PkFont.xs,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double tracking = 0.0,
    double height = 1.2,
  }) =>
      GoogleFonts.splineSansMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * tracking,
        height: height,
        fontFeatures: _tabular,
      );

  /// All-caps mono eyebrow with wide tracking (0.12em). Caller upper-cases text.
  static TextStyle eyebrow({
    double size = PkFont.xs,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.splineSansMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * 0.12,
        height: 1.2,
      );
}

class PkTheme {
  static ThemeData _build(PkColors pk, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: pk.canvas,
      canvasColor: pk.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pk.primary,
        brightness: brightness,
        primary: pk.primary,
        onPrimary: pk.onPrimary,
        surface: pk.surface,
        onSurface: pk.textPrimary,
        error: pk.danger,
      ),
      textTheme: GoogleFonts.commissionerTextTheme(base.textTheme).apply(
        bodyColor: pk.textPrimary,
        displayColor: pk.textPrimary,
      ),
      dividerColor: pk.borderSubtle,
      splashFactory: InkSparkle.splashFactory,
      extensions: [pk],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: pk.primary,
        selectionColor: pk.primary.withValues(alpha: 0.22),
        selectionHandleColor: pk.primary,
      ),
    );
  }

  static ThemeData get light => _build(PkColors.light, Brightness.light);
  static ThemeData get dark => _build(PkColors.dark, Brightness.dark);
}
