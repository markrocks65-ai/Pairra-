import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';

/// Final step — celebrates completion and generates the initial compatibility
/// profile as a "match readiness" estimate. The number counts up for a premium
/// moment, but the copy is explicit that this is an ESTIMATE, not a precise or
/// scientific score.
class CompleteStep extends ConsumerWidget {
  const CompleteStep({super.key, required this.onEnter});

  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final readiness = draft.readinessEstimate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Appear(
          child: Text('Your PAIRRA profile is ready.',
              textAlign: TextAlign.center, style: AppTypography.headingLarge),
        ),
        const SizedBox(height: AppSpacing.sm),
        Appear(
          delay: const Duration(milliseconds: 120),
          child: Text(
            'We\'ve built your initial compatibility profile from what you '
            'shared.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Appear(
          delay: const Duration(milliseconds: 260),
          beginScale: 0.9,
          child: LiquidGlassCard(
            level: GlassLevel.prominent,
            padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
            child: Column(
              children: [
                Text('MATCH READINESS', style: AppTypography.label),
                const SizedBox(height: AppSpacing.lg),
                AnimatedCompatibilityScore(
                  score: readiness,
                  showPercentSign: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'An estimate of how well we can match you right now — based '
                  'on the info you provided. Compatibility isn\'t an exact '
                  'science, and this will sharpen as you add more.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Appear(
          delay: const Duration(milliseconds: 420),
          child: LiquidGlassButton(
            label: 'Enter PAIRRA',
            icon: Icons.arrow_forward,
            expand: true,
            onPressed: onEnter,
          ),
        ),
      ],
    );
  }
}
