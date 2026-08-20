import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/preference_config.dart';
import '../../../../design_system/design_system.dart';
import '../../application/onboarding_controller.dart';
import '../../application/onboarding_providers.dart';
import '../../domain/onboarding_profile.dart';
import '../widgets/onboarding_controls.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 2 — gender identity and sexual orientation, each with a visibility
/// control. Deliberately never assumes a default, and offers self-describe.
class StepIdentity extends ConsumerStatefulWidget {
  const StepIdentity({super.key});

  @override
  ConsumerState<StepIdentity> createState() => _StepIdentityState();
}

class _StepIdentityState extends ConsumerState<StepIdentity> {
  late final TextEditingController _genderCustom;
  late final TextEditingController _orientationCustom;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingControllerProvider).draft;
    _genderCustom = TextEditingController(text: draft.genderCustom ?? '');
    _orientationCustom =
        TextEditingController(text: draft.orientationCustom ?? '');
  }

  @override
  void dispose() {
    _genderCustom.dispose();
    _orientationCustom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionBlock(
          title: 'Gender identity',
          child: SingleSelectChips(
            options: PreferenceConfig.genderIdentities,
            selectedId: draft.genderId,
            onChanged: (id) =>
                controller.update((p) => p.copyWith(genderId: id)),
          ),
        ),
        if (draft.genderId == 'self_describe') ...[
          const SizedBox(height: AppSpacing.md),
          LiquidGlassTextField(
            controller: _genderCustom,
            hint: 'Describe your gender',
            onChanged: (v) =>
                controller.update((p) => p.copyWith(genderCustom: v)),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        VisibilitySelector(
          label: 'Show gender to',
          value: draft.visibilityOf('gender'),
          onChanged: (v) => _setVisibility(controller, draft, 'gender', v),
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuestionBlock(
          title: 'Sexual orientation',
          child: SingleSelectChips(
            options: PreferenceConfig.orientations,
            selectedId: draft.orientationId,
            onChanged: (id) =>
                controller.update((p) => p.copyWith(orientationId: id)),
          ),
        ),
        if (draft.orientationId == 'self_describe') ...[
          const SizedBox(height: AppSpacing.md),
          LiquidGlassTextField(
            controller: _orientationCustom,
            hint: 'Describe your orientation',
            onChanged: (v) =>
                controller.update((p) => p.copyWith(orientationCustom: v)),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        VisibilitySelector(
          label: 'Show orientation to',
          value: draft.visibilityOf('orientation'),
          onChanged: (v) => _setVisibility(controller, draft, 'orientation', v),
        ),
      ],
    );
  }

  void _setVisibility(
    OnboardingController controller,
    OnboardingProfile draft,
    String field,
    FieldVisibility v,
  ) {
    final next = Map<String, FieldVisibility>.from(draft.fieldVisibility);
    next[field] = v;
    controller.update((p) => p.copyWith(fieldVisibility: next));
  }
}
