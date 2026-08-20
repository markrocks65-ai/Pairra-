import 'package:flutter/widgets.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// How "present" a glass surface is. Higher levels tint darker and (for the
/// focal levels) blur the backdrop, creating a stronger sense of depth.
///
/// Performance note: a real backdrop blur ([BackdropFilter]) resamples the
/// content behind it every frame, so each blurred surface on screen has a real
/// cost — and it compounds badly when many appear at once (a list of chips,
/// message bubbles, or profile pills). PAIRRA therefore reserves true blur for
/// the small number of *focal* surfaces:
///  • [subtle]     — chips, list rows, pills, bubbles. **No backdrop blur**: a
///    translucent fill over the dark background reads as glass at a fraction of
///    the cost, and these appear many-at-a-time in scrolls.
///  • [standard]   — cards/sheets/buttons. Moderate blur.
///  • [prominent]  — focal moments (compatibility cards, the nav bar, match
///    dialogs). Strongest blur.
enum GlassLevel { subtle, standard, prominent }

/// The concrete visual recipe for a Liquid Glass surface. This is the single
/// definition of what "PAIRRA glass" looks like — every glass component builds
/// from a [GlassStyle], so tuning the look here updates the whole product.
///
/// PAIRRA glass is deliberately restrained: a dark translucent fill (not a
/// bright frosted pane), a low-alpha white border, a soft top highlight for a
/// "lit edge", and a soft shadow for depth. Blur is kept moderate so the
/// effect reads as premium hardware, not generic glassmorphism, and so text
/// stays legible over photography.
@immutable
class GlassStyle {
  const GlassStyle({
    required this.blurSigma,
    required this.tint,
    required this.borderColor,
    required this.highlightColor,
    required this.shadows,
    required this.opaqueFallback,
  });

  /// Gaussian blur sigma applied to the backdrop. `0` disables the blur.
  final double blurSigma;

  /// Translucent fill painted over the blurred backdrop.
  final Color tint;

  /// Hairline border color.
  final Color borderColor;

  /// Top-edge highlight color (fades to transparent).
  final Color highlightColor;

  /// Drop shadow(s) beneath the surface.
  final List<BoxShadow> shadows;

  /// Fully-opaque fill used when transparency is reduced or the device opts
  /// out of blur. Must be legible with zero translucency.
  final Color opaqueFallback;

  /// The default PAIRRA recipe for a given [GlassLevel].
  factory GlassStyle.forLevel(GlassLevel level) {
    switch (level) {
      case GlassLevel.subtle:
        return const GlassStyle(
          // No backdrop blur: these render many-at-a-time in lists, so they use
          // a slightly denser translucent fill instead of a per-widget resample.
          blurSigma: 0,
          tint: Color(0xCC10151F),
          borderColor: AppColors.border,
          highlightColor: AppColors.highlight,
          shadows: [
            BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 10)),
          ],
          opaqueFallback: AppColors.surface,
        );
      case GlassLevel.standard:
        return const GlassStyle(
          blurSigma: 18,
          tint: Color(0xB310151F),
          borderColor: AppColors.border,
          highlightColor: AppColors.highlight,
          shadows: [
            BoxShadow(color: Color(0x80000000), blurRadius: 32, offset: Offset(0, 14)),
          ],
          opaqueFallback: AppColors.surfaceElevated,
        );
      case GlassLevel.prominent:
        return const GlassStyle(
          blurSigma: 24,
          tint: Color(0xCC141A28),
          borderColor: AppColors.borderStrong,
          highlightColor: AppColors.highlight,
          shadows: AppShadows.floating,
          opaqueFallback: AppColors.surfaceHigh,
        );
    }
  }

  /// Returns a copy with the backdrop blur removed but translucency kept — the
  /// "reduce visual effects" performance path. The tint is nudged toward the
  /// opaque fallback so content stays legible without the blur that normally
  /// separates it from the busy backdrop; shape, border and shadow are intact.
  GlassStyle withoutBlur() {
    if (blurSigma == 0) return this;
    return GlassStyle(
      blurSigma: 0,
      // ~35% toward the opaque fill compensates for the missing blur.
      tint: Color.alphaBlend(opaqueFallback.withValues(alpha: 0.35), tint),
      borderColor: borderColor,
      highlightColor: highlightColor,
      shadows: shadows,
      opaqueFallback: opaqueFallback,
    );
  }

  /// Returns a copy with transparency removed — an opaque, blur-free surface
  /// used for the reduced-transparency / low-performance fallback. Border and
  /// shadow are preserved so the component keeps its shape and depth.
  GlassStyle toOpaque({bool highContrast = false}) {
    return GlassStyle(
      blurSigma: 0,
      tint: opaqueFallback,
      borderColor: highContrast ? AppColors.borderHighContrast : borderColor,
      highlightColor: const Color(0x00000000),
      shadows: shadows,
      opaqueFallback: opaqueFallback,
    );
  }
}
