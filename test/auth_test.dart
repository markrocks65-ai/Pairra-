import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/auth/application/auth_controller.dart';
import 'package:pairra/features/auth/application/auth_validators.dart';
import 'package:pairra/features/auth/data/mock_auth_repository.dart';
import 'package:pairra/features/auth/domain/auth_failure.dart';
import 'package:pairra/features/auth/domain/legal_consent.dart';

MockAuthRepository _repo() =>
    MockAuthRepository(latency: Duration.zero, initialDelay: Duration.zero);

LegalConsent _consent({bool terms = true, bool privacy = true}) =>
    LegalConsent.now(termsAccepted: terms, privacyAccepted: privacy);

void main() {
  group('AuthValidators', () {
    test('email', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('nope'), isNotNull);
      expect(AuthValidators.email('a@b.co'), isNull);
    });

    test('newPassword enforces length + letters and numbers', () {
      expect(AuthValidators.newPassword('short1'), isNotNull);
      expect(AuthValidators.newPassword('allletters'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNotNull);
      expect(AuthValidators.newPassword('goodpass1'), isNull);
    });

    test('confirmPassword matches', () {
      expect(AuthValidators.confirmPassword('a', 'b'), isNotNull);
      expect(AuthValidators.confirmPassword('same', 'same'), isNull);
    });

    test('smsCode requires 6 digits', () {
      expect(AuthValidators.smsCode('123'), isNotNull);
      expect(AuthValidators.smsCode('123456'), isNull);
    });

    test('passwordStrength increases with complexity', () {
      expect(AuthValidators.passwordStrength('abc'), lessThan(2));
      expect(AuthValidators.passwordStrength('Abcd1234!xyz'),
          greaterThanOrEqualTo(3));
    });
  });

  group('MockAuthRepository', () {
    test('signUp creates an unverified, consented user', () async {
      final repo = _repo();
      final user = await repo.signUp(
        email: 'New@Example.com',
        password: 'goodpass1',
        consent: _consent(),
      );
      expect(user.email, 'new@example.com', reason: 'normalized');
      expect(user.emailVerified, isFalse);
      expect(user.hasCurrentConsent, isTrue);
      repo.dispose();
    });

    test('signUp rejects duplicate email', () async {
      final repo = _repo();
      await repo.signUp(
          email: 'a@b.co', password: 'goodpass1', consent: _consent());
      await repo.signOut();
      expect(
        () => repo.signUp(
            email: 'a@b.co', password: 'goodpass1', consent: _consent()),
        throwsA(isA<AuthException>().having(
            (e) => e.failure, 'failure', AuthFailure.emailAlreadyInUse)),
      );
      repo.dispose();
    });

    test('signUp requires complete consent', () async {
      final repo = _repo();
      expect(
        () => repo.signUp(
            email: 'a@b.co',
            password: 'goodpass1',
            consent: _consent(privacy: false)),
        throwsA(isA<AuthException>().having(
            (e) => e.failure, 'failure', AuthFailure.consentRequired)),
      );
      repo.dispose();
    });

    test('signIn with a wrong password is vague (invalidCredentials)',
        () async {
      final repo = _repo();
      await repo.signUp(
          email: 'a@b.co', password: 'goodpass1', consent: _consent());
      await repo.signOut();
      expect(
        () => repo.signIn(email: 'a@b.co', password: 'wrongpass'),
        throwsA(isA<AuthException>().having(
            (e) => e.failure, 'failure', AuthFailure.invalidCredentials)),
      );
      repo.dispose();
    });

    test('reloadUser reflects email verification after a link was sent',
        () async {
      final repo = _repo();
      await repo.signUp(
          email: 'a@b.co', password: 'goodpass1', consent: _consent());
      await repo.sendEmailVerification();
      final reloaded = await repo.reloadUser();
      expect(reloaded.emailVerified, isTrue);
      repo.dispose();
    });

    test('phone OTP: wrong code throws, correct code verifies', () async {
      final repo = _repo();
      await repo.signUp(
          email: 'a@b.co', password: 'goodpass1', consent: _consent());
      final vid = await repo.startPhoneVerification('+15551234567');
      expect(
        () => repo.confirmPhoneCode(verificationId: vid, smsCode: '000000'),
        throwsA(isA<AuthException>()
            .having((e) => e.failure, 'failure', AuthFailure.invalidCode)),
      );
      final user =
          await repo.confirmPhoneCode(verificationId: vid, smsCode: '123456');
      expect(user.phoneVerified, isTrue);
      repo.dispose();
    });

    test('deleteAccount clears the current user', () async {
      final repo = _repo();
      await repo.signUp(
          email: 'a@b.co', password: 'goodpass1', consent: _consent());
      await repo.deleteAccount();
      expect(repo.currentUser, isNull);
      repo.dispose();
    });
  });

  group('AuthController flow', () {
    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 10));

    test('sign up → authenticated & needs email verification', () async {
      final controller = AuthController(_repo());
      await settle(); // let the initial stream event resolve

      final ok = await controller.signUp(
        email: 'a@b.co',
        password: 'goodpass1',
        termsAccepted: true,
        privacyAccepted: true,
      );
      await settle();

      expect(ok, isTrue);
      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.needsConsent, isFalse);
      expect(controller.state.needsEmailVerification, isTrue);
      controller.dispose();
    });

    test('refreshEmailVerification advances past the email gate', () async {
      final controller = AuthController(_repo());
      await settle();
      await controller.signUp(
        email: 'a@b.co',
        password: 'goodpass1',
        termsAccepted: true,
        privacyAccepted: true,
      );
      await settle();
      await controller.resendEmailVerification();
      final verified = await controller.refreshEmailVerification();
      await settle();

      expect(verified, isTrue);
      expect(controller.state.needsEmailVerification, isFalse);
      controller.dispose();
    });

    test('sign in with bad credentials surfaces a typed error', () async {
      final controller = AuthController(_repo());
      await settle();
      final ok = await controller.signIn(
          email: 'ghost@nowhere.co', password: 'whatever1');
      expect(ok, isFalse);
      expect(controller.state.error, AuthFailure.invalidCredentials);
      expect(controller.state.submitting, isFalse);
      controller.dispose();
    });
  });
}
