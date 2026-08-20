import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/auth/application/auth_providers.dart';
import 'package:pairra/features/auth/data/mock_auth_repository.dart';
import 'package:pairra/features/settings/application/account_deletion_service.dart';
import 'package:pairra/features/settings/data/in_memory_account_deletion_repository.dart';
import 'package:pairra/features/settings/domain/deletion_request.dart';

void main() {
  test('deletion repository records a request', () async {
    final repo = InMemoryAccountDeletionRepository();
    await repo.submit(DeletionRequest(uid: 'u1', requestedAt: DateTime.now()));
    expect(repo.requests.single.uid, 'u1');
    expect(repo.requests.single.mode, DeletionMode.deleteEverything);
  });

  test('deleting the account files a backend workflow request (not deactivate)',
      () async {
    final container = ProviderContainer(overrides: [
      // Fast mock so no auth timers linger.
      authRepositoryProvider.overrideWithValue(
        MockAuthRepository(latency: Duration.zero, initialDelay: Duration.zero),
      ),
    ]);
    addTearDown(container.dispose);

    final repo = container.read(accountDeletionRepositoryProvider)
        as InMemoryAccountDeletionRepository;

    await container
        .read(accountDeletionServiceProvider)
        .deleteAccount(reason: 'moving on');

    // The deletion workflow was triggered (server performs the cascade).
    expect(repo.requests.length, 1);
    expect(repo.requests.single.reason, 'moving on');
  });
}
