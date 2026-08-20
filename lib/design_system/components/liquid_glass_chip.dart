import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../accessibility/accessibility_scope.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';
import '../../theme/glass_style.dart';

/// A pill-shaped glass chip for tags, filters and selectable options
/// (interests, roles, preferences). Supports a selected state that tints with
/// the restrained accent wash. Selection changes animate subtly and respect
/// reduced motion.
class LiquidGlassChip extends StatelessWidget {
  const LiquidGlassChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    final radius = BorderRadius.circular(AppRadius.pill);

    final labelColor = selected ? AppColors.textPrimary : AppColors.textSecondary;

    final inner = AnimatedContainer(
      duration: reduceMotion ? AppMotion.instant : AppMotion.fast,
      curve: AppMotion.standard,
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.accentWash : null,
        borderRadius: radius,
        // Only the selected chip carries an edge — unselected chips rely on the
        // glass fill, so a Wrap of options reads calm instead of a grid of
        // hairlines.
        border: selected
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 15,
                color: selected ? AppColors.accent : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs + 2),
          ],
          Text(label,
              style: AppTypography.buttonSmall.copyWith(color: labelColor)),
        ],
      ),
    );

    // Unselected chips sit on a faint glass base; selected chips use the tinted
    // border/fill above (over the same glass) for a lit, chosen feel.
    final chip = LiquidGlassSurface(
      level: GlassLevel.subtle,
      borderRadius: radius,
      showShadow: false,
      showBorder: false,
      child: inner,
    );

    if (onTap == null) return chip;
    return PressableScale(onTap: onTap, pressedScale: 0.94, child: chip);
  }
}
