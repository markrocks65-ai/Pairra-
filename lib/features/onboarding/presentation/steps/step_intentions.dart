import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/onboarding_options.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 3 — dating intentions (multiple selections allowed).
class StepIntentions extends ConsumerWidget {
  const StepIntentions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return QuestionBlock(
      title: 'What are you here for?',
      hint: 'Pick all that apply — there\'s no wrong answer.',
      child: MultiSelectChips(
        options: OnboardingOptions.datingIntentions,
        selectedIds: draft.datingIntentions,
        onChanged: (s) =>
            controller.update((p) => p.copyWith(datingIntentions: s)),
      ),
    );
  }
}
