import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import 'liquid_glass_card.dart';

/// A titled grouping surface — an eyebrow label / title / optional trailing
/// action above a glass container of content. Use it to structure a screen
/// into calm, scannable blocks (e.g. "Compatibility", "About", "Interests").
class LiquidGlassSection extends StatelessWidget {
  const LiquidGlassSection({
    super.key,
    required this.child,
    this.title,
    this.eyebrow,
    this.trailing,
    this.level = GlassLevel.subtle,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final String? title;

  /// Small uppercase label above the title (e.g. section category).
  final String? eyebrow;

  /// Optional trailing widget in the header row (e.g. a "See all" action).
  final Widget? trailing;

  final GlassLevel level;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || eyebrow != null || trailing != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              right: AppSpacing.xs,
              bottom: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (eyebrow != null)
                        Text(eyebrow!.toUpperCase(),
                            style: AppTypography.label
                                .copyWith(color: AppColors.accent)),
                      if (eyebrow != null && title != null)
                        const SizedBox(height: AppSpacing.xxs),
                      if (title != null)
                        Text(title!, style: AppTypography.headingSmall),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        LiquidGlassCard(level: level, padding: padding, child: child),
      ],
    );
  }
}
