import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// Controlled legal-consent control: two required checkboxes (Terms of Service
/// and Privacy Policy) with tappable document links. The parent owns the two
/// booleans and gates submission on both being true — this widget only renders
/// and reports changes.
class LegalConsentField extends StatelessWidget {
  const LegalConsentField({
    super.key,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final bool termsAccepted;
  final bool privacyAccepted;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ConsentRow(
          value: termsAccepted,
          onChanged: onTermsChanged,
          child: _linkedText(
            context,
            'I agree to the ',
            'Terms of Service',
            onOpenTerms,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ConsentRow(
          value: privacyAccepted,
          onChanged: onPrivacyChanged,
          child: _linkedText(
            context,
            'I have read the ',
            'Privacy Policy',
            onOpenPrivacy,
          ),
        ),
      ],
    );
  }

  Widget _linkedText(
      BuildContext context, String lead, String link, VoidCallback onTap) {
    return Text.rich(
      TextSpan(
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        children: [
          TextSpan(text: lead),
          TextSpan(
            text: link,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GlassCheckbox(value: value, onChanged: onChanged),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _GlassCheckbox extends StatelessWidget {
  const _GlassCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    return PressableScale(
      onTap: () => onChanged(!value),
      pressedScale: 0.88,
      child: AnimatedContainer(
        duration: reduceMotion ? AppMotion.instant : AppMotion.fast,
        curve: AppMotion.standard,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.accent : const Color(0x00000000),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(
            color: value ? AppColors.accent : AppColors.borderStrong,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 16, color: AppColors.onAccent)
            : null,
      ),
    );
  }
}
