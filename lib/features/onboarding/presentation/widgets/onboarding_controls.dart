import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/onboarding_profile.dart';

/// Compact control for choosing a field's [FieldVisibility] (Everyone /
/// Matches only / Only me). Used to let users govern what's shown — sensitive
/// fields default to non-public.
class VisibilitySelector extends StatelessWidget {
  const VisibilitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Who can see this',
  });

  final FieldVisibility value;
  final ValueChanged<FieldVisibility> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility_outlined,
                size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final v in FieldVisibility.values)
              LiquidGlassChip(
                label: v.label,
                selected: v == value,
                onTap: () => onChanged(v),
              ),
          ],
        ),
      ],
    );
  }
}

/// A labeled switch row for privacy/discovery toggles.
class SettingToggleRow extends StatelessWidget {
  const SettingToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge),
                if (subtitle != null)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
