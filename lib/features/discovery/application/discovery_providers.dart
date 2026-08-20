import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../compatibility/application/compatibility_providers.dart';
import '../../profile/application/profile_providers.dart';
import '../../safety/application/safety_controllers.dart';
import '../../subscription/application/subscription_controller.dart';
import '../data/mock_discovery_repository.dart';
import '../domain/discovery_repository.dart';
import 'discovery_controller.dart';
import 'matches_controller.dart';

/// The candidate source. Defaults to the mock; override with a Firestore-backed
/// repository later.
final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => MockDiscoveryRepository(),
);

/// The discovery feed controller. Recomputes if the current user's profile
/// changes (so scores reflect edits).
final discoveryControllerProvider =
    StateNotifierProvider<DiscoveryController, DiscoveryState>((ref) {
  return DiscoveryController(
    ref.watch(discoveryRepositoryProvider),
    ref.watch(compatibilityServiceProvider),
    ref.watch(currentProfileProvider),
    ref.watch(matchesControllerProvider.notifier),
    ref.watch(blockedProfilesProvider.notifier),
    premium: ref.watch(isPremiumProvider),
  );
});
