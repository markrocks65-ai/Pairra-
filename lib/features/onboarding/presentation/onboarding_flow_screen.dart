import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../navigation/app_routes.dart';
import '../application/onboarding_providers.dart';
import '../application/onboarding_steps.dart';
import '../domain/onboarding_profile.dart';
import 'steps/complete_step.dart';
import 'steps/step_basics.dart';
import 'steps/step_date_prefs.dart';
import 'steps/step_identity.dart';
import 'steps/step_interests.dart';
import 'steps/step_intentions.dart';
import 'steps/step_location.dart';
import 'steps/step_looking_for.dart';
import 'steps/step_personality.dart';
import 'steps/step_privacy.dart';
import 'steps/step_roles.dart';

/// The onboarding wizard shell. Progressive disclosure: one step at a time,
/// with a progress bar, back/skip, and a Next/Finish action. Steps and their
/// applicability come from the controller; the closing celebration is an extra
/// page after the data steps.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Mark the flow started once mounted (stops the router forcing us here).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider.notifier).markStarted();
    });
  }

  void _goHome() => context.go(AppRoutes.discover);

  bool _canAdvance(OnboardingStep step, OnboardingProfile draft) {
    // Only Step 1 is gated: a dating profile needs a name and a valid age.
    if (step == OnboardingStep.basics) {
      return (draft.displayName ?? '').trim().isNotEmpty && draft.isAdult;
    }
    return true;
  }

  Widget _stepWidget(OnboardingStep step) => switch (step) {
        OnboardingStep.basics => const StepBasics(),
        OnboardingStep.identity => const StepIdentity(),
        OnboardingStep.intentions => const StepIntentions(),
        OnboardingStep.roles => const StepRoles(),
        OnboardingStep.lookingFor => const StepLookingFor(),
        OnboardingStep.interests => const StepInterests(),
        OnboardingStep.personality => const StepPersonality(),
        OnboardingStep.datePrefs => const StepDatePrefs(),
        OnboardingStep.location => const StepLocation(),
        OnboardingStep.privacy => const StepPrivacy(),
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    if (state.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accent),
        ),
      );
    }

    final steps = state.steps;
    final page = _page.clamp(0, steps.length); // steps.length == complete page
    final onComplete = page >= steps.length;
    final reduceMotion = PairraA11y.of(context).reduceMotion;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: Column(
              children: [
                if (!onComplete)
                  _Header(
                    step: steps[page],
                    index: page,
                    total: steps.length,
                    onBack: page > 0
                        ? () => setState(() => _page = page - 1)
                        : null,
                    onSkip: () {
                      controller.skipForNow();
                      _goHome();
                    },
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: reduceMotion ? AppMotion.instant : AppMotion.base,
                    switchInCurve: AppMotion.standard,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: SingleChildScrollView(
                      key: ValueKey(page),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl,
                          AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
                      child: onComplete
                          ? CompleteStep(onEnter: _goHome)
                          : _stepWidget(steps[page]),
                    ),
                  ),
                ),
                if (!onComplete)
                  _Footer(
                    isLast: page == steps.length - 1,
                    enabled: _canAdvance(steps[page], state.draft),
                    onNext: () {
                      if (page == steps.length - 1) {
                        controller.finish();
                        setState(() => _page = steps.length);
                      } else {
                        setState(() => _page = page + 1);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.index,
    required this.total,
    required this.onBack,
    required this.onSkip,
  });

  final OnboardingStep step;
  final int index;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: onBack == null
                    ? null
                    : PressableScale(
                        onTap: onBack,
                        pressedScale: 0.9,
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 18, color: AppColors.textPrimary),
                      ),
              ),
              Expanded(
                child: _ProgressBar(value: (index + 1) / total),
              ),
              GestureDetector(
                onTap: onSkip,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: Text('Skip',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Step ${index + 1} of $total', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Text(step.title, style: AppTypography.headingLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(step.subtitle, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Stack(
        children: [
          Container(height: 6, color: AppColors.border),
          AnimatedFractionallySizedBox(
            duration: reduceMotion ? AppMotion.instant : AppMotion.base,
            curve: AppMotion.standard,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentPressed]),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isLast,
    required this.enabled,
    required this.onNext,
  });

  final bool isLast;
  final bool enabled;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
      child: LiquidGlassButton(
        label: isLast ? 'Finish' : 'Continue',
        icon: isLast ? Icons.check : null,
        expand: true,
        onPressed: enabled ? onNext : null,
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.9),
            radius: 1.4,
            colors: [Color(0xFF16264C), AppColors.background],
            stops: [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}
