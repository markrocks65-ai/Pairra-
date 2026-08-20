import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/core/models/profile_photo.dart';
import 'package:pairra/core/models/verification.dart';
import 'package:pairra/features/onboarding/data/onboarding_serialization.dart';
import 'package:pairra/features/onboarding/domain/onboarding_profile.dart';

void main() {
  group('OnboardingSerializer round-trip', () {
    final original = OnboardingProfile(
      status: OnboardingStatus.complete,
      displayName: 'Alex',
      avatarSeed: 'aurora',
      bio: 'Hi there',
      photos: const [
        ProfilePhoto(id: 'ph1', placeholderSeed: 'p2'),
      ],
      dateOfBirth: DateTime(1995, 6, 15),
      genderId: 'man',
      orientationId: 'gay',
      datingIntentions: const {'long_term', 'friends_first'},
      roleSetId: 'masc4masc_positions',
      sexualRoles: const {'top', 'vers_top'},
      lookingFor: const LookingForPrefs(
        preferredRoles: {'bottom'},
        relationshipTypes: {'monogamous'},
        ageMin: 25,
        ageMax: 40,
        maxDistanceKm: 30,
      ),
      lifestyle: const LifestylePrefs(
        smoking: 'no',
        drinking: 'socially',
        communicationStyles: {'texter'},
      ),
      interests: const {'fitness', 'travel'},
      personality: const {'social_energy': 'introvert'},
      datePreferences:
          const DatePreferences(firstDates: {'coffee'}, budgetId: '2'),
      location: const ApproximateLocation(
          granted: true, areaLabel: 'Nearby', approxLat: 40.7, approxLng: -74.0),
      privacy: const PrivacySettings(
        profileVisibility: FieldVisibility.matchesOnly,
        showDistance: false,
        showOnlineStatus: false,
        allowMessageRequests: true,
      ),
      fieldVisibility: const {
        'gender': FieldVisibility.public,
        'roles': FieldVisibility.private,
      },
      completedAt: DateTime(2026, 8, 1, 12),
    );

    test('preserves every persisted field', () {
      final restored = OnboardingSerializer.fromMap(
          OnboardingSerializer.toMap(original));

      expect(restored.status, original.status);
      expect(restored.displayName, 'Alex');
      expect(restored.avatarSeed, 'aurora');
      expect(restored.bio, 'Hi there');
      expect(restored.photos.single.placeholderSeed, 'p2');
      expect(restored.dateOfBirth, original.dateOfBirth);
      expect(restored.age, original.age);
      expect(restored.genderId, 'man');
      expect(restored.orientationId, 'gay');
      expect(restored.datingIntentions, original.datingIntentions);
      expect(restored.roleSetId, 'masc4masc_positions');
      expect(restored.sexualRoles, original.sexualRoles);
      expect(restored.lookingFor.preferredRoles, {'bottom'});
      expect(restored.lookingFor.ageMin, 25);
      expect(restored.lookingFor.maxDistanceKm, 30);
      expect(restored.lifestyle.drinking, 'socially');
      expect(restored.lifestyle.communicationStyles, {'texter'});
      expect(restored.interests, {'fitness', 'travel'});
      expect(restored.personality['social_energy'], 'introvert');
      expect(restored.datePreferences.firstDates, {'coffee'});
      expect(restored.datePreferences.budgetId, '2');
      expect(restored.location.approxLat, 40.7);
      expect(restored.location.granted, isTrue);
      expect(restored.privacy.profileVisibility, FieldVisibility.matchesOnly);
      expect(restored.privacy.showDistance, isFalse);
      expect(restored.privacy.showOnlineStatus, isFalse);
      expect(restored.privacy.allowMessageRequests, isTrue);
      expect(restored.visibilityOf('roles'), FieldVisibility.private);
      expect(restored.completedAt, original.completedAt);
    });

    test('verification is NOT persisted (server-only; no self-verify)', () {
      final map = OnboardingSerializer.toMap(original);
      expect(map.containsKey('verification'), isFalse);
      final restored = OnboardingSerializer.fromMap(map);
      expect(restored.verification.hasBadge, isFalse);
      expect(restored.verification.photo, VerificationStatus.none);
    });

    test('no server-only/privileged field is ever persisted by the client', () {
      // These are set exclusively by the server (Admin SDK) and are blocked from
      // client writes by firestore.rules. The client-writable profile draft must
      // never carry them, or a client could smuggle a privileged value in.
      const serverOnly = {
        'verification',
        'plan',
        'planUpdatedAt',
        'identityStatus',
        'phoneVerified',
        'phoneNumber',
      };
      final map = OnboardingSerializer.toMap(original);
      for (final key in serverOnly) {
        expect(map.containsKey(key), isFalse,
            reason: '"$key" is server-only and must not be client-persisted');
      }
    });

    test('an empty map decodes to a fresh profile', () {
      final restored = OnboardingSerializer.fromMap(const {});
      expect(restored.status, OnboardingStatus.notStarted);
      expect(restored.displayName, isNull);
      expect(restored.interests, isEmpty);
    });
  });
}
