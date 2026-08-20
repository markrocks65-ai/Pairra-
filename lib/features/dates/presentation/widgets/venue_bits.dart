import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../places/places.dart';
import '../../../profile/presentation/widgets/profile_photo_view.dart';
import '../../domain/date_criteria.dart';

/// Rough travel-time estimate from an approximate distance. Presented as "~N
/// min" — never precise, and never derived from the user's exact location.
int approxMinutes(double distanceKm) => (distanceKm * 3).round().clamp(1, 999);

String vibeLabel(String id) {
  for (final o in DateOptions.vibes) {
    if (o.id == id) return o.label;
  }
  return id;
}

/// Gradient placeholder thumbnail (reuses the profile photo gradients). Swaps
/// for a real venue photo when a places API is connected.
class VenueThumb extends StatelessWidget {
  const VenueThumb({super.key, required this.seed, this.size = 72});
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: size,
        height: size,
        child: ProfilePhotoView(seed: seed, showMonogram: false),
      ),
    );
  }
}

/// The subtle, always-visible safety cue for a venue.
class SafetyChip extends StatelessWidget {
  const SafetyChip({super.key, required this.label});
  final SafetyLabel label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successWash,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, size: 12, color: AppColors.success),
          const SizedBox(width: 4),
          Text(label.label,
              style: AppTypography.caption.copyWith(color: AppColors.success)),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.count});
  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: AppColors.warning),
        const SizedBox(width: 3),
        Text(rating.toStringAsFixed(1),
            style: AppTypography.bodyMedium),
        if (count != null) ...[
          const SizedBox(width: 3),
          Text('($count)', style: AppTypography.caption),
        ],
      ],
    );
  }
}

/// Honest notice that venue data is sample/placeholder until a real places API
/// is connected — so nothing is misrepresented as a real business.
class SampleDataNotice extends StatelessWidget {
  const SampleDataNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Sample venues shown for now. Real local businesses appear once a '
              'places provider is connected.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}
