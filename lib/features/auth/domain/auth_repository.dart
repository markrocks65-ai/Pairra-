import 'auth_user.dart';
import 'legal_consent.dart';

/// The authentication contract the app depends on. The UI/state layer talks
/// only to this interface, never to Firebase (or the mock) directly — so the
/// backend can be swapped by overriding a single provider.
///
/// Implementations MUST translate backend errors into [AuthException]
/// (see `auth_failure.dart`). Every method that can fail does so by throwing
/// an [AuthException]; success returns normally.
abstract interface class AuthRepository {
  /// Emits the current [AuthUser] whenever auth state changes; emits `null`
  /// when signed out. Emits its first value once initialization completes
  /// (used to leave the splash screen).
  Stream<AuthUser?> authStateChanges();

  /// The current user synchronously, or null if signed out / not yet resolved.
  AuthUser? get currentUser;

  /// Creates an account. Consent is required up front and stored with the
  /// account. Throws [AuthFailure.emailAlreadyInUse] / [weakPassword] /
  /// [invalidEmail] / [consentRequired] as appropriate.
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required LegalConsent consent,
  });

  /// Signs in with email + password. Throws [AuthFailure.invalidCredentials]
  /// on a bad email/password (kept vague to reduce account enumeration).
  Future<AuthUser> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Sends a password-reset email. Does not reveal whether the email exists.
  Future<void> sendPasswordReset(String email);

  /// (Re)sends the email-verification link to the current user.
  Future<void> sendEmailVerification();

  /// Reloads the current user from the backend (e.g. to pick up that email
  /// verification has completed). Returns the refreshed user.
  Future<AuthUser> reloadUser();

  /// Records/updates the current user's legal consent (e.g. after a document
  /// version bump).
  Future<AuthUser> recordConsent(LegalConsent consent);

  /// Begins phone verification, returning an opaque verification id to pair
  /// with the SMS code in [confirmPhoneCode]. Optional feature; only used when
  /// phone verification is enabled.
  Future<String> startPhoneVerification(String phoneNumber);

  /// Confirms an SMS code against a prior [startPhoneVerification]. Throws
  /// [AuthFailure.invalidCode] / [expiredCode].
  Future<AuthUser> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  });

  /// Permanently deletes the current account. Callers are responsible for
  /// purging associated profile/message data first; this removes the auth
  /// identity itself. May throw [AuthFailure.requiresRecentLogin].
  Future<void> deleteAccount();

  /// Releases resources (stream controllers, listeners).
  void dispose();
}
