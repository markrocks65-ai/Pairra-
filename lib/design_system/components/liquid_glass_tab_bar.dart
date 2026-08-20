import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../accessibility/accessibility_scope.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';

/// A segmented control on a Liquid Glass track, with a sliding selection
/// indicator. Use it for in-screen view switching (e.g. a profile's
/// "Overview / Compatibility / Photos"). The indicator glides between segments
/// and respects reduced motion (it snaps when motion is reduced).
class LiquidGlassTabBar extends StatelessWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 46,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    assert(labels.isNotEmpty);
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    final radius = BorderRadius.circular(AppRadius.md);

    return LiquidGlassSurface(
      level: GlassLevel.subtle,
      borderRadius: radius,
      showShadow: false,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / labels.length;
            return Stack(
              children: [
                // Sliding indicator.
                AnimatedPositioned(
                  duration: reduceMotion ? AppMotion.instant : AppMotion.base,
                  curve: AppMotion.standard,
                  left: segmentWidth * selectedIndex,
                  top: 0,
                  bottom: 0,
                  width: segmentWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                  ),
                ),
                // Labels.
                Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: PressableScale(
                          onTap: () => onChanged(i),
                          pressedScale: 0.96,
                          child: Center(
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.buttonSmall.copyWith(
                                color: i == selectedIndex
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
