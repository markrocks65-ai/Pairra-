import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/in_memory_onboarding_repository.dart';
import '../domain/onboarding_repository.dart';
import 'onboarding_controller.dart';

/// The active onboarding store. Defaults to in-memory; override with a
/// persistent implementation (shared_preferences / Firestore) later.
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => InMemoryOnboardingRepository(),
);

/// The per-user onboarding controller. Recreated when the signed-in user
/// changes, so each account gets its own resumable draft.
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final uid = ref.watch(authControllerProvider.select((s) => s.user?.id));
  final repo = ref.watch(onboardingRepositoryProvider);
  return OnboardingController(repo, uid);
});
