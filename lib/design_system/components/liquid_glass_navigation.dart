import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../accessibility/accessibility_scope.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';

/// A single destination in [LiquidGlassNavigation].
@immutable
class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// PAIRRA's primary navigation: a floating Liquid Glass bar that hosts the
/// top-level destinations (Discover · Matches · Dates · Messages · Profile).
/// It is `SafeArea`-aware and detaches from the screen edges to read as a
/// floating premium control. Selection animates subtly; reduced motion is
/// respected.
class LiquidGlassNavigation extends StatelessWidget {
  const LiquidGlassNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      0,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: margin,
        child: LiquidGlassSurface(
          level: GlassLevel.prominent,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    final color = selected ? AppColors.accent : AppColors.textMuted;
    final iconData =
        selected ? (item.selectedIcon ?? item.icon) : item.icon;

    // Announce as a single "<label>, selected, tab" node (MergeSemantics folds
    // the visual + tap + selected state together); ExcludeSemantics stops the
    // inner label Text from duplicating it.
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: PressableScale(
          onTap: onTap,
          pressedScale: 0.94,
          semanticLabel: item.label,
          focusBorderRadius: BorderRadius.circular(AppRadius.lg),
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: reduceMotion ? AppMotion.instant : AppMotion.base,
              curve: AppMotion.standard,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color:
                    selected ? AppColors.accentWash : const Color(0x00000000),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, size: 22, color: color),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
