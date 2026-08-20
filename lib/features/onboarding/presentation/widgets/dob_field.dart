import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// Date-of-birth picker. Age is always *derived* from the chosen date — never
/// typed. The picker's [lastDate] is pinned to exactly 18 years ago, so an
/// under-18 date can't be selected at all.
class DobField extends StatelessWidget {
  const DobField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  static DateTime get _maxDob {
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  int _ageFrom(DateTime dob) {
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(_maxDob.year - 7, _maxDob.month),
      firstDate: DateTime(1920),
      lastDate: _maxDob,
      helpText: 'Select your date of birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surfaceElevated,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme:
              const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    final label = v == null
        ? 'Select date of birth'
        : '${v.year}-${v.month.toString().padLeft(2, '0')}-'
            '${v.day.toString().padLeft(2, '0')}';

    return PressableScale(
      onTap: () => _pick(context),
      child: LiquidGlassSurface(
        level: GlassLevel.subtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        showShadow: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined,
                size: 20, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: v == null ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
            ),
            if (v != null)
              Text('Age ${_ageFrom(v)}',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
