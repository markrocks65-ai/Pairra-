import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/onboarding_options.dart';
import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../widgets/question_block.dart';
import '../widgets/selection_chips.dart';

/// Step 8 — ideal first dates (multi-select) and a budget comfort level.
class StepDatePrefs extends ConsumerWidget {
  const StepDatePrefs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final dp = draft.datePreferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionBlock(
          title: 'Ideal first date',
          hint: 'Pick a few that sound like you.',
          child: MultiSelectChips(
            options: OnboardingOptions.firstDates,
            selectedIds: dp.firstDates,
            onChanged: (s) => controller.update(
                (p) => p.copyWith(datePreferences: dp.copyWith(firstDates: s))),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        QuestionBlock(
          title: 'Budget comfort',
          hint: 'Sets expectations — no judgment either way.',
          child: SingleSelectChips(
            options: OnboardingOptions.budgets,
            selectedId: dp.budgetId,
            onChanged: (id) => controller.update(
                (p) => p.copyWith(datePreferences: dp.copyWith(budgetId: id))),
          ),
        ),
      ],
    );
  }
}
