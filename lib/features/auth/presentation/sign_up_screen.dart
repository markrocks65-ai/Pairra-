import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../navigation/app_routes.dart';
import '../application/auth_controller.dart';
import '../application/auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/legal_consent_field.dart';
import 'widgets/legal_documents.dart';
import 'widgets/password_field.dart';

/// Account creation. Collects only an email + password and the required legal
/// consent — no name, birthday or other personal data at this stage (that
/// belongs to onboarding/profile). The "Create account" action stays disabled
/// until both agreements are accepted, and all fields are validated on submit.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  bool _terms = false;
  bool _privacy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = AuthValidators.email(_email.text);
      _passwordError = AuthValidators.newPassword(_password.text);
      _confirmError =
          AuthValidators.confirmPassword(_confirm.text, _password.text);
    });
    return _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    // Router redirects to email verification on success.
    await ref.read(authControllerProvider.notifier).signUp(
          email: _email.text,
          password: _password.text,
          termsAccepted: _terms,
          privacyAccepted: _privacy,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final canSubmit = _terms && _privacy && !state.submitting;

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Compatibility first. Set up takes a minute.',
      footer: _LoginFooter(),
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
          autofillHints: const [AutofillHints.newUsername, AutofillHints.email],
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
            controller.clearError();
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        PasswordField(
          controller: _password,
          label: 'Password',
          errorText: _passwordError,
          showStrength: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        PasswordField(
          controller: _confirm,
          label: 'Confirm password',
          errorText: _confirmError,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.xl),
        LegalConsentField(
          termsAccepted: _terms,
          privacyAccepted: _privacy,
          onTermsChanged: (v) => setState(() => _terms = v),
          onPrivacyChanged: (v) => setState(() => _privacy = v),
          onOpenTerms: () => showLegalDocument(context, LegalDoc.terms),
          onOpenPrivacy: () => showLegalDocument(context, LegalDoc.privacy),
        ),
        const SizedBox(height: AppSpacing.xl),
        LiquidGlassButton(
          label: 'Create account',
          expand: true,
          loading: state.submitting,
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: AppTypography.bodyMedium),
        GestureDetector(
          onTap: () => context.pushReplacement(AppRoutes.login),
          child: Text('Log in',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }
}
