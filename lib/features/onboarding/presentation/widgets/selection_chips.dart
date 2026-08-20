import 'package:flutter/widgets.dart';

import '../../../../core/config/option.dart';
import '../../../../design_system/design_system.dart';

/// Single-select chip group (built on [LiquidGlassChip]). Tapping the selected
/// chip again clears it when [allowDeselect] is true.
class SingleSelectChips extends StatelessWidget {
  const SingleSelectChips({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.allowDeselect = false,
  });

  final List<Option> options;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool allowDeselect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final o in options)
          LiquidGlassChip(
            label: o.label,
            selected: o.id == selectedId,
            onTap: () {
              if (o.id == selectedId) {
                if (allowDeselect) onChanged(null);
              } else {
                onChanged(o.id);
              }
            },
          ),
      ],
    );
  }
}

/// Multi-select chip group. Optionally caps the number of selections at [max].
class MultiSelectChips extends StatelessWidget {
  const MultiSelectChips({
    super.key,
    required this.options,
    required this.selectedIds,
    required this.onChanged,
    this.max,
  });

  final List<Option> options;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final int? max;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final o in options)
          LiquidGlassChip(
            label: o.label,
            selected: selectedIds.contains(o.id),
            onTap: () {
              final next = Set<String>.from(selectedIds);
              if (next.contains(o.id)) {
                next.remove(o.id);
              } else {
                if (max != null && next.length >= max!) return;
                next.add(o.id);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
