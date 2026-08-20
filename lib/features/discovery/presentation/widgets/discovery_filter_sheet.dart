import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/onboarding_options.dart';
import '../../../../design_system/design_system.dart';
import '../../../onboarding/presentation/widgets/question_block.dart';
import '../../../onboarding/presentation/widgets/selection_chips.dart';
import '../../application/discovery_providers.dart';
import '../../domain/discovery_filters.dart';

/// Opens the discovery filter sheet. Applies via the controller on "Apply".
Future<void> showDiscoveryFilters(BuildContext context) {
  return LiquidGlassBottomSheet.show(
    context,
    title: 'Filters',
    builder: (context) => const _FilterForm(),
  );
}

class _FilterForm extends ConsumerStatefulWidget {
  const _FilterForm();

  @override
  ConsumerState<_FilterForm> createState() => _FilterFormState();
}

class _FilterFormState extends ConsumerState<_FilterForm> {
  late DiscoveryFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(discoveryControllerProvider).filters;
  }

  void _apply() {
    ref.read(discoveryControllerProvider.notifier).setFilters(_draft);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QuestionBlock(
                    title: 'Age',
                    trailing: Text('${_draft.ageMin}–${_draft.ageMax}',
                        style: AppTypography.number),
                    child: RangeSlider(
                      values: RangeValues(
                          _draft.ageMin.toDouble(), _draft.ageMax.toDouble()),
                      min: 18,
                      max: 99,
                      divisions: 81,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(() => _draft = _draft.copyWith(
                          ageMin: v.start.round(), ageMax: v.end.round())),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DistanceControl(
                    value: _draft.maxDistanceKm,
                    onChanged: (v) =>
                        setState(() => _draft = _draft.copyWith(maxDistanceKm: v)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuestionBlock(
                    title: 'Minimum compatibility',
                    trailing: Text('${_draft.minCompatibility}%',
                        style: AppTypography.number),
                    child: Slider(
                      value: _draft.minCompatibility.toDouble(),
                      max: 100,
                      divisions: 20,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(() =>
                          _draft = _draft.copyWith(minCompatibility: v.round())),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuestionBlock(
                    title: 'Dating intention',
                    child: MultiSelectChips(
                      options: OnboardingOptions.datingIntentions,
                      selectedIds: _draft.intentions,
                      onChanged: (s) =>
                          setState(() => _draft = _draft.copyWith(intentions: s)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  QuestionBlock(
                    title: 'Interests',
                    hint: 'Shows people who share at least one.',
                    child: MultiSelectChips(
                      options: OnboardingOptions.interests,
                      selectedIds: _draft.interests,
                      onChanged: (s) =>
                          setState(() => _draft = _draft.copyWith(interests: s)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  QuestionBlock(
                    title: 'Smoking',
                    child: MultiSelectChips(
                      options: OnboardingOptions.smoking,
                      selectedIds: _draft.smoking,
                      onChanged: (s) =>
                          setState(() => _draft = _draft.copyWith(smoking: s)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  QuestionBlock(
                    title: 'Drinking',
                    child: MultiSelectChips(
                      options: OnboardingOptions.drinking,
                      selectedIds: _draft.drinking,
                      onChanged: (s) =>
                          setState(() => _draft = _draft.copyWith(drinking: s)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _VerifiedRow(
                    value: _draft.verifiedOnly,
                    onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(verifiedOnly: v)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: LiquidGlassButton(
                  label: 'Reset',
                  variant: GlassButtonVariant.ghost,
                  onPressed: () =>
                      setState(() => _draft = DiscoveryFilters.initial),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: LiquidGlassButton(label: 'Apply filters', onPressed: _apply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistanceControl extends StatelessWidget {
  const _DistanceControl({required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final any = value == null;
    return QuestionBlock(
      title: 'Maximum distance',
      trailing: Text(any ? 'Any' : '${value!.round()} km',
          style: AppTypography.number),
      child: Column(
        children: [
          Row(
            children: [
              Text('Any distance', style: AppTypography.bodyMedium),
              const Spacer(),
              Switch(
                value: any,
                onChanged: (isAny) => onChanged(isAny ? null : 50),
              ),
            ],
          ),
          if (!any)
            Slider(
              value: value!.clamp(5, 160).toDouble(),
              min: 5,
              max: 160,
              divisions: 31,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.border,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}

class _VerifiedRow extends StatelessWidget {
  const _VerifiedRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verified profiles only', style: AppTypography.bodyLarge),
              Text('Verification is coming soon.',
                  style: AppTypography.caption),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
