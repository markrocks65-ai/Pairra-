import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/core/models/profile_photo.dart';
import 'package:pairra/core/models/verification.dart';
import 'package:pairra/features/onboarding/application/onboarding_controller.dart';
import 'package:pairra/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:pairra/features/onboarding/domain/onboarding_profile.dart';
import 'package:pairra/features/profile/application/profile_labels.dart';
import 'package:pairra/features/profile/application/profile_providers.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  group('ProfileLabels', () {
    test('resolves role ids against the applicable role set', () {
      const p = OnboardingProfile(genderId: 'man', orientationId: 'gay');
      final labels = ProfileLabels.roleLabels(p, {'top', 'vers_bottom'});
      expect(labels, containsAll(['Top', 'Vers Bottom']));
    });

    test('gender/orientation honor self-describe custom text', () {
      const p = OnboardingProfile(
        genderId: 'self_describe',
        genderCustom: 'Genderfluid',
        orientationId: 'gay',
      );
      expect(ProfileLabels.gender(p), 'Genderfluid');
      expect(ProfileLabels.orientation(p), 'Gay');
    });

    test('maps intention ids to labels', () {
      expect(ProfileLabels.intentions({'long_term'}), ['Long-term relationship']);
    });
  });

  group('Verification & photo defaults', () {
    test('a fresh profile is unverified with no badge', () {
      const p = OnboardingProfile();
      expect(p.verification.hasBadge, isFalse);
      expect(p.verification.photo, VerificationStatus.none);
    });

    test('a new photo starts pending moderation', () {
      const photo = ProfilePhoto(id: 'x', placeholderSeed: 'p1');
      expect(photo.moderation, PhotoModerationStatus.pending);
    });
  });

  group('ProfileEditingController (edits the shared draft)', () {
    test('sets bio and adds/removes/reorders photos', () async {
      final repo = InMemoryOnboardingRepository(latency: Duration.zero);
      final onb = OnboardingController(repo, 'u1');
      await _settle();
      final editor = ProfileEditingController(onb);

      editor.setBio('Hello there');
      await _settle();
      expect(onb.state.draft.bio, 'Hello there');

      editor.addPhoto('p1');
      editor.addPhoto('p2');
      await _settle();
      expect(onb.state.draft.photos.length, 2);
      expect(onb.state.draft.photos.first.placeholderSeed, 'p1');

      // Move the first photo to the end.
      editor.reorderPhotos(0, 2);
      await _settle();
      expect(onb.state.draft.photos.first.placeholderSeed, 'p2');

      final removeId = onb.state.draft.photos.first.id;
      editor.removePhoto(removeId);
      await _settle();
      expect(onb.state.draft.photos.length, 1);
      expect(onb.state.draft.photos.first.placeholderSeed, 'p1');

      onb.dispose();
    });

    test('editing does not reset a completed profile\'s status', () async {
      final repo = InMemoryOnboardingRepository(latency: Duration.zero);
      final onb = OnboardingController(repo, 'u2');
      await _settle();
      onb.finish();
      await _settle();
      expect(onb.state.draft.status, OnboardingStatus.complete);

      ProfileEditingController(onb).setBio('later edit');
      await _settle();
      expect(onb.state.draft.status, OnboardingStatus.complete);
      onb.dispose();
    });
  });
}
