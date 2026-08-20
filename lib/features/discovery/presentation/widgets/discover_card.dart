import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../profile/application/profile_labels.dart';
import '../../../profile/presentation/widgets/profile_photo_view.dart';
import '../../application/discovery_controller.dart';

/// The premium discovery card: a large photo is the visual focus, with Liquid
/// Glass overlays for the compatibility badge and the profile-info panel. The
/// whole surface (or the "View profile" affordance) opens the full detail.
///
/// Intentionally NOT a dense grid tile and NOT a swipe-stack — one considered
/// recommendation at a time.
class DiscoverCard extends StatelessWidget {
  const DiscoverCard({
    super.key,
    required this.scored,
    required this.onViewProfile,
  });

  final ScoredCandidate scored;
  final VoidCallback onViewProfile;

  String? get _distanceLine {
    final d = scored.distanceKm;
    if (d != null) return '~${d.round()} km away';
    return scored.candidate.profile.location.areaLabel;
  }

  @override
  Widget build(BuildContext context) {
    final p = scored.candidate.profile;
    final name = (p.displayName ?? '').trim();
    final age = p.age;
    final title = age != null && name.isNotEmpty ? '$name, $age' : name;
    final seed = p.photos.isNotEmpty ? p.photos.first.placeholderSeed : 'p1';
    final monogram = name.isEmpty ? '' : name.characters.first.toUpperCase();
    final intents = ProfileLabels.intentions(p.datingIntentions);
    final interests = ProfileLabels.interests(p.interests).take(4).toList();

    return GestureDetector(
      onTap: onViewProfile,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProfilePhotoView(seed: seed, monogram: monogram),
            // Bottom scrim for legibility — photo stays the focus.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xE60A0E17)],
                ),
              ),
            ),
            // Compatibility badge (glass).
            Positioned(
              top: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _CompatibilityBadge(
                percent: scored.score.percent,
                band: scored.score.band.label,
              ),
            ),
            // Info panel (glass).
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: LiquidGlassSurface(
                level: GlassLevel.standard,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title.isEmpty ? 'Someone' : title,
                            style: AppTypography.headingMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (p.verification.hasBadge) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.verified,
                              color: AppColors.accent, size: 20),
                        ],
                      ],
                    ),
                    if (_distanceLine != null || intents.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (_distanceLine != null) ...[
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(_distanceLine!,
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                          if (_distanceLine != null && intents.isNotEmpty)
                            Text('  ·  ',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.textMuted)),
                          if (intents.isNotEmpty)
                            Flexible(
                              child: Text(intents.first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary)),
                            ),
                        ],
                      ),
                    ],
                    if (interests.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [for (final i in interests) _MiniPill(i)],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text('View profile',
                            style: AppTypography.buttonSmall
                                .copyWith(color: AppColors.accent)),
                        const Icon(Icons.chevron_right,
                            size: 18, color: AppColors.accent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({required this.percent, required this.band});

  final int percent;
  final String band;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      level: GlassLevel.prominent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$percent%',
              style: AppTypography.number
                  .copyWith(fontSize: 20, color: AppColors.textPrimary)),
          Text('$band match',
              style: AppTypography.caption.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs + 1),
      decoration: BoxDecoration(
        color: AppColors.glassBase.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}
