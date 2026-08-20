import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/legal_consent.dart';

/// Firebase-backed [AuthRepository]. Email/password auth via Firebase Auth;
/// consent + phone-verified state live in `users/{uid}` in Firestore. Verified
/// email comes from Firebase Auth itself.
///
/// The auth state stream merges the Firebase user with the user's Firestore
/// document, so consent/phone changes re-emit an updated [AuthUser]. Nothing
/// here writes an entitlement or verification status that the security rules
/// reserve for the server.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  final _controller = StreamController<AuthUser?>.broadcast();
  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSub;
  AuthUser? _current;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() {
    _authSub ??= _auth.authStateChanges().listen(_onAuthChanged);
    return _controller.stream;
  }

  void _onAuthChanged(fb.User? user) {
    _docSub?.cancel();
    if (user == null) {
      _current = null;
      _controller.add(null);
      return;
    }
    // Merge the auth user with its Firestore doc; re-emit on either change.
    _docSub = _userDoc(user.uid).snapshots().listen(
      (doc) {
        _current = _merge(user, doc.data());
        _controller.add(_current);
      },
      onError: (_) {
        _current = _merge(user, null);
        _controller.add(_current);
      },
    );
  }

  AuthUser _merge(fb.User user, Map<String, dynamic>? data) {
    final consentMap = data?['consent'];
    final createdRaw = data?['createdAt'];
    final createdAt = createdRaw is Timestamp
        ? createdRaw.toDate()
        : (user.metadata.creationTime ?? DateTime.now());
    return AuthUser(
      id: user.uid,
      email: user.email ?? (data?['email'] as String? ?? ''),
      emailVerified: user.emailVerified,
      createdAt: createdAt,
      // Phone identity comes ONLY from Firebase Auth (a genuine, server-checked
      // linked credential) — never from the client-writable Firestore doc, so a
      // modified client can't self-attest a verified phone.
      phoneNumber: user.phoneNumber,
      phoneVerified: user.phoneNumber != null,
      consent: consentMap is Map
          ? LegalConsent.fromMap(Map<String, dynamic>.from(consentMap))
          : null,
    );
  }

  Never _fail(Object e) {
    if (e is fb.FirebaseAuthException) throw AuthException(_map(e), e);
    throw AuthException(AuthFailure.unknown, e);
  }

  AuthFailure _map(fb.FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => AuthFailure.invalidEmail,
        'email-already-in-use' => AuthFailure.emailAlreadyInUse,
        'weak-password' => AuthFailure.weakPassword,
        'user-disabled' => AuthFailure.userDisabled,
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          AuthFailure.invalidCredentials,
        'invalid-verification-code' => AuthFailure.invalidCode,
        'session-expired' || 'code-expired' => AuthFailure.expiredCode,
        'requires-recent-login' => AuthFailure.requiresRecentLogin,
        'too-many-requests' => AuthFailure.tooManyRequests,
        'network-request-failed' => AuthFailure.network,
        _ => AuthFailure.unknown,
      };

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required LegalConsent consent,
  }) async {
    if (!consent.isComplete) {
      throw const AuthException(AuthFailure.consentRequired);
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final user = cred.user!;
      await user.sendEmailVerification();
      // Note: phone-verified state is derived from Firebase Auth, never stored
      // here (it's a server-only field the rules forbid a client from writing).
      await _userDoc(user.uid).set({
        'email': email.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'consent': consent.toMap(),
      });
      return _merge(user, {'consent': consent.toMap()});
    } catch (e) {
      _fail(e);
    }
  }

  @override
  Future<AuthUser> signIn(
      {required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      final user = cred.user!;
      final doc = await _userDoc(user.uid).get();
      return _merge(user, doc.data());
    } catch (e) {
      _fail(e);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      // Don't reveal whether the account exists.
      if (e.code == 'user-not-found') return;
      throw AuthException(_map(e), e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<AuthUser> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    await user.reload();
    final refreshed = _auth.currentUser!;
    final doc = await _userDoc(refreshed.uid).get();
    final merged = _merge(refreshed, doc.data());
    _current = merged;
    _controller.add(merged);
    return merged;
  }

  @override
  Future<AuthUser> recordConsent(LegalConsent consent) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    await _userDoc(user.uid)
        .set({'consent': consent.toMap()}, SetOptions(merge: true));
    final doc = await _userDoc(user.uid).get();
    final merged = _merge(user, doc.data());
    _current = merged;
    _controller.add(merged);
    return merged;
  }

  @override
  Future<String> startPhoneVerification(String phoneNumber) async {
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthException(_map(e), e));
        }
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<AuthUser> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode.trim());
    try {
      await user.linkWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code != 'provider-already-linked' &&
          e.code != 'credential-already-in-use') {
        throw AuthException(_map(e), e);
      }
    }
    // Linking the credential makes Firebase Auth authoritative for the verified
    // phone (user.phoneNumber is now set). We deliberately do NOT mirror this to
    // Firestore — the rules treat phoneVerified/phoneNumber as server-only, and
    // _merge derives them from Auth, so there's nothing for a client to spoof.
    await user.reload();
    final doc = await _userDoc(user.uid).get();
    final merged = _merge(_auth.currentUser!, doc.data());
    _current = merged;
    _controller.add(merged);
    return merged;
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _userDoc(user.uid).delete();
      await user.delete();
    } catch (e) {
      _fail(e);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _docSub?.cancel();
    _controller.close();
  }
}
