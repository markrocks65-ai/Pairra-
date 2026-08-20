import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/legal_consent.dart';

/// Which legal document to display.
enum LegalDoc { terms, privacy }

/// Presents a legal document in a glass bottom sheet. Content is placeholder
/// copy for now; swap [_body] for the real documents (or an in-app web view)
/// before launch. The document version shown matches
/// [LegalConsent.currentVersion] so users see what they're consenting to.
Future<void> showLegalDocument(BuildContext context, LegalDoc doc) {
  final title = doc == LegalDoc.terms ? 'Terms of Service' : 'Privacy Policy';
  return LiquidGlassBottomSheet.show(
    context,
    title: title,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Version ${LegalConsent.currentVersion}',
                style: AppTypography.caption),
            const SizedBox(height: AppSpacing.md),
            Text(_body(doc), style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassButton(
              label: 'Close',
              variant: GlassButtonVariant.glass,
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}

String _body(LegalDoc doc) {
  switch (doc) {
    case LegalDoc.terms:
      return 'These are placeholder Terms of Service for PAIRRA.\n\n'
          'PAIRRA is a compatibility-first dating service. By creating an '
          'account you agree to use the service respectfully, to be at least '
          '18 years old, and to follow our community guidelines. The full '
          'legal terms will replace this text before launch.\n\n'
          'You can request account deletion and a copy of your data at any '
          'time from Settings.';
    case LegalDoc.privacy:
      return 'This is placeholder Privacy Policy copy for PAIRRA.\n\n'
          'We collect only what we need to run the service. Sensitive profile '
          'details are private by default and never shown without your explicit '
          'choice. Your precise location is never shared with other users — '
          'only approximate distance. The full policy will replace this text '
          'before launch.';
  }
}
