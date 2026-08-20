import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../onboarding/domain/onboarding_profile.dart';

/// A clear indicator of exactly what information is public on the profile.
/// Shown at the top of Preview so users can see, at a glance, what a
/// non-matched viewer can and can't see.
class PrivacyIndicator extends StatelessWidget {
  const PrivacyIndicator({super.key, required this.profile});

  final OnboardingProfile profile;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final rows = <(String, bool)>[
      ('Name & age', true),
      ('Approximate distance', p.privacy.showDistance),
      ('Gender', p.visibilityOf('gender') == FieldVisibility.public),
      ('Orientation', p.visibilityOf('orientation') == FieldVisibility.public),
      ('Compatibility (position)',
          p.visibilityOf('roles') == FieldVisibility.public),
      ('What you\'re looking for', p.privacy.preferencesVisible),
      ('Shown in discovery', p.privacy.appearInDiscovery),
    ];

    return LiquidGlassCard(
      level: GlassLevel.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Text('What others can see', style: AppTypography.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final r in rows) _Row(label: r.$1, visible: r.$2),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.visible});

  final String label;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            visible ? Icons.visibility_outlined : Icons.lock_outline,
            size: 16,
            color: visible ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label,
                style: AppTypography.bodyMedium.copyWith(
                  color: visible
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                )),
          ),
          Text(
            visible ? 'Public' : 'Hidden',
            style: AppTypography.caption.copyWith(
              color: visible ? AppColors.success : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
