import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_auth_repository.dart';
import '../domain/auth_repository.dart';

/// The active [AuthRepository]. Defaults to the in-memory [MockAuthRepository]
/// so the app runs with no backend configured.
///
/// To go live, override this in `ProviderScope(overrides: [...])` with a
/// `FirebaseAuthRepository()` once Firebase is set up — nothing else changes:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     authRepositoryProvider.overrideWithValue(FirebaseAuthRepository()),
///   ],
///   child: const PairraApp(),
/// )
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = MockAuthRepository();
  ref.onDispose(repo.dispose);
  return repo;
});
