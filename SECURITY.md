# PAIRRA Security Model

This document is the authoritative reference for PAIRRA's security posture and
the trust boundaries every contributor must respect. PAIRRA handles sensitive
data (orientation, sexual roles, location, private messages), so the rules here
are not optional.

## Core principle: the client is never trusted for privileged state

Anything that confers trust, unlocks paid features, or exposes another user's
data is decided by the **server**, never the client. The client may *request*;
only the server may *grant*.

### Server-only fields (Admin SDK writes only)

These live on `users/{uid}` and are blocked from all client writes by
`firestore.rules`:

| Field | Set by | Why it's server-only |
|-------|--------|----------------------|
| `verification` | Verification callback (Onfido/etc.) | Prevents self-verifying |
| `plan`, `planUpdatedAt` | RevenueCat webhook | Prevents self-granting premium |
| `identityStatus` | Verification pipeline | Identity trust |
| `phoneVerified`, `phoneNumber` | Derived from Firebase Auth | Prevents phone self-attestation |

The onboarding/profile serializer (`OnboardingSerializer`) must **never**
persist any of these — enforced by a regression test in
`test/firebase_serialization_test.dart`. `phoneVerified` is derived in the app
from `FirebaseAuth.currentUser.phoneNumber`, never from a Firestore field.

## Firestore rules summary (`firestore.rules`)

- `users/{uid}` — owner read/write only; server-only fields blocked; `email` and
  `createdAt` immutable after create.
- `users/{uid}/private/**`, `users/{uid}/{document=**}` — owner only.
- `publicProfiles/{uid}` — **the only way one user sees another.** Signed-in
  read, **server-write-only**. A Cloud Function projects *non-sensitive* fields
  here. It must **exclude**: sexual roles, `preferences`, orientation unless the
  user made it public, and any coordinates. Distance is precomputed coarse.
- `matches/{matchId}` — participant read only; server writes.
- `conversations/{cid}` + `messages/**` — participant-scoped. You can only read a
  conversation you're in and only author messages as yourself. Prevents message
  IDOR. Messages are immutable client-side.
- `moderationCases/{id}` — create-only; `reporterId == auth.uid`; must open as
  `pending` with no resolution note; text fields size-bounded. **No client read**
  (reporters can't see who reported them or tamper with triage).
- `deletionRequests/{id}` — user may create their own; no client read/update.
- `_server/**` — never client-accessible.

## Cloud Storage rules (`storage.rules`)

- `profilePhotos/{uid}/**` — owner-only read AND write (raw, pre-moderation
  uploads; images only, < 8 MB). Other users can never read raw uploads.
- `publicPhotos/{uid}/**` — signed-in read, **server-write-only**: moderated
  derivatives published by the server after image review.

## Location handling

- PAIRRA never stores or exposes an exact position. Only coarse values live in
  the owner-only profile draft.
- **Distance must be computed server-side.** Never ship another user's
  coordinates (even approximate) to the client — that enables triangulation.
  The `publicProfiles` projection carries a precomputed coarse distance/band,
  not lat/lng. Coordinates must be rounded before storage server-side.

## Required Cloud Functions (Admin SDK)

None exist yet; the rules are safe-by-default without them (nothing gets granted
or projected), but the product needs these before launch:

1. **Public profile projection** — on profile write, project non-sensitive fields
   (and coarse distance) into `publicProfiles/{uid}`, honoring visibility
   settings and `appearInDiscovery`.
2. **Account-deletion cascade** — on `deletionRequests` create: recursively
   delete `users/{uid}` subcollections, `publicProfiles/{uid}`, storage photos,
   and anonymize the user's references in others' matches/conversations, per the
   retention policy. (A client `delete()` does **not** remove subcollections.)
3. **Entitlement webhook** — RevenueCat → set `plan`/`planUpdatedAt`. The client
   `isPremium` is a UX hint only; **re-check entitlement server-side** for any
   action that costs money or compute.
4. **Verification callback** — set `verification`/`identityStatus` from the KYC
   provider's signed webhook.
5. **Image moderation** — review `profilePhotos` uploads, publish approved
   derivatives to `publicPhotos`.
6. **Moderation review** — the only reader/writer of `moderationCases` triage.

## API keys & third-party services

- **No secrets in the client repo.** Keys are injected via provider overrides.
- **Google Places** and any **AI model** key must be **proxied through a backend**
  (or, for Places, heavily API-restricted + app-attested). A key shipped in a
  mobile binary is extractable — treat it as public.
- **RevenueCat** validates purchases server-side; the app only reflects the
  resulting entitlement.
- **AI**: requests carry only sanitized/aggregate data (shared interests, counts,
  coarse compatibility reasons) — never another user's raw profile, hidden
  scores, or sensitive preferences. A model-backed provider must keep this
  boundary and run behind a backend proxy.

## Client-side gates (accepted limitations)

Premium features and the free-like cap are enforced client-side for UX. A
modified client can bypass the *UI*, so anything with real cost (server-enforced
like limits, AI usage, media) must be re-validated server-side. Safety features
are never gated.
