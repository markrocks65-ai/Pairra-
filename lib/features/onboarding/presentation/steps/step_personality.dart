import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/onboarding_options.dart';
import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 7 — lightweight personality signals. Explicitly not a test or
/// diagnosis; answers are only used as soft compatibility signals.
class StepPersonality extends ConsumerWidget {
  const StepPersonality({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick vibes — not a personality test. There are no right answers.',
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final q in PersonalityConfig.questions) ...[
          QuestionBlock(
            title: q.prompt,
            child: SingleSelectChips(
              options: q.options,
              selectedId: draft.personality[q.id],
              allowDeselect: true,
              onChanged: (id) {
                final next = Map<String, String>.from(draft.personality);
                if (id == null) {
                  next.remove(q.id);
                } else {
                  next[q.id] = id;
                }
                controller.update((p) => p.copyWith(personality: next));
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ],
    );
  }
}
