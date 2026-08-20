import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/auth_controller.dart';
import '../application/auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

/// Password reset request. On success we show a neutral confirmation that does
/// not reveal whether the email is registered (anti-enumeration).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _emailError;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _emailError = AuthValidators.email(_email.text));
    if (_emailError != null) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text);
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    if (_sent) {
      return AuthScaffold(
        title: 'Check your inbox',
        children: [
          _SuccessIcon(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'If an account exists for ${_email.text.trim()}, we\'ve sent a '
            'link to reset your password. It may take a minute to arrive.',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          LiquidGlassButton(
            label: 'Back to log in',
            expand: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      );
    }

    return AuthScaffold(
      title: 'Reset password',
      subtitle:
          'Enter the email for your account and we\'ll send you a reset link.',
      children: [
        AuthErrorBanner(message: state.error?.message),
        LiquidGlassTextField(
          controller: _email,
          label: 'Email',
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline,
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
            ref.read(authControllerProvider.notifier).clearError();
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.xl),
        LiquidGlassButton(
          label: 'Send reset link',
          expand: true,
          loading: state.submitting,
          onPressed: state.submitting ? null : _submit,
        ),
      ],
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.successWash,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mark_email_read_outlined,
            color: AppColors.success, size: 34),
      ),
    );
  }
}
