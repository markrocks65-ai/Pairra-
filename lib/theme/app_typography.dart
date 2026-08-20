import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// PAIRRA typography — a centralized, premium type system.
///
/// Two families:
///  • **Sora** for display/headings — a modern geometric face that reads as
///    confident and masculine without novelty.
///  • **Inter** for body/UI — exceptionally legible at small sizes.
///  • Tabular figures ([number], [compatibilityScore]) use Inter with
///    tabular figures so numbers don't jitter when animating.
///
/// Every `TextStyle` in PAIRRA should come from here. Colors default to the
/// dark-theme tokens but can be overridden per-use with `.copyWith(color:)`.
@immutable
abstract final class AppTypography {
  static TextStyle _display(double size, FontWeight weight, double height,
          {double letterSpacing = -0.5}) =>
      GoogleFonts.sora(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: AppColors.textPrimary,
      );

  static TextStyle _text(double size, FontWeight weight, double height,
          {Color color = AppColors.textPrimary, double letterSpacing = 0}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  // Display / headings -------------------------------------------------------

  /// Large hero heading (onboarding, empty states).
  static TextStyle get displayLarge => _display(40, FontWeight.w700, 1.1);

  /// Screen title.
  static TextStyle get headingLarge => _display(28, FontWeight.w700, 1.15);

  /// Section heading.
  static TextStyle get headingMedium => _display(22, FontWeight.w600, 1.2);

  /// Sub-section / card title.
  static TextStyle get headingSmall =>
      _text(18, FontWeight.w600, 1.25, letterSpacing: -0.2);

  // Body ---------------------------------------------------------------------

  static TextStyle get bodyLarge => _text(16, FontWeight.w400, 1.5);
  static TextStyle get bodyMedium => _text(14, FontWeight.w400, 1.5);

  /// Secondary supporting text.
  static TextStyle get bodySecondary =>
      _text(14, FontWeight.w400, 1.5, color: AppColors.textSecondary);

  // Labels & captions --------------------------------------------------------

  /// Field labels / section eyebrows (often uppercased with tracking).
  static TextStyle get label => _text(12, FontWeight.w600, 1.3,
      color: AppColors.textSecondary, letterSpacing: 0.8);

  /// Small captions, timestamps, helper text.
  static TextStyle get caption =>
      _text(12, FontWeight.w400, 1.4, color: AppColors.textMuted);

  // Buttons ------------------------------------------------------------------

  static TextStyle get button =>
      _text(15, FontWeight.w600, 1.0, letterSpacing: 0.2);

  static TextStyle get buttonSmall =>
      _text(13, FontWeight.w600, 1.0, letterSpacing: 0.2);

  // Numbers ------------------------------------------------------------------

  /// Tabular numeric style for stats/metrics (won't jitter when animating).
  static TextStyle get number => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// The large compatibility score readout (e.g. "92"). Display face, tight
  /// tracking, tabular figures for smooth count-up animation.
  static TextStyle get compatibilityScore => GoogleFonts.sora(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
