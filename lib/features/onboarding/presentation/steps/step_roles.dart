import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/preference_config.dart';
import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../../domain/onboarding_profile.dart';
import '../widgets/onboarding_controls.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 4 — sexual compatibility (self). The role vocabulary is resolved from
/// the configurable [PreferenceConfig] based on the user's gender + orientation
/// — never hard-coded. If no set applies, this step isn't shown at all (the
/// flow omits it). This is sensitive, so it defaults to matches-only.
class StepRoles extends ConsumerWidget {
  const StepRoles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);

    final roleSet = PreferenceConfig.roleSetFor(
      genderId: draft.genderId,
      orientationId: draft.orientationId,
    );

    // Defensive: the flow shouldn't route here when null, but render gracefully.
    if (roleSet == null) {
      return Text('No compatibility options apply to your selections.',
          style: AppTypography.bodySecondary);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiquidGlassCard(
          level: GlassLevel.subtle,
          child: Row(
            children: [
              const Icon(Icons.lock_outline,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'This is private by default. You choose who can see it.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        QuestionBlock(
          title: roleSet.label,
          hint: 'Select what fits you. This helps us match reciprocally.',
          child: MultiSelectChips(
            options: roleSet.roles,
            selectedIds: draft.sexualRoles,
            onChanged: (s) => controller.update(
              (p) => p.copyWith(sexualRoles: s, roleSetId: roleSet.id),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        VisibilitySelector(
          label: 'Show this to',
          value: draft.visibilityOf('roles'),
          onChanged: (v) {
            final next =
                Map<String, FieldVisibility>.from(draft.fieldVisibility);
            next['roles'] = v;
            controller.update((p) => p.copyWith(fieldVisibility: next));
          },
        ),
      ],
    );
  }
}
