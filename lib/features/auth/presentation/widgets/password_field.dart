import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../application/auth_validators.dart';

/// A password input built on [LiquidGlassTextField] with a show/hide toggle
/// and an optional strength meter (for sign-up). Used by Sign up / Login.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.errorText,
    this.textInputAction,
    this.autofillHints,
    this.showStrength = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  /// Shows the strength meter beneath the field (sign-up only).
  final bool showStrength;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LiquidGlassTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          errorText: widget.errorText,
          obscureText: _obscured,
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onChanged: (v) {
            widget.onChanged?.call(v);
            if (widget.showStrength) setState(() {});
          },
          onSubmitted: widget.onSubmitted,
          suffix: PressableScale(
            onTap: () => setState(() => _obscured = !_obscured),
            pressedScale: 0.9,
            child: Icon(
              _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
          ),
        ),
        if (widget.showStrength && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _StrengthMeter(
              score: AuthValidators.passwordStrength(widget.controller.text),
            ),
          ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.score});

  /// 0–4.
  final int score;

  @override
  Widget build(BuildContext context) {
    const labels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];
    final color = switch (score) {
      <= 1 => AppColors.error,
      2 => AppColors.warning,
      3 => AppColors.accent,
      _ => AppColors.success,
    };

    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? AppSpacing.xs : 0),
              decoration: BoxDecoration(
                color: i < score ? color : AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        const SizedBox(width: AppSpacing.sm),
        Text(labels[score], style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}
