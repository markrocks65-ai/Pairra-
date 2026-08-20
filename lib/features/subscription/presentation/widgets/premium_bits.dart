import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/premium_feature.dart';
import '../../domain/subscription_models.dart';

IconData premiumFeatureIcon(PremiumFeature f) => switch (f) {
      PremiumFeature.unlimitedLikes => Icons.favorite,
      PremiumFeature.advancedFilters => Icons.tune,
      PremiumFeature.compatibilityBreakdown => Icons.insights,
      PremiumFeature.advancedDiscovery => Icons.explore_outlined,
      PremiumFeature.incognito => Icons.visibility_off_outlined,
      PremiumFeature.travelMode => Icons.flight_takeoff,
      PremiumFeature.boost => Icons.rocket_launch_outlined,
      PremiumFeature.advancedDatePlanning => Icons.event_note_outlined,
      PremiumFeature.aiAssistant => Icons.auto_awesome,
      PremiumFeature.moreDateRecommendations => Icons.place_outlined,
      PremiumFeature.readReceipts => Icons.done_all,
      PremiumFeature.profileAnalytics => Icons.bar_chart,
    };

/// A subtle premium marker — small pill, never loud.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentWash,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, size: 12, color: AppColors.accent),
          const SizedBox(width: 3),
          Text('Premium',
              style: AppTypography.caption.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}

/// A compact benefit row.
class PremiumFeatureTile extends StatelessWidget {
  const PremiumFeatureTile({super.key, required this.feature});

  final PremiumFeature feature;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(premiumFeatureIcon(feature), size: 20, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title, style: AppTypography.bodyLarge),
                Text(feature.description, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A selectable pricing option. Price text comes straight from the service.
class PackageOption extends StatelessWidget {
  const PackageOption({
    super.key,
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: LiquidGlassSurface(
        level: GlassLevel.standard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        showShadow: false,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? AppColors.accent : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(package.title, style: AppTypography.headingSmall),
                          if (package.savingsLabel != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _SavingsTag(package.savingsLabel!),
                          ],
                        ],
                      ),
                      if (package.perMonthString != null)
                        Text(package.perMonthString!,
                            style: AppTypography.caption),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(package.priceString, style: AppTypography.headingSmall),
                    Text(package.period.suffix, style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavingsTag extends StatelessWidget {
  const _SavingsTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.successWash,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label,
          style: AppTypography.caption.copyWith(color: AppColors.success)),
    );
  }
}
