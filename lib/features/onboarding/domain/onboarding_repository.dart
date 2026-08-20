import 'onboarding_profile.dart';

/// Persistence contract for the onboarding draft. Kept behind an interface so
/// the store can move from in-memory → local (shared_preferences) → Firestore
/// without touching the controller or UI. Drafts are per-user so progress is
/// scoped and resumable.
abstract interface class OnboardingRepository {
  /// Loads the saved draft for [uid], or a fresh [OnboardingProfile] if none.
  Future<OnboardingProfile> load(String uid);

  /// Persists the (possibly partial) draft so the user can resume later.
  Future<void> save(String uid, OnboardingProfile profile);

  /// Removes the draft (e.g. on account deletion).
  Future<void> clear(String uid);
}
