import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../application/icebreakers.dart';

/// Optional conversation starters shown only on a fresh conversation. Tapping a
/// suggestion places it in the composer for the user to edit and send — it is
/// never sent automatically, and is clearly framed as a suggestion.
class IcebreakerBar extends StatelessWidget {
  const IcebreakerBar({
    super.key,
    required this.icebreakers,
    required this.onPick,
  });

  final List<Icebreaker> icebreakers;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (icebreakers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  size: 15, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${icebreakers.first.reason} Suggested openers — tap to edit, '
                  'not sent automatically.',
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: icebreakers.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final ib = icebreakers[i];
              return PressableScale(
                pressedScale: 0.95,
                onTap: () => onPick(ib.suggestion),
                child: LiquidGlassSurface(
                  level: GlassLevel.subtle,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  showShadow: false,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Center(
                    child: Text(ib.suggestion,
                        style: AppTypography.buttonSmall
                            .copyWith(color: AppColors.textPrimary)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
