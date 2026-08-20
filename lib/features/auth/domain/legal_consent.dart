import 'package:flutter/foundation.dart';

/// A record of a user accepting PAIRRA's legal agreements. Captured at sign-up
/// and re-captured whenever [currentVersion] changes (so we can prove informed
/// consent to the *current* documents). Stored alongside the account and is
/// intentionally self-contained so it can be exported or purged cleanly on
/// account deletion.
@immutable
class LegalConsent {
  const LegalConsent({
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.documentVersion,
    required this.acceptedAt,
  });

  final bool termsAccepted;
  final bool privacyAccepted;

  /// The version of the Terms/Privacy documents the user agreed to.
  final String documentVersion;

  final DateTime acceptedAt;

  /// The version currently in force. Bump this when the legal documents change
  /// to force re-consent on next launch.
  static const String currentVersion = '2026-08-01';

  /// Both agreements ticked.
  bool get isComplete => termsAccepted && privacyAccepted;

  /// Complete *and* against the current document version.
  bool get isCurrent => isComplete && documentVersion == currentVersion;

  /// Builds a consent record accepted "now" against the current version.
  factory LegalConsent.now({
    required bool termsAccepted,
    required bool privacyAccepted,
  }) {
    return LegalConsent(
      termsAccepted: termsAccepted,
      privacyAccepted: privacyAccepted,
      documentVersion: currentVersion,
      acceptedAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toMap() => {
        'termsAccepted': termsAccepted,
        'privacyAccepted': privacyAccepted,
        'documentVersion': documentVersion,
        'acceptedAt': acceptedAt.toIso8601String(),
      };

  factory LegalConsent.fromMap(Map<String, dynamic> map) => LegalConsent(
        termsAccepted: map['termsAccepted'] as bool? ?? false,
        privacyAccepted: map['privacyAccepted'] as bool? ?? false,
        documentVersion: map['documentVersion'] as String? ?? '',
        acceptedAt:
            DateTime.tryParse(map['acceptedAt'] as String? ?? '')?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
}
