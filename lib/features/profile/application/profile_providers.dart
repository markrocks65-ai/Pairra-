import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_photo.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../../onboarding/domain/onboarding_profile.dart';

/// The current user's profile — the same draft onboarding builds. The profile
/// feature reads and edits this single source of truth rather than duplicating
/// state, so onboarding and profile can never drift apart.
final currentProfileProvider = Provider<OnboardingProfile>(
  (ref) => ref.watch(onboardingControllerProvider).draft,
);

/// Editing actions specific to the profile (bio + photos). Delegates to the
/// shared [OnboardingController.update] so persistence/resume behavior is
/// identical to onboarding. Editing a completed profile does not reset its
/// status (update only advances notStarted → inProgress).
final profileEditingControllerProvider = Provider<ProfileEditingController>(
  (ref) =>
      ProfileEditingController(ref.watch(onboardingControllerProvider.notifier)),
);

class ProfileEditingController {
  ProfileEditingController(this._onboarding);

  final OnboardingController _onboarding;

  void setBio(String value) =>
      _onboarding.update((p) => p.copyWith(bio: value));

  void addPhoto(String placeholderSeed) {
    _onboarding.update((p) {
      final photo = ProfilePhoto(
        id: 'photo_${DateTime.now().microsecondsSinceEpoch}',
        placeholderSeed: placeholderSeed,
      );
      return p.copyWith(photos: [...p.photos, photo]);
    });
  }

  void removePhoto(String id) {
    _onboarding.update(
      (p) => p.copyWith(photos: p.photos.where((x) => x.id != id).toList()),
    );
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    _onboarding.update((p) {
      final list = [...p.photos];
      var target = newIndex;
      if (target > oldIndex) target -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(target, item);
      return p.copyWith(photos: list);
    });
  }
}
