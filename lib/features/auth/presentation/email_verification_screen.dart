import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

/// Shown after sign-up (or on login with an unverified account). Prompts the
/// user to confirm the link we emailed them. When verification completes, the
/// router redirects onward automatically. A sign-out escape hatch lets the
/// user switch to a different email.
///
/// (In this mock build, "I've verified my email" simulates the link click.)
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  static const _cooldown = 30;
  int _secondsLeft = 0;
  Timer? _timer;
  bool _checkedAndPending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _secondsLeft = _cooldown);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    final ok =
        await ref.read(authControllerProvider.notifier).resendEmailVerification();
    if (ok && mounted) _startCooldown();
  }

  Future<void> _check() async {
    final verified =
        await ref.read(authControllerProvider.notifier).refreshEmailVerification();
    // If it succeeded the router navigates us away; otherwise show a hint.
    if (!verified && mounted) setState(() => _checkedAndPending = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final email = state.user?.email ?? 'your email';

    return AuthScaffold(
      showBack: false,
      title: 'Verify your email',
      children: [
        AuthErrorBanner(message: state.error?.message),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.accentWash,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_outlined,
                color: AppColors.accent, size: 34),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text.rich(
          TextSpan(
            style:
                AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
            children: [
              const TextSpan(text: 'We sent a verification link to '),
              TextSpan(
                text: email,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                  text: '. Tap the link, then come back and continue.'),
            ],
          ),
        ),
        if (_checkedAndPending) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'We haven\'t detected verification yet. Check your inbox (and spam), '
            'then try again.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.warning),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        LiquidGlassButton(
          label: 'I\'ve verified my email',
          expand: true,
          loading: state.submitting,
          onPressed: state.submitting ? null : _check,
        ),
        const SizedBox(height: AppSpacing.md),
        LiquidGlassButton(
          label: _secondsLeft > 0
              ? 'Resend link in ${_secondsLeft}s'
              : 'Resend link',
          variant: GlassButtonVariant.glass,
          expand: true,
          onPressed:
              (_secondsLeft > 0 || state.submitting) ? null : _resend,
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: GestureDetector(
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
            child: Text('Use a different email',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted)),
          ),
        ),
      ],
    );
  }
}
