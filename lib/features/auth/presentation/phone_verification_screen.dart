import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/auth_controller.dart';
import '../application/auth_validators.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

/// Optional phone verification (a two-step: enter number → enter the 6-digit
/// SMS code). Not part of the required auth gate — it's an added assurance step
/// reachable from Home/Settings. Prepared here so identity/trust features can
/// build on a verified phone later.
///
/// (In this mock build, the accepted code is `123456`.)
class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

enum _Step { enterPhone, enterCode }

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  _Step _step = _Step.enterPhone;
  String? _verificationId;
  String? _phoneError;
  String? _codeError;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    setState(() => _phoneError = AuthValidators.phone(_phone.text));
    if (_phoneError != null) return;

    final id = await ref
        .read(authControllerProvider.notifier)
        .startPhoneVerification(_phone.text.trim());
    if (id != null && mounted) {
      setState(() {
        _verificationId = id;
        _step = _Step.enterCode;
      });
    }
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    setState(() => _codeError = AuthValidators.smsCode(_code.text));
    if (_codeError != null || _verificationId == null) return;

    final ok = await ref.read(authControllerProvider.notifier).confirmPhoneCode(
          verificationId: _verificationId!,
          smsCode: _code.text.trim(),
        );
    if (ok && mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final onCode = _step == _Step.enterCode;

    return AuthScaffold(
      title: onCode ? 'Enter the code' : 'Verify your phone',
      subtitle: onCode
          ? 'We sent a 6-digit code to ${_phone.text.trim()}.'
          : 'Add a verified phone number for extra account security. This is '
              'optional and never shown on your profile.',
      onBack: onCode ? () => setState(() => _step = _Step.enterPhone) : null,
      children: [
        AuthErrorBanner(message: state.error?.message),
        if (!onCode) ...[
          LiquidGlassTextField(
            controller: _phone,
            label: 'Phone number',
            hint: '+1 555 123 4567',
            prefixIcon: Icons.phone_outlined,
            errorText: _phoneError,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
              ref.read(authControllerProvider.notifier).clearError();
            },
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: AppSpacing.xl),
          LiquidGlassButton(
            label: 'Send code',
            expand: true,
            loading: state.submitting,
            onPressed: state.submitting ? null : _sendCode,
          ),
        ] else ...[
          LiquidGlassTextField(
            controller: _code,
            label: 'Verification code',
            hint: '123456',
            prefixIcon: Icons.sms_outlined,
            errorText: _codeError,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (_) {
              if (_codeError != null) setState(() => _codeError = null);
              ref.read(authControllerProvider.notifier).clearError();
            },
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: AppSpacing.xl),
          LiquidGlassButton(
            label: 'Verify',
            expand: true,
            loading: state.submitting,
            onPressed: state.submitting ? null : _confirm,
          ),
          const SizedBox(height: AppSpacing.md),
          LiquidGlassButton(
            label: 'Resend code',
            variant: GlassButtonVariant.ghost,
            expand: true,
            onPressed: state.submitting ? null : _sendCode,
          ),
        ],
      ],
    );
  }
}
