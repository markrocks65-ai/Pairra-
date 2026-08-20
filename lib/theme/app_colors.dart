import 'package:flutter/widgets.dart';

/// PAIRRA color system — the single source of truth for every color in the app.
///
/// The palette is dark-first, built from black, deep navy, charcoal and slate,
/// with white/soft-grey text and a restrained indigo accent. Bright colors are
/// intentionally avoided; the only saturated colors are semantic status colors
/// (success / warning / error), and money uses the restrained green success
/// token — never neon.
///
/// Do NOT introduce raw `Color(0x...)` values in feature code. Add a semantic
/// token here instead so the whole product stays consistent and themeable.
@immutable
abstract final class AppColors {
  // --------------------------------------------------------------------------
  // Backgrounds & surfaces (deep navy → charcoal → slate)
  // --------------------------------------------------------------------------

  /// App background. Near-black with a deep-navy bias.
  static const Color background = Color(0xFF05070D);

  /// Base surface for cards/containers that sit on the background.
  static const Color surface = Color(0xFF0B0F18);

  /// Elevated surface (menus, elevated cards, opaque glass fallback).
  static const Color surfaceElevated = Color(0xFF141A28);

  /// A second, brighter elevation step for stacked surfaces.
  static const Color surfaceHigh = Color(0xFF1C2333);

  /// Base fill used to build translucent "glass" surfaces. This is the color
  /// that gets a low alpha applied to it in [glassTint]; on its own it is the
  /// opaque fallback used when transparency is reduced.
  static const Color glassBase = Color(0xFF10151F);

  // --------------------------------------------------------------------------
  // Text
  // --------------------------------------------------------------------------

  /// Primary text — soft white (never pure #FFFFFF, which glares on dark).
  static const Color textPrimary = Color(0xFFF3F5FA);

  /// Secondary text — muted slate-grey for supporting copy.
  static const Color textSecondary = Color(0xFFA7B0C2);

  /// Muted text — captions, timestamps, disabled labels. Tuned to ~4.8:1 on
  /// [background] so even this lowest tier clears WCAG AA for small text.
  static const Color textMuted = Color(0xFF737D8F);

  /// Text/icon color to place on top of the [accent] fill.
  static const Color onAccent = Color(0xFFFFFFFF);

  // --------------------------------------------------------------------------
  // Borders & dividers (built from white at low alpha for depth over glass)
  // --------------------------------------------------------------------------

  /// Standard hairline border.
  static const Color border = Color(0x14FFFFFF); // white @ 8%

  /// Slightly stronger border for interactive/selected states.
  static const Color borderStrong = Color(0x24FFFFFF); // white @ 14%

  /// High-contrast border (used when high-contrast accessibility is on).
  static const Color borderHighContrast = Color(0x66FFFFFF); // white @ 40%

  /// The subtle top highlight that gives glass its "lit edge".
  static const Color highlight = Color(0x1FFFFFFF); // white @ 12%

  // --------------------------------------------------------------------------
  // Accent (restrained indigo — interactive states only)
  // --------------------------------------------------------------------------

  static const Color accent = Color(0xFF6E8BFF);
  static const Color accentPressed = Color(0xFF5A78F0);
  static const Color accentMuted = Color(0xFF2A3350);

  /// Soft translucent accent wash for selected chips / highlighted surfaces.
  static const Color accentWash = Color(0x226E8BFF); // accent @ ~13%

  // --------------------------------------------------------------------------
  // Semantic status colors (restrained, not neon)
  // --------------------------------------------------------------------------

  /// Success / money-positive (the only place green is used).
  static const Color success = Color(0xFF3FB98A);
  static const Color warning = Color(0xFFE0A745);
  static const Color error = Color(0xFFE5565B);

  static const Color successWash = Color(0x223FB98A);
  static const Color warningWash = Color(0x22E0A745);
  static const Color errorWash = Color(0x22E5565B);

  // --------------------------------------------------------------------------
  // Shadows & scrims
  // --------------------------------------------------------------------------

  /// Soft shadow used beneath glass and elevated surfaces.
  static const Color shadow = Color(0x66000000);

  /// Scrim placed behind modals / bottom sheets / overlays.
  static const Color scrim = Color(0xB3000000); // black @ 70%
}
