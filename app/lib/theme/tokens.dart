import 'package:flutter/material.dart';

/// πόσο κάνει — design tokens ported from the design-system CSS custom properties.
///
/// `PkColors` is a [ThemeExtension] carrying every *semantic* color. Read it
/// from any widget with `context.pk`. Light and dark variants mirror the
/// `:root` / `[data-theme="dark"]` token sets exactly.

extension PkContext on BuildContext {
  PkColors get pk => Theme.of(this).extension<PkColors>()!;
}

@immutable
class PkColors extends ThemeExtension<PkColors> {
  // Surfaces
  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color surfaceInverse;
  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color onBrand;
  // Borders
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  // Primary (brand green)
  final Color primary;
  final Color primaryHover;
  final Color primaryActive;
  final Color primarySoft;
  final Color primarySoftBorder;
  final Color onPrimary;
  // Savings / good price
  final Color save;
  final Color saveText;
  final Color saveSoft;
  // Deals (terracotta)
  final Color deal;
  final Color dealHover;
  final Color dealText;
  final Color dealSoft;
  final Color dealSoftBorder;
  // Warning / stale (amber)
  final Color warning;
  final Color warningText;
  final Color warningSoft;
  // Info / international (sea)
  final Color info;
  final Color infoText;
  final Color infoSoft;
  // Danger
  final Color danger;
  final Color dangerHover;
  final Color dangerSoft;
  final Color onDanger;
  // Skeleton shimmer
  final Color skeletonBase;
  final Color skeletonSheen;
  // Price-spread gradient midpoint (amber-400)
  final Color spreadMid;
  // Shadows (warm-tinted)
  final List<BoxShadow> shadowXs;
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;
  final bool isDark;

  const PkColors({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceInverse,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.onBrand,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.primary,
    required this.primaryHover,
    required this.primaryActive,
    required this.primarySoft,
    required this.primarySoftBorder,
    required this.onPrimary,
    required this.save,
    required this.saveText,
    required this.saveSoft,
    required this.deal,
    required this.dealHover,
    required this.dealText,
    required this.dealSoft,
    required this.dealSoftBorder,
    required this.warning,
    required this.warningText,
    required this.warningSoft,
    required this.info,
    required this.infoText,
    required this.infoSoft,
    required this.danger,
    required this.dangerHover,
    required this.dangerSoft,
    required this.onDanger,
    required this.skeletonBase,
    required this.skeletonSheen,
    required this.spreadMid,
    required this.shadowXs,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
    required this.isDark,
  });

  static const light = PkColors(
    canvas: Color(0xFFF7F5EF),
    surface: Color(0xFFFFFDF8),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF1EEE4),
    surfaceInverse: Color(0xFF1C1A16),
    textPrimary: Color(0xFF1C1A16),
    textSecondary: Color(0xFF6B655A),
    textMuted: Color(0xFF8A8478),
    textInverse: Color(0xFFFFFDF8),
    onBrand: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFE1DCCD),
    borderDefault: Color(0xFFD2CCBA),
    borderStrong: Color(0xFFB6AF9C),
    primary: Color(0xFF1F6B4A),
    primaryHover: Color(0xFF185A3E),
    primaryActive: Color(0xFF124730),
    primarySoft: Color(0xFFEEF5F0),
    primarySoftBorder: Color(0xFFD8E9DF),
    onPrimary: Color(0xFFFFFFFF),
    save: Color(0xFF1F6B4A),
    saveText: Color(0xFF185A3E),
    saveSoft: Color(0xFFEEF5F0),
    deal: Color(0xFFE8462D),
    dealHover: Color(0xFFCF3A23),
    dealText: Color(0xFFA82D19),
    dealSoft: Color(0xFFFDEEE9),
    dealSoftBorder: Color(0xFFFAD9CF),
    warning: Color(0xFFB67D09),
    warningText: Color(0xFF7C5400),
    warningSoft: Color(0xFFFBF1D9),
    info: Color(0xFF2F6F8F),
    infoText: Color(0xFF245870),
    infoSoft: Color(0xFFE7F0F4),
    danger: Color(0xFFB3271D),
    dangerHover: Color(0xFF971C14),
    dangerSoft: Color(0xFFFBE9E7),
    onDanger: Color(0xFFFFFFFF),
    skeletonBase: Color(0xFFF1EEE4),
    skeletonSheen: Color(0xFFFAF8F1),
    spreadMid: Color(0xFFD99812),
    shadowXs: [BoxShadow(color: Color(0x0F1C1A16), offset: Offset(0, 1), blurRadius: 2)],
    shadowSm: [
      BoxShadow(color: Color(0x141C1A16), offset: Offset(0, 1), blurRadius: 3),
      BoxShadow(color: Color(0x0A1C1A16), offset: Offset(0, 1), blurRadius: 2),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x141C1A16), offset: Offset(0, 4), blurRadius: 12),
      BoxShadow(color: Color(0x0A1C1A16), offset: Offset(0, 2), blurRadius: 4),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x1F1C1A16), offset: Offset(0, 12), blurRadius: 28),
      BoxShadow(color: Color(0x0F1C1A16), offset: Offset(0, 4), blurRadius: 10),
    ],
    isDark: false,
  );

  static const dark = PkColors(
    canvas: Color(0xFF14130F),
    surface: Color(0xFF1D1B15),
    surfaceRaised: Color(0xFF24211A),
    surfaceSunken: Color(0xFF1A1813),
    surfaceInverse: Color(0xFFF5F1E6),
    textPrimary: Color(0xFFF5F1E6),
    textSecondary: Color(0xFFB6AF9C),
    textMuted: Color(0xFF948D79),
    textInverse: Color(0xFF1C1A16),
    onBrand: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFF2C281D),
    borderDefault: Color(0xFF3A3424),
    borderStrong: Color(0xFF4D4632),
    primary: Color(0xFF3FA978),
    primaryHover: Color(0xFF58BD8E),
    primaryActive: Color(0xFF74CDA3),
    primarySoft: Color(0xFF18261E),
    primarySoftBorder: Color(0xFF234C39),
    onPrimary: Color(0xFF08160F),
    save: Color(0xFF4FB98A),
    saveText: Color(0xFF6BCB9F),
    saveSoft: Color(0xFF16241C),
    deal: Color(0xFFF0654A),
    dealHover: Color(0xFFF47D65),
    dealText: Color(0xFFF5A08C),
    dealSoft: Color(0xFF2A1712),
    dealSoftBorder: Color(0xFF4D2419),
    warning: Color(0xFFE0A82A),
    warningText: Color(0xFFF0C662),
    warningSoft: Color(0xFF2A2110),
    info: Color(0xFF5FA6C4),
    infoText: Color(0xFF84C0D9),
    infoSoft: Color(0xFF14242B),
    danger: Color(0xFFE06054),
    dangerHover: Color(0xFFEA7468),
    dangerSoft: Color(0xFF2C1512),
    onDanger: Color(0xFFFFFFFF),
    skeletonBase: Color(0xFF221F17),
    skeletonSheen: Color(0xFF2C281D),
    spreadMid: Color(0xFFD99812),
    shadowXs: [BoxShadow(color: Color(0x661C1A16), offset: Offset(0, 1), blurRadius: 2)],
    shadowSm: [
      BoxShadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 3),
      BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 2),
    ],
    shadowMd: [
      BoxShadow(color: Color(0x80000000), offset: Offset(0, 4), blurRadius: 14),
      BoxShadow(color: Color(0x4D000000), offset: Offset(0, 2), blurRadius: 4),
    ],
    shadowLg: [
      BoxShadow(color: Color(0x99000000), offset: Offset(0, 14), blurRadius: 32),
      BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    isDark: true,
  );

  @override
  PkColors copyWith() => this;

  @override
  PkColors lerp(ThemeExtension<PkColors>? other, double t) {
    if (other is! PkColors) return this;
    // Hard-switch palette at the midpoint; theme toggle is a discrete change.
    return t < 0.5 ? this : other;
  }
}

/// Corner radii (px). Card = 16 so hero image corners morph cleanly card→detail.
class PkRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 36;
  static const double pill = 999;
  static const double card = 16;
}

/// 4px spacing grid.
class PkSpace {
  static const double x1 = 4;
  static const double x1_5 = 6;
  static const double x2 = 8;
  static const double x2_5 = 10;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x7 = 28;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
  static const double x20 = 80;
  static const double x24 = 96;
}

/// Type scale (px), 16px root.
class PkFont {
  static const double xs2 = 11;
  static const double xs = 12;
  static const double sm = 13;
  static const double base = 15;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 22;
  static const double xl2 = 28;
  static const double xl3 = 36;
  static const double xl4 = 48;
  static const double xl5 = 60;
  static const double xl6 = 76;
}

/// Layout constants.
class PkLayout {
  static const double railCategory = 264;
  static const double railBasket = 340;
  static const double headerHeight = 72;
  static const double container2xl = 1440;
  static const double bpPhone = 600;
  static const double bpTablet = 1024;
  static const double bpDesktop = 1080; // app kit collapses rails below this
}

/// Motion durations.
class PkDur {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 450);
  static const Duration count = Duration(milliseconds: 600);
  static const Duration spark = Duration(milliseconds: 600);
  static const Duration staggerStep = Duration(milliseconds: 40);
}

/// Easing curves (mirror motion.css).
class PkCurve {
  static const Curve standard = Cubic(0.4, 0, 0.2, 1);
  static const Curve out = Cubic(0, 0, 0.2, 1);
  static const Curve inCurve = Cubic(0.4, 0, 1, 1);
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);
}
