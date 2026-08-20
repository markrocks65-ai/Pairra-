/// Typed authentication failures. Repositories translate backend-specific
/// errors (Firebase codes, network exceptions) into these so the UI never has
/// to parse raw error strings and every message stays on-brand and friendly.
enum AuthFailure {
  invalidEmail,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  userDisabled,
  invalidCode,
  expiredCode,
  consentRequired,
  requiresRecentLogin,
  network,
  tooManyRequests,
  unknown;

  /// A user-facing message. Deliberately avoids leaking which field was wrong
  /// on sign-in ([invalidCredentials]) to reduce account enumeration.
  String get message => switch (this) {
        AuthFailure.invalidEmail => 'That email address doesn\'t look right.',
        AuthFailure.invalidCredentials =>
          'Email or password is incorrect. Please try again.',
        AuthFailure.emailAlreadyInUse =>
          'An account already exists for this email. Try logging in.',
        AuthFailure.weakPassword =>
          'Please choose a stronger password (at least 8 characters).',
        AuthFailure.userDisabled =>
          'This account has been disabled. Contact support for help.',
        AuthFailure.invalidCode => 'That code isn\'t valid. Please re-enter it.',
        AuthFailure.expiredCode =>
          'That code has expired. Request a new one.',
        AuthFailure.consentRequired =>
          'You need to accept the Terms and Privacy Policy to continue.',
        AuthFailure.requiresRecentLogin =>
          'For your security, please log in again to continue.',
        AuthFailure.network =>
          'We couldn\'t reach the network. Check your connection and retry.',
        AuthFailure.tooManyRequests =>
          'Too many attempts. Please wait a moment and try again.',
        AuthFailure.unknown =>
          'Something went wrong. Please try again.',
      };
}

/// Exception carrying a typed [AuthFailure]. Thrown by repositories, caught by
/// the controller, and surfaced as [AuthFailure.message].
class AuthException implements Exception {
  const AuthException(this.failure, [this.cause]);

  final AuthFailure failure;
  final Object? cause;

  String get message => failure.message;

  @override
  String toString() => 'AuthException(${failure.name})';
}
