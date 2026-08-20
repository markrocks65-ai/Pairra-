import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/legal_consent_field.dart';
import 'widgets/legal_documents.dart';

/// Standalone consent capture. Reached when an authenticated user hasn't
/// accepted the *current* legal documents — e.g. an existing account after a
/// Terms/Privacy version bump. Continuation is blocked until both are accepted,
/// satisfying "do not allow users to continue until required legal agreements
/// are accepted".
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _terms = false;
  bool _privacy = false;

  Future<void> _accept() async {
    // Router redirects onward once consent is recorded.
    await ref.read(authControllerProvider.notifier).acceptConsent(
          termsAccepted: _terms,
          privacyAccepted: _privacy,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final canContinue = _terms && _privacy && !state.submitting;

    return AuthScaffold(
      showBack: false,
      title: 'A quick update',
      subtitle:
          'We\'ve updated our Terms and Privacy Policy. Please review and accept '
          'them to continue.',
      children: [
        AuthErrorBanner(message: state.error?.message),
        LegalConsentField(
          termsAccepted: _terms,
          privacyAccepted: _privacy,
          onTermsChanged: (v) => setState(() => _terms = v),
          onPrivacyChanged: (v) => setState(() => _privacy = v),
          onOpenTerms: () => showLegalDocument(context, LegalDoc.terms),
          onOpenPrivacy: () => showLegalDocument(context, LegalDoc.privacy),
        ),
        const SizedBox(height: AppSpacing.xxl),
        LiquidGlassButton(
          label: 'Agree & continue',
          expand: true,
          loading: state.submitting,
          onPressed: canContinue ? _accept : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: GestureDetector(
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
            child: Text('Sign out',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted)),
          ),
        ),
      ],
    );
  }
}
