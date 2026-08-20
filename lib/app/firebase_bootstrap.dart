import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/onboarding/application/onboarding_providers.dart';
import '../features/onboarding/data/firestore_onboarding_repository.dart';

/// Attempts to initialize Firebase and, on success, returns the provider
/// overrides that switch the app from the in-memory mocks to the real
/// Firebase-backed repositories.
///
/// If Firebase isn't configured yet (no `google-services.json` /
/// `GoogleService-Info.plist` / generated options), initialization throws and
/// we return no overrides — so the app keeps running on the mocks. Add your
/// Firebase config (via `flutterfire configure`) and it flips over
/// automatically, with no code changes.
Future<List<Override>> firebaseBootstrap() async {
  try {
    await Firebase.initializeApp();

    // Offline-first: keep a local cache so reads/writes work without a
    // connection and sync when it returns (Step 10 — graceful offline). Must be
    // set before Firestore is first used, which is here.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 100 * 1024 * 1024,
    );

    return [
      authRepositoryProvider.overrideWith((ref) {
        final repo = FirebaseAuthRepository();
        ref.onDispose(repo.dispose);
        return repo;
      }),
      onboardingRepositoryProvider.overrideWithValue(
        FirestoreOnboardingRepository(FirebaseFirestore.instance),
      ),
    ];
  } catch (e) {
    // No config, or init failed — fall back to the in-memory mocks so the app
    // still runs. The raw error never reaches a user (debug log only).
    debugPrint('Firebase not configured — running on in-memory mocks. ($e)');
    return const [];
  }
}
