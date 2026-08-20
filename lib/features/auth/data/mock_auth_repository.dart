import 'dart:async';

import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';
import '../domain/legal_consent.dart';
import '../domain/auth_repository.dart';

/// In-memory [AuthRepository] used until a Firebase project is configured. It
/// faithfully simulates the real flows — sign up / sign in, email verification,
/// password reset, phone OTP, consent, deletion — with small async delays and
/// the same typed [AuthException]s a real backend would raise, so the entire
/// auth experience is fully exercisable (and unit-testable) with no network.
///
/// Swap for `FirebaseAuthRepository` by overriding `authRepositoryProvider`;
/// no calling code changes.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    this.latency = const Duration(milliseconds: 450),
    this.initialDelay = const Duration(milliseconds: 900),
  });

  /// Simulated per-call network latency.
  final Duration latency;

  /// Simulated cold-start session-restore delay (drives the splash). Set to
  /// [Duration.zero] in tests for determinism.
  final Duration initialDelay;

  final _controller = StreamController<AuthUser?>.broadcast();
  final Map<String, _Account> _accounts = {}; // keyed by lowercased email

  AuthUser? _current;
  bool _initialized = false;

  // Demo helper: which account has an outstanding verification email.
  final Set<String> _pendingEmailVerification = {};

  // Demo phone OTP state.
  String? _phoneUnderVerification;
  static const _validSmsCode = '123456';

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    if (!_initialized) {
      // Simulate restoring a persisted session on cold start (splash).
      await Future<void>.delayed(initialDelay);
      _initialized = true;
    }
    yield _current;
    yield* _controller.stream;
  }

  void _emit() => _controller.add(_current);

  Future<void> _wait() => Future<void>.delayed(latency);

  bool _looksLikeEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required LegalConsent consent,
  }) async {
    await _wait();
    final normalized = email.trim().toLowerCase();
    if (!_looksLikeEmail(normalized)) {
      throw const AuthException(AuthFailure.invalidEmail);
    }
    if (password.length < 8) {
      throw const AuthException(AuthFailure.weakPassword);
    }
    if (!consent.isComplete) {
      throw const AuthException(AuthFailure.consentRequired);
    }
    if (_accounts.containsKey(normalized)) {
      throw const AuthException(AuthFailure.emailAlreadyInUse);
    }

    final user = AuthUser(
      id: 'mock_${DateTime.now().microsecondsSinceEpoch}',
      email: normalized,
      emailVerified: false,
      createdAt: DateTime.now().toUtc(),
      consent: consent,
    );
    _accounts[normalized] = _Account(password: password, user: user);
    _current = user;
    _pendingEmailVerification.add(normalized);
    _emit();
    return user;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    await _wait();
    final normalized = email.trim().toLowerCase();
    final account = _accounts[normalized];
    // Vague on purpose: never reveal whether the email exists.
    if (account == null || account.password != password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    _current = account.user;
    _emit();
    return account.user;
  }

  @override
  Future<void> signOut() async {
    await _wait();
    _current = null;
    _emit();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _wait();
    if (!_looksLikeEmail(email)) {
      throw const AuthException(AuthFailure.invalidEmail);
    }
    // Intentionally succeeds whether or not the account exists (no enumeration).
  }

  @override
  Future<void> sendEmailVerification() async {
    await _wait();
    final current = _current;
    if (current == null) throw const AuthException(AuthFailure.unknown);
    _pendingEmailVerification.add(current.email);
  }

  @override
  Future<AuthUser> reloadUser() async {
    await _wait();
    final current = _current;
    if (current == null) throw const AuthException(AuthFailure.unknown);
    // Simulate the user having clicked the verification link: once a
    // verification was requested, reloading reflects it as verified.
    if (_pendingEmailVerification.contains(current.email)) {
      final verified = current.copyWith(emailVerified: true);
      _accounts[current.email] =
          _accounts[current.email]!.copyWith(user: verified);
      _pendingEmailVerification.remove(current.email);
      _current = verified;
      _emit();
      return verified;
    }
    return current;
  }

  @override
  Future<AuthUser> recordConsent(LegalConsent consent) async {
    await _wait();
    final current = _current;
    if (current == null) throw const AuthException(AuthFailure.unknown);
    final updated = current.copyWith(consent: consent);
    _accounts[current.email] =
        _accounts[current.email]!.copyWith(user: updated);
    _current = updated;
    _emit();
    return updated;
  }

  @override
  Future<String> startPhoneVerification(String phoneNumber) async {
    await _wait();
    if (phoneNumber.trim().length < 6) {
      throw const AuthException(AuthFailure.unknown);
    }
    _phoneUnderVerification = phoneNumber.trim();
    return 'mock_vid_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<AuthUser> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    await _wait();
    final current = _current;
    if (current == null) throw const AuthException(AuthFailure.unknown);
    if (smsCode.trim() != _validSmsCode) {
      throw const AuthException(AuthFailure.invalidCode);
    }
    final updated = current.copyWith(
      phoneNumber: _phoneUnderVerification,
      phoneVerified: true,
    );
    _accounts[current.email] =
        _accounts[current.email]!.copyWith(user: updated);
    _current = updated;
    _phoneUnderVerification = null;
    _emit();
    return updated;
  }

  @override
  Future<void> deleteAccount() async {
    await _wait();
    final current = _current;
    if (current == null) return;
    _accounts.remove(current.email);
    _pendingEmailVerification.remove(current.email);
    _current = null;
    _emit();
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// Internal account record: the stored credential plus the user snapshot.
class _Account {
  const _Account({required this.password, required this.user});
  final String password;
  final AuthUser user;

  _Account copyWith({String? password, AuthUser? user}) =>
      _Account(password: password ?? this.password, user: user ?? this.user);
}
