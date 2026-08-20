import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/core/models/verification.dart';
import 'package:pairra/features/verification/domain/verification_check.dart';
import 'package:pairra/features/verification/domain/verification_provider.dart';

void main() {
  group('UnconnectedVerificationProvider (no fake verification)', () {
    const provider = UnconnectedVerificationProvider();

    test('is not connected', () {
      expect(provider.isConnected, isFalse);
    });

    test('starting a flow throws instead of verifying anyone', () {
      expect(
        () => provider.start(VerificationCheckType.photo),
        throwsA(isA<VerificationNotConnected>()),
      );
    });
  });

  test('VerificationCheckType covers photo and identity', () {
    expect(VerificationCheckType.values.map((v) => v.name),
        containsAll(<String>['photo', 'identity']));
  });

  group('VerificationState', () {
    test('a fresh state is unverified with no badge', () {
      const state = VerificationState();
      expect(state.hasBadge, isFalse);
      expect(state.photo, VerificationStatus.none);
      expect(state.identity, VerificationStatus.none);
    });

    test('the badge shows only when a check is actually verified', () {
      const verified =
          VerificationState(photo: VerificationStatus.verified);
      expect(verified.hasBadge, isTrue);
      expect(const VerificationState(photo: VerificationStatus.pending).hasBadge,
          isFalse);
    });
  });
}
