import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/likes_repository.dart';

/// Production [LikesRepository]. Writes owner-scoped like/pass documents under
/// `users/{uid}/private/...`, which the rules permit only for the owner. A like
/// write fires the server's `onLikeCreated` trigger, which creates the match +
/// conversation when the like is reciprocal.
class FirebaseLikesRepository implements LikesRepository {
  FirebaseLikesRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<void> like(String targetUid, {bool superLike = false}) async {
    final uid = _uid;
    if (uid == null || targetUid.isEmpty) return;
    await _db.doc('users/$uid/private/likes/items/$targetUid').set({
      'targetUid': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
      if (superLike) 'superLike': true,
    });
  }

  @override
  Future<void> pass(String targetUid) async {
    final uid = _uid;
    if (uid == null || targetUid.isEmpty) return;
    await _db.doc('users/$uid/private/passes/items/$targetUid').set({
      'targetUid': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
