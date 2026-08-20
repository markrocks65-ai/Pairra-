import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/discovery/application/discovery_providers.dart';
import '../features/discovery/application/matches_controller.dart';
import '../features/discovery/data/firebase_discovery_repository.dart';
import '../features/discovery/data/firebase_likes_repository.dart';
import '../features/discovery/data/firebase_matches_repository.dart';
import '../features/messaging/application/messaging_controller.dart';
import '../features/messaging/data/firebase_messaging_repository.dart';
import '../features/onboarding/application/onboarding_providers.dart';
import '../features/onboarding/data/firestore_onboarding_repository.dart';
import '../features/settings/application/account_deletion_service.dart';
import '../features/settings/data/firebase_account_deletion_repository.dart';
import '../firebase_options.dart';

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
    // Explicit generated options (lib/firebase_options.dart) so init works on
    // iOS without a bundled GoogleService-Info.plist and on Android alongside
    // the google-services config — same real project (pairra-app-e104f).
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

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
      // Real account deletion: calls the server-side `deleteAccount` Cloud
      // Function (authoritative cascade + Auth deletion). Required by Apple
      // App Review guideline 5.1.1(v) — deletion must actually remove the
      // account, not just deactivate it.
      accountDeletionRepositoryProvider.overrideWithValue(
        FirebaseAccountDeletionRepository(),
      ),
      // Real discovery: ranks actual onboarded users via the discoverProfiles
      // Cloud Function (sanitized cards). Replaces the hardcoded mock list, so
      // no fabricated profiles ship (Apple 2.1). An empty result shows the
      // honest empty state rather than fake people.
      discoveryRepositoryProvider.overrideWithValue(
        FirebaseDiscoveryRepository(),
      ),
      // Real like/pass: writes owner-scoped decision docs; a mutual like fires
      // the server's onLikeCreated trigger to create the match + conversation.
      likesRepositoryProvider.overrideWithValue(
        FirebaseLikesRepository(
          FirebaseFirestore.instance,
          FirebaseAuth.instance,
        ),
      ),
      // Real matches: live stream of server-created matches (hydrated from each
      // other participant's public card); unmatch goes through the callable.
      matchesRepositoryProvider.overrideWithValue(
        FirebaseMatchesRepository(
          FirebaseFirestore.instance,
          FirebaseAuth.instance,
          FirebaseFunctions.instance,
        ),
      ),
      // Real messaging: live message threads, sends authored as the user, and
      // server-side markRead. Message data lives at conversations/{cid}/messages.
      messagingRepositoryProvider.overrideWithValue(
        FirebaseMessagingRepository(
          FirebaseFirestore.instance,
          FirebaseAuth.instance,
          FirebaseFunctions.instance,
        ),
      ),
    ];
  } catch (e) {
    // No config, or init failed — fall back to the in-memory mocks so the app
    // still runs. The raw error never reaches a user (debug log only).
    debugPrint('Firebase not configured — running on in-memory mocks. ($e)');
    return const [];
  }
}
