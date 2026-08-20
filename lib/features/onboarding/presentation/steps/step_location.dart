import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../../domain/onboarding_profile.dart';

/// Step 9 — location. We ask only when it's useful (to find nearby people),
/// explain why, and only ever store/derive an APPROXIMATE position. Exact
/// coordinates are never captured or shown.
///
/// (Real OS location permission needs a platform plugin; this mock sets a
/// coarse approximate area so the flow is complete.)
class StepLocation extends ConsumerWidget {
  const StepLocation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final granted = draft.location.granted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiquidGlassCard(
          level: GlassLevel.subtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.public, color: AppColors.accent, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Why we ask', style: AppTypography.headingSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'PAIRRA uses your general area to show how far away someone is. '
                'We only ever use an approximate distance — never your exact '
                'location, and it\'s never shown to anyone on a map.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (granted)
          LiquidGlassCard(
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    draft.location.areaLabel ?? 'Approximate location set',
                    style: AppTypography.bodyLarge,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.update(
                      (p) => p.copyWith(location: const ApproximateLocation())),
                  child: Text('Remove',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted)),
                ),
              ],
            ),
          )
        else
          LiquidGlassButton(
            label: 'Use my approximate location',
            icon: Icons.my_location,
            expand: true,
            onPressed: () => controller.update(
              (p) => p.copyWith(
                // Coarsened on purpose — never an exact position.
                location: const ApproximateLocation(
                  granted: true,
                  areaLabel: 'Near you (approximate)',
                  approxLat: 40.7,
                  approxLng: -74.0,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'You can skip this and add it later. Distance features work best with '
          'an approximate area.',
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
