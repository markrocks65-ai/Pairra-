import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/glass_style.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';

/// A circular Liquid Glass icon button — the standard affordance for back
/// arrows, overflow menus and top-bar actions across PAIRRA.
///
/// It bakes in the accessibility every icon-only control needs: a required
/// [semanticLabel] (icons carry no text for screen readers), a guaranteed
/// ~48dp hit target regardless of the visual size, keyboard focus, and a pill
/// focus ring. Use this instead of hand-rolling `PressableScale` +
/// `LiquidGlassSurface` so those never drift apart again.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.level = GlassLevel.standard,
    this.iconSize = 18,
    this.iconColor = AppColors.textPrimary,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Announced by screen readers (e.g. "Back", "Settings", "More options").
  final String semanticLabel;

  final GlassLevel level;
  final double iconSize;
  final Color iconColor;

  /// Shows a small accent dot (e.g. unread indicator).
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final pill = BorderRadius.circular(AppRadius.pill);
    return PressableScale(
      pressedScale: 0.94,
      onTap: onTap,
      semanticLabel: semanticLabel,
      minTapTarget: const Size.square(48),
      focusBorderRadius: pill,
      child: LiquidGlassSurface(
        level: level,
        borderRadius: pill,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            if (badge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
