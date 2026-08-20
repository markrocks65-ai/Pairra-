import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/dob_field.dart';
import '../widgets/question_block.dart';

/// Step 1 — display name, profile photo (placeholder avatar) and date of birth
/// (age is derived, never typed).
class StepBasics extends ConsumerStatefulWidget {
  const StepBasics({super.key});

  @override
  ConsumerState<StepBasics> createState() => _StepBasicsState();
}

class _StepBasicsState extends ConsumerState<StepBasics> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: ref.read(onboardingControllerProvider).draft.displayName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AvatarPicker(
            displayName: draft.displayName,
            selectedSeed: draft.avatarSeed,
            onChanged: (seed) =>
                controller.update((p) => p.copyWith(avatarSeed: seed)),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuestionBlock(
          title: 'Display name',
          hint: 'This is how you\'ll appear on PAIRRA.',
          child: LiquidGlassTextField(
            controller: _name,
            hint: 'Your name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.done,
            onChanged: (v) =>
                controller.update((p) => p.copyWith(displayName: v)),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuestionBlock(
          title: 'Date of birth',
          hint: 'You must be 18+. We only ever show your age, never this date.',
          child: DobField(
            value: draft.dateOfBirth,
            onChanged: (d) =>
                controller.update((p) => p.copyWith(dateOfBirth: d)),
          ),
        ),
      ],
    );
  }
}
