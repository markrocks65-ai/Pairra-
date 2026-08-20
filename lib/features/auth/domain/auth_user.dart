import 'package:flutter/foundation.dart';

import 'legal_consent.dart';

/// Future-facing identity verification state. Kept separate from email/phone
/// verification: this represents document/selfie identity checks that PAIRRA
/// will layer on later. Defaults to [none] so nothing about the current flow
/// depends on it, but the field exists now so the model never has to change.
enum IdentityVerificationStatus { none, pending, verified, rejected }

/// The authenticated identity as PAIRRA's app layer sees it. Intentionally
/// minimal — auth collects only what it needs (an email/phone credential and
/// verification/consent state). Profile data (name, photos, preferences) lives
/// in a separate profile model and is never mixed in here.
///
/// This shape maps 1:1 onto Firebase Auth's `User`, so swapping the mock
/// repository for a Firebase-backed one requires no changes to callers.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.createdAt,
    this.phoneNumber,
    this.phoneVerified = false,
    this.identityStatus = IdentityVerificationStatus.none,
    this.consent,
  });

  /// Stable account id (Firebase uid in production).
  final String id;

  final String email;
  final bool emailVerified;
  final DateTime createdAt;

  final String? phoneNumber;
  final bool phoneVerified;

  /// Future identity-verification state (document/selfie checks).
  final IdentityVerificationStatus identityStatus;

  /// Most recent legal consent on file, if any.
  final LegalConsent? consent;

  /// Whether the user has accepted the *current* legal documents.
  bool get hasCurrentConsent => consent?.isCurrent ?? false;

  AuthUser copyWith({
    String? email,
    bool? emailVerified,
    String? phoneNumber,
    bool? phoneVerified,
    IdentityVerificationStatus? identityStatus,
    LegalConsent? consent,
  }) {
    return AuthUser(
      id: id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      identityStatus: identityStatus ?? this.identityStatus,
      consent: consent ?? this.consent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.email == email &&
      other.emailVerified == emailVerified &&
      other.phoneNumber == phoneNumber &&
      other.phoneVerified == phoneVerified &&
      other.identityStatus == identityStatus &&
      other.consent?.isCurrent == consent?.isCurrent;

  @override
  int get hashCode => Object.hash(id, email, emailVerified, phoneNumber,
      phoneVerified, identityStatus, consent?.isCurrent);
}
