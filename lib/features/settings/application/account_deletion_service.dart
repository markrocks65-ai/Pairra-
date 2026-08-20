import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../dates/application/dates_providers.dart';
import '../../discovery/application/matches_controller.dart';
import '../../messaging/application/messaging_providers.dart';
import '../../notifications/application/notifications_controllers.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../../safety/application/safety_controllers.dart';
import '../../safety/application/safety_plan_controller.dart';
import '../data/in_memory_account_deletion_repository.dart';
import '../domain/account_deletion_repository.dart';
import '../domain/deletion_request.dart';

/// Coordinates permanent account deletion (NOT deactivation):
///  1. Files a deletion request to the backend workflow (the server performs
///     the authoritative removal/anonymization per the retention policy).
///  2. Purges local per-user data on this device.
///  3. Deletes the auth identity.
class AccountDeletionService {
  AccountDeletionService(this._ref);

  final Ref _ref;

  Future<void> deleteAccount({String? reason}) async {
    final uid = _ref.read(authControllerProvider).user?.id;

    // 1. Hand off to the server-side deletion workflow.
    await _ref.read(accountDeletionRepositoryProvider).submit(DeletionRequest(
          uid: uid,
          requestedAt: DateTime.now(),
          reason: reason,
        ));

    // 2. Purge local caches (the server owns the authoritative cascade).
    if (uid != null) {
      try {
        await _ref.read(onboardingRepositoryProvider).clear(uid);
      } catch (_) {}
    }
    _ref.read(matchesControllerProvider.notifier).clear();
    _ref.read(messagingControllerProvider.notifier).clear();
    _ref.read(blockedProfilesProvider.notifier).clear();
    _ref.read(savedPlacesProvider.notifier).clear();
    _ref.read(plannedDatesProvider.notifier).clear();
    _ref.read(safetyPlansProvider.notifier).clear();
    _ref.read(notificationsControllerProvider.notifier).clear();

    // 3. Delete the auth account. This removes it — it is not a deactivation.
    await _ref.read(authControllerProvider.notifier).deleteAccount();
  }
}

final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository>(
  (ref) => InMemoryAccountDeletionRepository(),
);

final accountDeletionServiceProvider =
    Provider<AccountDeletionService>((ref) => AccountDeletionService(ref));
