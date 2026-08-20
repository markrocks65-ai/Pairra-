import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../accessibility/accessibility_scope.dart';

/// A premium glass text field. Sits on a subtle translucent surface with a
/// hairline border that lifts to the accent color on focus and to the error
/// color when [errorText] is set. Label sits above; error/helper text sits
/// below. Built for forms across PAIRRA (auth, profile, filters), so it lives
/// in the design system rather than in any one feature.
///
/// Honors reduced-transparency (opaque fill) and reduced-motion (no border
/// tween).
class LiquidGlassTextField extends StatefulWidget {
  const LiquidGlassTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixIcon,
    this.suffix,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;

  /// When non-null, the field renders in its error state and shows this text.
  final String? errorText;

  /// Optional helper text shown when there is no error.
  final String? helperText;

  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;

  /// Trailing widget (e.g. a password visibility toggle).
  final Widget? suffix;

  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<LiquidGlassTextField> createState() => _LiquidGlassTextFieldState();
}

class _LiquidGlassTextFieldState extends State<LiquidGlassTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Only dispose the node if we created it.
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a11y = PairraA11y.of(context);
    final hasError = widget.errorText != null;

    final borderColor = hasError
        ? AppColors.error
        : _focused
            ? AppColors.accent
            : (a11y.highContrast
                ? AppColors.borderHighContrast
                : AppColors.border);

    final fill = a11y.reduceTransparency
        ? AppColors.surfaceElevated
        : AppColors.glassBase.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
        ],
        AnimatedContainer(
          duration: a11y.reduceMotion ? AppMotion.instant : AppMotion.fast,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: _focused || hasError ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Icon(widget.prefixIcon,
                    size: 20,
                    color: _focused ? AppColors.accent : AppColors.textMuted),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  autofillHints: widget.autofillHints,
                  maxLength: widget.maxLength,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: AppColors.accent,
                  style: AppTypography.bodyLarge,
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    hintText: widget.hint,
                    hintStyle: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: AppSpacing.sm),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: AppTypography.caption.copyWith(
                color: hasError ? AppColors.error : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
