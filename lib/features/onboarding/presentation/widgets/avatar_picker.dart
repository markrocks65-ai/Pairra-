import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';

/// Placeholder profile-photo picker. Real image upload needs a platform image
/// picker + storage (a later integration); for now the user chooses a premium
/// gradient monogram so the profile has a visual identity. Selection is stored
/// as an [avatarSeed] and swaps cleanly for a real photo URL later.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.displayName,
    required this.selectedSeed,
    required this.onChanged,
  });

  final String? displayName;
  final String? selectedSeed;
  final ValueChanged<String> onChanged;

  static const _seeds = ['aurora', 'dusk', 'slate', 'ocean', 'ember', 'moss'];

  static List<Color> gradientFor(String seed) {
    switch (seed) {
      case 'aurora':
        return const [Color(0xFF5B7CFF), Color(0xFF7E5BFF)];
      case 'dusk':
        return const [Color(0xFF3A2F6B), Color(0xFF6E8BFF)];
      case 'slate':
        return const [Color(0xFF2B3242), Color(0xFF4A5568)];
      case 'ocean':
        return const [Color(0xFF1E5C7A), Color(0xFF3FB98A)];
      case 'ember':
        return const [Color(0xFF6B2F3A), Color(0xFFE0A745)];
      case 'moss':
        return const [Color(0xFF244B3A), Color(0xFF3FB98A)];
      default:
        return const [Color(0xFF2B3242), Color(0xFF4A5568)];
    }
  }

  String get _initial {
    final n = (displayName ?? '').trim();
    return n.isEmpty ? '?' : n.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final seed = selectedSeed ?? _seeds.first;
    return Column(
      children: [
        _AvatarCircle(seed: seed, initial: _initial, size: 108),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.center,
          children: [
            for (final s in _seeds)
              PressableScale(
                onTap: () => onChanged(s),
                pressedScale: 0.9,
                child: _AvatarCircle(
                  seed: s,
                  initial: _initial,
                  size: 44,
                  selected: s == seed,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.seed,
    required this.initial,
    required this.size,
    this.selected = false,
  });

  final String seed;
  final String initial;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AvatarPicker.gradientFor(seed),
        ),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: (size > 80
                ? AppTypography.displayLarge
                : AppTypography.headingSmall)
            .copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
