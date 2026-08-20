// Security-rule tests for PAIRRA's firestore.rules, run against the Firestore
// emulator. These VERIFY the trust boundaries in firestore.rules — owner
// scoping, server-only fields, the public/private profile split, participant-
// scoped messaging, moderation confidentiality, and deletion requests.
//
// Run from the repo root:  npm --prefix firestore_rules_test test
// (which wraps `firebase emulators:exec --only firestore "node --test ..."`).

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-pairra',
    firestore: { rules: readFileSync('firestore.rules', 'utf8') },
  });
});
after(async () => {
  await testEnv.cleanup();
});
beforeEach(async () => {
  await testEnv.clearFirestore();
});

const as = (uid) => testEnv.authenticatedContext(uid).firestore();
const anon = () => testEnv.unauthenticatedContext().firestore();
const seed = (fn) =>
  testEnv.withSecurityRulesDisabled((ctx) => fn(ctx.firestore()));

describe('users/{uid} account doc', () => {
  it('owner can create with allowed fields', async () => {
    await assertSucceeds(
      setDoc(doc(as('alice'), 'users/alice'), {
        email: 'a@x.com',
        createdAt: 1,
        consent: { terms: true },
      }),
    );
  });

  it('cannot introduce a server-only field on create (plan / verification / phoneVerified)', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'users/alice'), { email: 'a', plan: 'premium' }),
    );
    await assertFails(
      setDoc(doc(as('alice'), 'users/alice'), {
        email: 'a',
        verification: { verified: true },
      }),
    );
    await assertFails(
      setDoc(doc(as('alice'), 'users/alice'), {
        email: 'a',
        phoneVerified: true,
      }),
    );
  });

  it('cannot create a doc under another uid', async () => {
    await assertFails(setDoc(doc(as('alice'), 'users/bob'), { email: 'x' }));
  });

  it('cannot read another user account doc', async () => {
    await seed((db) => setDoc(doc(db, 'users/bob'), { email: 'b', createdAt: 1 }));
    await assertFails(getDoc(doc(as('alice'), 'users/bob')));
  });

  it('owner can read own account doc', async () => {
    await seed((db) => setDoc(doc(db, 'users/alice'), { email: 'a', createdAt: 1 }));
    await assertSucceeds(getDoc(doc(as('alice'), 'users/alice')));
  });

  it('email and createdAt are immutable after create', async () => {
    await seed((db) =>
      setDoc(doc(db, 'users/alice'), { email: 'a@x.com', createdAt: 1 }),
    );
    await assertFails(
      updateDoc(doc(as('alice'), 'users/alice'), { email: 'new@x.com' }),
    );
    await assertFails(
      updateDoc(doc(as('alice'), 'users/alice'), { createdAt: 2 }),
    );
  });

  it('cannot add a server-only field on update, but can update a normal field', async () => {
    await seed((db) =>
      setDoc(doc(db, 'users/alice'), { email: 'a@x.com', createdAt: 1 }),
    );
    await assertFails(
      updateDoc(doc(as('alice'), 'users/alice'), { plan: 'premium' }),
    );
    await assertSucceeds(
      updateDoc(doc(as('alice'), 'users/alice'), { consent: { terms: true } }),
    );
  });
});

describe('users/{uid}/private/profile (owner-only)', () => {
  it('owner can write and read', async () => {
    await assertSucceeds(
      setDoc(doc(as('alice'), 'users/alice/private/profile'), { bio: 'hi' }),
    );
    await assertSucceeds(getDoc(doc(as('alice'), 'users/alice/private/profile')));
  });

  it('another user cannot read the private draft', async () => {
    await seed((db) =>
      setDoc(doc(db, 'users/alice/private/profile'), { bio: 'secret' }),
    );
    await assertFails(getDoc(doc(as('bob'), 'users/alice/private/profile')));
  });
});

describe('publicProfiles/{uid} (server projection)', () => {
  it('any signed-in user can read', async () => {
    await seed((db) =>
      setDoc(doc(db, 'publicProfiles/alice'), { displayName: 'Alex' }),
    );
    await assertSucceeds(getDoc(doc(as('bob'), 'publicProfiles/alice')));
  });

  it('an unauthenticated user cannot read', async () => {
    await seed((db) =>
      setDoc(doc(db, 'publicProfiles/alice'), { displayName: 'Alex' }),
    );
    await assertFails(getDoc(doc(anon(), 'publicProfiles/alice')));
  });

  it('a client can NEVER write it (projection is server-only)', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'publicProfiles/alice'), { displayName: 'Alex' }),
    );
  });
});

describe('conversations + messages (participant-scoped, anti-IDOR)', () => {
  const seedConvo = () =>
    seed((db) =>
      setDoc(doc(db, 'conversations/c1'), { participants: ['alice', 'bob'] }),
    );

  it('a participant can read; a non-participant cannot', async () => {
    await seedConvo();
    await assertSucceeds(getDoc(doc(as('alice'), 'conversations/c1')));
    await assertFails(getDoc(doc(as('carol'), 'conversations/c1')));
  });

  it('clients cannot create conversations (server-created on match)', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'conversations/x'), {
        participants: ['alice', 'bob'],
      }),
    );
  });

  it('a participant may post a message only as themselves', async () => {
    await seedConvo();
    await assertSucceeds(
      setDoc(doc(as('alice'), 'conversations/c1/messages/m1'), {
        senderId: 'alice',
        text: 'hello',
      }),
    );
    // Spoofing another sender is denied.
    await assertFails(
      setDoc(doc(as('alice'), 'conversations/c1/messages/m2'), {
        senderId: 'bob',
        text: 'framed',
      }),
    );
  });

  it('a non-participant cannot read or post messages', async () => {
    await seedConvo();
    await seed((db) =>
      setDoc(doc(db, 'conversations/c1/messages/m0'), {
        senderId: 'alice',
        text: 'hi',
      }),
    );
    await assertFails(getDoc(doc(as('carol'), 'conversations/c1/messages/m0')));
    await assertFails(
      setDoc(doc(as('carol'), 'conversations/c1/messages/m3'), {
        senderId: 'carol',
        text: 'intrude',
      }),
    );
  });
});

describe('matches (server-created, participant read)', () => {
  it('a participant can read; a non-participant cannot; clients cannot write', async () => {
    await seed((db) =>
      setDoc(doc(db, 'matches/m1'), { participants: ['alice', 'bob'] }),
    );
    await assertSucceeds(getDoc(doc(as('alice'), 'matches/m1')));
    await assertFails(getDoc(doc(as('carol'), 'matches/m1')));
    await assertFails(
      setDoc(doc(as('alice'), 'matches/m2'), { participants: ['alice', 'bob'] }),
    );
  });
});

describe('moderationCases (file-only, confidential)', () => {
  it('a user can file a report about someone', async () => {
    await assertSucceeds(
      setDoc(doc(as('alice'), 'moderationCases/r1'), {
        reporterId: 'alice',
        reason: 'harassment',
        status: 'pending',
      }),
    );
  });

  it('cannot file as a different reporter (no framing a third party)', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'moderationCases/r2'), {
        reporterId: 'bob',
        reason: 'harassment',
      }),
    );
  });

  it('cannot open a case pre-resolved or with a resolution note', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'moderationCases/r3'), {
        reporterId: 'alice',
        reason: 'spam',
        status: 'dismissed',
      }),
    );
    await assertFails(
      setDoc(doc(as('alice'), 'moderationCases/r4'), {
        reporterId: 'alice',
        reason: 'spam',
        resolutionNote: 'handled',
      }),
    );
  });

  it('cannot read a case (reporter identity stays confidential)', async () => {
    await seed((db) =>
      setDoc(doc(db, 'moderationCases/r5'), {
        reporterId: 'bob',
        reason: 'x',
        status: 'pending',
      }),
    );
    await assertFails(getDoc(doc(as('alice'), 'moderationCases/r5')));
  });
});

describe('deletionRequests (file-your-own only)', () => {
  it('a user can file their own request', async () => {
    await assertSucceeds(
      setDoc(doc(as('alice'), 'deletionRequests/d1'), {
        uid: 'alice',
        requestedAt: 1,
      }),
    );
  });

  it('cannot file for another user, and cannot read the queue', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'deletionRequests/d2'), { uid: 'bob' }),
    );
    await seed((db) => setDoc(doc(db, 'deletionRequests/d3'), { uid: 'alice' }));
    await assertFails(getDoc(doc(as('alice'), 'deletionRequests/d3')));
  });
});
