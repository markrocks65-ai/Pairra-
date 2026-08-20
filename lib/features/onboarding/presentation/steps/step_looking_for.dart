import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/onboarding_options.dart';
import '../../../../core/config/option.dart';
import '../../../../core/config/preference_config.dart';
import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 5 — what the user is looking for: preferred roles, relationship type,
/// age range, distance, and lifestyle/communication. These preferences are the
/// other half of the reciprocal-compatibility equation.
class StepLookingFor extends ConsumerWidget {
  const StepLookingFor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final lf = draft.lookingFor;
    final ls = draft.lifestyle;

    final roleSet = PreferenceConfig.roleSetFor(
      genderId: draft.genderId,
      orientationId: draft.orientationId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (roleSet != null) ...[
          QuestionBlock(
            title: 'Preferred ${roleSet.label.toLowerCase()}',
            hint: 'What are you looking for in a match?',
            child: MultiSelectChips(
              options: roleSet.roles,
              selectedIds: lf.preferredRoles,
              onChanged: (s) => controller.update(
                  (p) => p.copyWith(lookingFor: lf.copyWith(preferredRoles: s))),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        QuestionBlock(
          title: 'Relationship type',
          child: MultiSelectChips(
            options: OnboardingOptions.relationshipTypes,
            selectedIds: lf.relationshipTypes,
            onChanged: (s) => controller.update((p) =>
                p.copyWith(lookingFor: lf.copyWith(relationshipTypes: s))),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuestionBlock(
          title: 'Age range',
          trailing: Text('${lf.ageMin}–${lf.ageMax}',
              style: AppTypography.number),
          child: RangeSlider(
            values: RangeValues(lf.ageMin.toDouble(), lf.ageMax.toDouble()),
            min: 18,
            max: 80,
            divisions: 62,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.border,
            labels: RangeLabels('${lf.ageMin}', '${lf.ageMax}'),
            onChanged: (v) => controller.update((p) => p.copyWith(
                  lookingFor: lf.copyWith(
                    ageMin: v.start.round(),
                    ageMax: v.end.round(),
                  ),
                )),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        QuestionBlock(
          title: 'Maximum distance',
          trailing: Text('${lf.maxDistanceKm.round()} km',
              style: AppTypography.number),
          child: Slider(
            value: lf.maxDistanceKm.clamp(5, 160).toDouble(),
            min: 5,
            max: 160,
            divisions: 31,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.border,
            label: '${lf.maxDistanceKm.round()} km',
            onChanged: (v) => controller.update((p) =>
                p.copyWith(lookingFor: lf.copyWith(maxDistanceKm: v))),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _single(context, 'Smoking', OnboardingOptions.smoking, ls.smoking,
            (id) => controller.update((p) => p.copyWith(lifestyle: ls.copyWith(smoking: id)))),
        _single(context, 'Drinking', OnboardingOptions.drinking, ls.drinking,
            (id) => controller.update((p) => p.copyWith(lifestyle: ls.copyWith(drinking: id)))),
        _single(context, 'Pets', OnboardingOptions.pets, ls.pets,
            (id) => controller.update((p) => p.copyWith(lifestyle: ls.copyWith(pets: id)))),
        _single(context, 'Children', OnboardingOptions.children, ls.children,
            (id) => controller.update((p) => p.copyWith(lifestyle: ls.copyWith(children: id)))),
        QuestionBlock(
          title: 'Communication style',
          child: MultiSelectChips(
            options: OnboardingOptions.communicationStyles,
            selectedIds: ls.communicationStyles,
            onChanged: (s) => controller.update((p) =>
                p.copyWith(lifestyle: ls.copyWith(communicationStyles: s))),
          ),
        ),
      ],
    );
  }

  Widget _single(BuildContext context, String title, List<Option> options,
      String? selectedId, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: QuestionBlock(
        title: title,
        child: SingleSelectChips(
          options: options,
          selectedId: selectedId,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
