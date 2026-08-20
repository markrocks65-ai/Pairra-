/// Pure, synchronous form validators for the auth screens. Return `null` when
/// valid, or a short user-facing error string. Kept free of Flutter/Riverpod
/// so they're trivially unit-testable and reusable by any form.
abstract final class AuthValidators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your email address.';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  /// Sign-up password policy: at least 8 chars, with letters and numbers.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Choose a password.';
    if (v.length < 8) return 'Use at least 8 characters.';
    final hasLetter = v.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = v.contains(RegExp(r'\d'));
    if (!hasLetter || !hasNumber) {
      return 'Include both letters and numbers.';
    }
    return null;
  }

  /// Sign-in only checks presence — never leak the policy to attackers.
  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password.';
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if ((value ?? '').isEmpty) return 'Re-enter your password.';
    if (value != original) return 'Passwords don\'t match.';
    return null;
  }

  static String? smsCode(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter the code we sent you.';
    if (v.length < 6 || !RegExp(r'^\d{6}$').hasMatch(v)) {
      return 'Enter the 6-digit code.';
    }
    return null;
  }

  /// Lightweight E.164-ish phone check (real formatting handled at verify).
  static String? phone(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your phone number.';
    if (!RegExp(r'^\+?[0-9\s\-()]{7,}$').hasMatch(v)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  /// Coarse password-strength score (0–4) for the sign-up meter.
  static int passwordStrength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (value.contains(RegExp(r'\d')) &&
        value.contains(RegExp(r'[^A-Za-z0-9]'))) {
      score++;
    }
    return score.clamp(0, 4);
  }
}
