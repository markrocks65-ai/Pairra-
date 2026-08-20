import '../domain/onboarding_profile.dart';
import '../domain/onboarding_repository.dart';

/// In-memory [OnboardingRepository] — the default store. Resumes within a
/// session; swap for a shared_preferences- or Firestore-backed implementation
/// to persist across launches and devices (the [OnboardingProfile] already has
/// the shape for it).
class InMemoryOnboardingRepository implements OnboardingRepository {
  InMemoryOnboardingRepository({this.latency = const Duration(milliseconds: 150)});

  final Duration latency;
  final Map<String, OnboardingProfile> _drafts = {};

  @override
  Future<OnboardingProfile> load(String uid) async {
    await Future<void>.delayed(latency);
    return _drafts[uid] ?? const OnboardingProfile();
  }

  @override
  Future<void> save(String uid, OnboardingProfile profile) async {
    await Future<void>.delayed(latency);
    _drafts[uid] = profile;
  }

  @override
  Future<void> clear(String uid) async {
    await Future<void>.delayed(latency);
    _drafts.remove(uid);
  }
}
