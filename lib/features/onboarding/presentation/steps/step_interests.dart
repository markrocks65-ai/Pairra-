import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/onboarding_options.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 6 — interests. Multi-select; we gently nudge for at least three.
class StepInterests extends ConsumerWidget {
  const StepInterests({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final count = draft.interests.length;

    return QuestionBlock(
      title: 'What are you into?',
      hint: count < 3
          ? 'Choose at least 3 to help us find your people.'
          : '$count selected — nice.',
      child: MultiSelectChips(
        options: OnboardingOptions.interests,
        selectedIds: draft.interests,
        onChanged: (s) => controller.update((p) => p.copyWith(interests: s)),
      ),
    );
  }
}
