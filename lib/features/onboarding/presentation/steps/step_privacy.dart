import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../application/onboarding_providers.dart';
import '../../domain/onboarding_profile.dart';
import '../widgets/onboarding_controls.dart';
import '../widgets/question_block.dart';

/// Step 10 — privacy & discovery controls. Sensible, privacy-preserving
/// defaults; the user can open up or lock down as they wish.
class StepPrivacy extends ConsumerWidget {
  const StepPrivacy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider).draft;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final privacy = draft.privacy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionBlock(
          title: 'Who can see my profile',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final v in FieldVisibility.values)
                LiquidGlassChip(
                  label: v.label,
                  selected: v == privacy.profileVisibility,
                  onTap: () => controller.update((p) =>
                      p.copyWith(privacy: privacy.copyWith(profileVisibility: v))),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingToggleRow(
          title: 'Show my preferences',
          subtitle: 'Let others see what you\'re looking for.',
          value: privacy.preferencesVisible,
          onChanged: (v) => controller.update(
              (p) => p.copyWith(privacy: privacy.copyWith(preferencesVisible: v))),
        ),
        SettingToggleRow(
          title: 'Appear in discovery',
          subtitle: 'Turn off to browse without being shown to others.',
          value: privacy.appearInDiscovery,
          onChanged: (v) => controller.update(
              (p) => p.copyWith(privacy: privacy.copyWith(appearInDiscovery: v))),
        ),
        SettingToggleRow(
          title: 'Show my distance',
          subtitle: 'Others see approximate distance only, never location.',
          value: privacy.showDistance,
          onChanged: (v) => controller.update(
              (p) => p.copyWith(privacy: privacy.copyWith(showDistance: v))),
        ),
        SettingToggleRow(
          title: 'Appear to people outside my range',
          subtitle: 'Allow matches slightly beyond your distance preference.',
          value: privacy.appearOutsideRange,
          onChanged: (v) => controller.update((p) =>
              p.copyWith(privacy: privacy.copyWith(appearOutsideRange: v))),
        ),
      ],
    );
  }
}
