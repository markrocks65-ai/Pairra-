import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../theme/glass_style.dart';
import '../accessibility/accessibility_scope.dart';
import '../accessibility/accessibility_settings.dart';

/// The single Liquid Glass primitive. **Every** glass component in PAIRRA is
/// built on top of this — do not re-implement `BackdropFilter` glass anywhere
/// else. Tuning the look here (or in [GlassStyle]) updates the entire product.
///
/// The recipe: a soft drop shadow for depth, a clipped rounded rectangle, an
/// optional backdrop blur, a dark translucent fill with a subtle "lit" top
/// edge (from the highlight token), and a low-alpha border. It is purely
/// presentational — interaction (tap, press) is layered on by the components
/// that wrap it (card, button, chip, FAB…).
///
/// Accessibility: when `reduceTransparency` is active (OS or in-app toggle),
/// the surface automatically renders opaque with no blur while keeping its
/// shape, border and shadow — via [GlassStyle.toOpaque]. `highContrast`
/// strengthens the border.
class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    this.level = GlassLevel.standard,
    this.style,
    this.borderRadius,
    this.padding,
    this.showShadow = true,
    this.showBorder = true,
    this.child,
  });

  /// Preset intensity. Ignored if [style] is supplied.
  final GlassLevel level;

  /// Explicit style override. When null, `GlassStyle.forLevel(level)` is used.
  final GlassStyle? style;

  /// Corner radius. Defaults to a rounded rect appropriate for cards/sheets.
  final BorderRadius? borderRadius;

  final EdgeInsetsGeometry? padding;
  final bool showShadow;
  final bool showBorder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final a11y = PairraA11y.of(context);
    final radius = borderRadius ?? BorderRadius.circular(20);

    // Resolve the visual recipe, degrading in two graceful steps:
    //  • reduceTransparency (accessibility) → fully opaque, no blur.
    //  • reduceGlassEffects (performance / lower-end) → keep the translucent
    //    look but drop the expensive backdrop blur.
    // The whole glass system hinges on these fallbacks.
    GlassStyle resolved = style ?? GlassStyle.forLevel(level);
    if (a11y.reduceTransparency) {
      resolved = resolved.toOpaque(highContrast: a11y.highContrast);
    } else if (a11y.reduceGlassEffects && resolved.blurSigma > 0) {
      resolved = resolved.withoutBlur();
    }

    // A "lit" top edge: blend the highlight over the tint so it reads as a
    // subtle rim of light without washing over the child content.
    final topColor = Color.alphaBlend(resolved.highlightColor, resolved.tint);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, resolved.tint],
          stops: const [0.0, 0.6],
        ),
        borderRadius: radius,
        border: showBorder
            ? Border.all(
                color: resolved.borderColor,
                width: a11y.highContrast ? 1.5 : 1,
              )
            : null,
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    // Only pay for a BackdropFilter when there is actually blur to apply.
    if (resolved.blurSigma > 0) {
      surface = BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: resolved.blurSigma,
          sigmaY: resolved.blurSigma,
        ),
        child: surface,
      );
    }

    surface = ClipRRect(borderRadius: radius, child: surface);

    if (showShadow && resolved.shadows.isNotEmpty) {
      surface = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: resolved.shadows,
        ),
        child: surface,
      );
    }

    return surface;
  }
}

/// Convenience extension so widgets can branch on reduced transparency without
/// importing the settings type directly.
extension ResolvedA11yGlass on ResolvedAccessibility {
  bool get prefersOpaque => reduceTransparency;
}
