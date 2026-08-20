import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/match.dart';
import '../domain/matches_repository.dart';
import 'public_card_mapper.dart';

/// Production [MatchesRepository]. Streams the `matches` collection for the
/// signed-in user (server is the only writer), hydrating each match with the
/// other participant's sanitized `publicProfiles/{uid}` card. Unmatching calls
/// the server `unmatch` callable.
class FirebaseMatchesRepository implements MatchesRepository {
  FirebaseMatchesRepository(this._db, this._auth, this._functions);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  @override
  Stream<List<Match>> watchMatches() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .collection('matches')
        .where('participants', arrayContains: uid)
        .snapshots()
        .asyncMap((snap) async {
      final active = snap.docs
          .where((d) => (d.data()['unmatched'] as bool?) != true)
          .toList();
      final matches = await Future.wait(active.map((d) => _toMatch(d, uid)));
      final result = matches.whereType<Match>().toList()
        ..sort((a, b) => b.matchedAt.compareTo(a.matchedAt));
      return result;
    });
  }

  Future<Match?> _toMatch(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String selfUid,
  ) async {
    final data = doc.data();
    final participants =
        (data['participants'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final otherUid = participants.firstWhere(
      (p) => p != selfUid,
      orElse: () => '',
    );
    if (otherUid.isEmpty) return null;

    final pubSnap = await _db.doc('publicProfiles/$otherUid').get();
    final card = pubSnap.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return Match(
      id: doc.id,
      otherId: otherUid,
      profile: onboardingProfileFromPublicCard(
        Map<String, dynamic>.from(card),
        uidForPhotos: otherUid,
      ),
      // publicProfiles doesn't carry a server compatibility score; matches show
      // the profile without a recomputed percentage (roles/prefs aren't shared).
      compatibilityPercent: (card['compatibility'] as num?)?.toInt() ?? 0,
      matchedAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  @override
  Future<void> unmatch(String matchId) async {
    if (matchId.isEmpty) return;
    await _functions.httpsCallable('unmatch').call({'matchId': matchId});
  }
}
