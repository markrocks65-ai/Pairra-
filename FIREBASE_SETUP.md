# Firebase setup for PAIRRA

The app is **wired for Firebase but runs on in-memory mocks until you connect a
project.** `main()` calls `firebaseBootstrap()`, which tries `Firebase.initializeApp()`:

- **No config present** → initialization fails, no provider overrides, app runs
  on the mock repositories (exactly as before).
- **Config present** → the app switches to `FirebaseAuthRepository` +
  `FirestoreOnboardingRepository` automatically. **No code changes needed.**

## What's already implemented

- `lib/features/auth/data/firebase_auth_repository.dart` — full `AuthRepository`
  on Firebase Auth (email/password, email verification, password reset, phone
  verification via link, account deletion) + consent stored in `users/{uid}`.
- `lib/features/onboarding/data/firestore_onboarding_repository.dart` +
  `onboarding_serialization.dart` — persists the onboarding/profile draft at
  `users/{uid}/private/profile`.
- `lib/app/firebase_bootstrap.dart` — the auto-switch.
- `firestore.rules` — least-privilege, owner-scoped; server-only fields
  (verification, entitlements) are never client-writable.

## The remaining steps (require your Firebase account — I can't do these)

1. Create a Firebase project at <https://console.firebase.google.com>.
2. Enable **Authentication → Email/Password** (and Phone, if you want phone
   verification).
3. Create a **Firestore** database.
4. From the project root, generate the platform config:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This adds `google-services.json` (Android), `GoogleService-Info.plist`
   (iOS/macOS), and `lib/firebase_options.dart`.
5. (Recommended) Have `bootstrap` use the generated options for reliability:
   in `firebase_bootstrap.dart`, change `Firebase.initializeApp()` to
   `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
   and import `firebase_options.dart`.
6. Deploy the security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
7. Run the app — it now uses Firebase.

## Offline & failure behavior

- `firebaseBootstrap()` enables Firestore local persistence (100 MB cache), so
  reads/writes work offline and sync on reconnect.
- Data-layer failures (offline with no cache, permission denied) never surface a
  raw exception: auth errors map to friendly `AuthFailure` messages, and the
  onboarding load falls back to a fresh draft instead of hanging on a spinner.

## Security-rule tests (verified against the emulator)

`firestore.rules` is covered by real emulator tests in `firestore_rules_test/`
(23 cases: owner scoping, server-only fields, private/public split,
participant-scoped messaging, moderation confidentiality, deletion requests).

```bash
cd firestore_rules_test && npm install
# from the repo root (needs the Firestore emulator + a JDK):
firebase emulators:exec --project demo-pairra --only firestore \
  "node --test firestore_rules_test/rules.test.mjs"
```

> These tests caught a real bug: under `rules_version 2` a bare
> `match /{document=**}` matches **zero** segments too, so the per-user
> catch-all was also matching `users/{uid}` and letting a client write
> `plan` / `verification` / `phoneVerified` straight onto their own doc. The
> subcollection match now requires a `{sub}` segment. Re-run these tests
> whenever you touch `firestore.rules`.

## Not yet wired (future increments — separate phases)

- **Public profile projection** (`publicProfiles/{uid}`): server-write-only by
  rule, so it needs a Cloud Function to project non-sensitive fields. Discovery
  reads it once that exists; until then discovery/matches/messaging keep their
  in-memory stores (the seams are ready).
- Verification **results** require a Cloud Function that writes the server-only
  `verification` field after a provider webhook — clients can never set it.
- Storage, Cloud Functions, and Messaging packages are intentionally NOT added
  yet (later phases).
