import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../places/places.dart';
import '../../application/cost_estimator.dart';
import 'venue_bits.dart';

/// The signature date card built from a [Venue]: photo, name, estimated cost
/// range, approximate distance, vibe tags, a safety cue, and the two actions
/// (View place / Build date). Liquid Glass surface; photo-forward but calm.
class VenueDateCard extends StatelessWidget {
  const VenueDateCard({
    super.key,
    required this.venue,
    required this.onViewPlace,
    required this.onBuildDate,
    this.eyebrow,
  });

  final Venue venue;
  final VoidCallback onViewPlace;
  final VoidCallback onBuildDate;

  /// Small label above the name (e.g. "TONIGHT" or the category).
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final v = venue;
    final cost = CostRange(v.costForTwoMin, v.costForTwoMax);
    final vibes = v.vibes.take(2).map(vibeLabel).toList();
    final highlyRated = (v.rating ?? 0) >= 4.5;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VenueThumb(seed: v.imageSeed),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((eyebrow ?? v.category.label).toUpperCase(),
                        style: AppTypography.label),
                    const SizedBox(height: 2),
                    Text(v.name,
                        style: AppTypography.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xs),
                    Text(cost.label,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          v.distanceKm != null
                              ? '~${approxMinutes(v.distanceKm!)} min · ${v.areaLabel}'
                              : v.areaLabel,
                          style: AppTypography.caption,
                        ),
                        if (v.rating != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          RatingBadge(rating: v.rating!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final vibe in vibes) _Tag(vibe),
              if (highlyRated) _Tag('Highly rated'),
              SafetyChip(label: v.safety),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: LiquidGlassButton(
                  label: 'View place',
                  variant: GlassButtonVariant.glass,
                  height: 46,
                  onPressed: onViewPlace,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LiquidGlassButton(
                  label: 'Build date',
                  height: 46,
                  onPressed: onBuildDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}
