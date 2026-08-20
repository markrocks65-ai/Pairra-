import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../navigation/app_routes.dart';
import '../application/auth_controller.dart';
import '../application/auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/password_field.dart';

/// Email + password sign-in. Errors are deliberately non-specific (see
/// [AuthFailure.invalidCredentials]) to avoid revealing which accounts exist.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = AuthValidators.email(_email.text);
      _passwordError = AuthValidators.loginPassword(_password.text);
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    // On success the router redirects (to verify email / consent / home).
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Log in to pick up where you left off.',
      footer: _SignUpFooter(),
      children: [
        AuthErrorBanner(message: state.error?.message),
        LiquidGlassTextField(
          controller: _email,
          label: 'Email',
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline,
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
            controller.clearError();
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        PasswordField(
          controller: _password,
          errorText: _passwordError,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
            controller.clearError();
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.forgotPassword),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text('Forgot password?',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.accent)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LiquidGlassButton(
          label: 'Log in',
          expand: true,
          loading: state.submitting,
          onPressed: state.submitting ? null : _submit,
        ),
      ],
    );
  }
}

class _SignUpFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('New to PAIRRA? ', style: AppTypography.bodyMedium),
        GestureDetector(
          onTap: () => context.pushReplacement(AppRoutes.signUp),
          child: Text('Create account',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }
}
