import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';

/// A floating action button rendered as prominent Liquid Glass. Supports a
/// circular icon-only form and an extended (icon + label) pill. Uses the
/// prominent glass level so it reads as the primary floating affordance
/// without a loud accent fill.
class LiquidGlassFloatingActionButton extends StatelessWidget {
  const LiquidGlassFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.tint = false,
    this.size = 60,
  });

  /// Icon-only (circular) constructor omits [label].
  final IconData icon;
  final VoidCallback? onPressed;

  /// When provided, renders an extended pill FAB.
  final String? label;

  /// When true, the icon/label take the accent color for extra emphasis.
  final bool tint;

  /// Diameter for the icon-only form (ignored when [label] is set).
  final double size;

  @override
  Widget build(BuildContext context) {
    final extended = label != null;
    final radius = BorderRadius.circular(AppRadius.pill);
    final fg = tint ? AppColors.accent : AppColors.textPrimary;

    final child = extended
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: AppSpacing.sm),
                Text(label!,
                    style: AppTypography.button.copyWith(color: fg)),
              ],
            ),
          )
        : SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 24, color: fg),
          );

    return PressableScale(
      onTap: onPressed,
      pressedScale: 0.92,
      child: LiquidGlassSurface(
        level: GlassLevel.prominent,
        borderRadius: radius,
        child: child,
      ),
    );
  }
}
