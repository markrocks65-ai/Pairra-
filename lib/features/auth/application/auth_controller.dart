import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/legal_consent.dart';
import 'auth_providers.dart';

/// Where the app is in its auth lifecycle. [unknown] holds the splash screen
/// until the persisted session (if any) resolves.
enum AuthLifecycle { unknown, unauthenticated, authenticated }

/// Immutable auth state consumed by the router and the auth screens.
@immutable
class AuthState {
  const AuthState({
    required this.lifecycle,
    this.user,
    this.submitting = false,
    this.error,
  });

  final AuthLifecycle lifecycle;
  final AuthUser? user;

  /// True while an async auth action is in flight (drives button spinners).
  final bool submitting;

  /// The most recent failure, if any (drives inline error banners).
  final AuthFailure? error;

  static const initial = AuthState(lifecycle: AuthLifecycle.unknown);

  bool get isAuthenticated =>
      lifecycle == AuthLifecycle.authenticated && user != null;

  /// Authenticated but hasn't accepted the current legal documents.
  bool get needsConsent => isAuthenticated && !user!.hasCurrentConsent;

  /// Authenticated, consented, but email still unverified.
  bool get needsEmailVerification => isAuthenticated && !user!.emailVerified;

  AuthState copyWith({
    AuthLifecycle? lifecycle,
    AuthUser? user,
    bool? submitting,
    AuthFailure? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      lifecycle: lifecycle ?? this.lifecycle,
      user: clearUser ? null : (user ?? this.user),
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Orchestrates authentication for the UI. Owns no backend logic itself — it
/// delegates to [AuthRepository] and translates results into [AuthState].
/// Action methods return `true` on success and set [AuthState.error] on a
/// typed failure, so screens can both react to the result and render a banner.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(AuthState.initial) {
    _subscription = _repo.authStateChanges().listen(_onAuthUserChanged);
  }

  final AuthRepository _repo;
  late final StreamSubscription<AuthUser?> _subscription;

  void _onAuthUserChanged(AuthUser? user) {
    state = state.copyWith(
      lifecycle: user == null
          ? AuthLifecycle.unauthenticated
          : AuthLifecycle.authenticated,
      user: user,
      clearUser: user == null,
    );
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  /// Wraps an async repo action with submitting + typed-error handling.
  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await action();
      state = state.copyWith(submitting: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(submitting: false, error: e.failure);
      return false;
    } catch (_) {
      state = state.copyWith(submitting: false, error: AuthFailure.unknown);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required bool termsAccepted,
    required bool privacyAccepted,
  }) {
    return _run(() => _repo.signUp(
          email: email,
          password: password,
          consent: LegalConsent.now(
            termsAccepted: termsAccepted,
            privacyAccepted: privacyAccepted,
          ),
        ));
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _repo.signIn(email: email, password: password));
  }

  Future<bool> signOut() => _run(_repo.signOut);

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _repo.sendPasswordReset(email));

  Future<bool> resendEmailVerification() =>
      _run(_repo.sendEmailVerification);

  /// Refreshes the user to detect completed email verification. Returns true
  /// once the email is verified. Reads the freshly-reloaded user directly
  /// (rather than [state], which the auth stream updates asynchronously).
  Future<bool> refreshEmailVerification() async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final user = await _repo.reloadUser();
      state = state.copyWith(submitting: false);
      return user.emailVerified;
    } on AuthException catch (e) {
      state = state.copyWith(submitting: false, error: e.failure);
      return false;
    } catch (_) {
      state = state.copyWith(submitting: false, error: AuthFailure.unknown);
      return false;
    }
  }

  Future<bool> acceptConsent({
    required bool termsAccepted,
    required bool privacyAccepted,
  }) {
    return _run(() => _repo.recordConsent(
          LegalConsent.now(
            termsAccepted: termsAccepted,
            privacyAccepted: privacyAccepted,
          ),
        ));
  }

  /// Returns the verification id on success, or null on failure (error set).
  Future<String?> startPhoneVerification(String phoneNumber) async {
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final id = await _repo.startPhoneVerification(phoneNumber);
      state = state.copyWith(submitting: false);
      return id;
    } on AuthException catch (e) {
      state = state.copyWith(submitting: false, error: e.failure);
      return null;
    } catch (_) {
      state = state.copyWith(submitting: false, error: AuthFailure.unknown);
      return null;
    }
  }

  Future<bool> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) {
    return _run(() => _repo.confirmPhoneCode(
          verificationId: verificationId,
          smsCode: smsCode,
        ));
  }

  Future<bool> deleteAccount() => _run(_repo.deleteAccount);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// The app-wide auth state + actions.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);
