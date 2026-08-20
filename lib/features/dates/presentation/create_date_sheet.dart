import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/presentation/widgets/question_block.dart';
import '../../onboarding/presentation/widgets/selection_chips.dart';
import '../../places/places.dart';
import '../domain/date_criteria.dart';

/// Opens the "create a date" form. Returns the chosen [DateCriteria] (or null
/// if dismissed) so the caller can push the suggestions screen.
Future<DateCriteria?> showCreateDate(BuildContext context) {
  return LiquidGlassBottomSheet.show<DateCriteria>(
    context,
    title: 'Create a date',
    builder: (context) => const _CreateDateForm(),
  );
}

class _CreateDateForm extends StatefulWidget {
  const _CreateDateForm();

  @override
  State<_CreateDateForm> createState() => _CreateDateFormState();
}

class _CreateDateFormState extends State<_CreateDateForm> {
  DateCriteria _c = const DateCriteria();

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
                    title: 'Vibe',
                    child: MultiSelectChips(
                      options: DateOptions.vibes,
                      selectedIds: _c.vibes,
                      onChanged: (s) => setState(() => _c = _c.copyWith(vibes: s)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  QuestionBlock(
                    title: 'What kind of place',
                    hint: 'Leave empty for anything.',
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final cat in VenueCategory.values)
                          LiquidGlassChip(
                            label: cat.label,
                            selected: _c.categories.contains(cat),
                            onTap: () => setState(() {
                              final next = {..._c.categories};
                              next.contains(cat)
                                  ? next.remove(cat)
                                  : next.add(cat);
                              _c = _c.copyWith(categories: next);
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  QuestionBlock(
                    title: 'Budget',
                    trailing: Text('\$' * _c.maxPriceLevel,
                        style: AppTypography.number),
                    child: Slider(
                      value: _c.maxPriceLevel.toDouble(),
                      min: 1,
                      max: 4,
                      divisions: 3,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(
                          () => _c = _c.copyWith(maxPriceLevel: v.round())),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuestionBlock(
                    title: 'Within',
                    trailing: Text('${_c.maxDistanceKm.round()} km',
                        style: AppTypography.number),
                    child: Slider(
                      value: _c.maxDistanceKm.clamp(2, 40).toDouble(),
                      min: 2,
                      max: 40,
                      divisions: 19,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.border,
                      onChanged: (v) => setState(
                          () => _c = _c.copyWith(maxDistanceKm: v)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuestionBlock(
                    title: 'Setting',
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final s in IndoorOutdoor.values)
                          LiquidGlassChip(
                            label: switch (s) {
                              IndoorOutdoor.any => 'Any',
                              IndoorOutdoor.indoor => 'Indoor',
                              IndoorOutdoor.outdoor => 'Outdoor',
                            },
                            selected: _c.setting == s,
                            onTap: () =>
                                setState(() => _c = _c.copyWith(setting: s)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LiquidGlassButton(
            label: 'Find places',
            icon: Icons.search,
            expand: true,
            onPressed: () => Navigator.of(context).pop(_c),
          ),
        ],
      ),
    );
  }
}
