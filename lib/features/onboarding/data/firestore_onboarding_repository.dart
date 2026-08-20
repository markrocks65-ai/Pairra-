import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/onboarding_profile.dart';
import '../domain/onboarding_repository.dart';
import 'onboarding_serialization.dart';

/// Firestore-backed [OnboardingRepository]. Persists the onboarding/profile
/// draft at `users/{uid}/private/profile`, so it resumes across launches and
/// devices. Drop-in for the in-memory default (override the provider once
/// Firebase is configured).
///
/// Security rules (see `firestore.rules`) restrict this document to its owner.
class FirestoreOnboardingRepository implements OnboardingRepository {
  FirestoreOnboardingRepository(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('private').doc('profile');

  @override
  Future<OnboardingProfile> load(String uid) async {
    final snap = await _doc(uid).get();
    final data = snap.data();
    if (data == null) return const OnboardingProfile();
    return OnboardingSerializer.fromMap(data);
  }

  @override
  Future<void> save(String uid, OnboardingProfile profile) async {
    await _doc(uid).set(OnboardingSerializer.toMap(profile));
  }

  @override
  Future<void> clear(String uid) async {
    await _doc(uid).delete();
  }
}
