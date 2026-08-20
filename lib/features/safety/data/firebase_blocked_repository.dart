import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/blocked_repository.dart';
import '../domain/blocked_user.dart';

/// Production [BlockedRepository]. Writes owner-scoped block entries at
/// `users/{uid}/private/blocked/items/{targetUid}`. The server reads these for
/// mutual invisibility in discovery and matching; a like never becomes a match
/// across a block in either direction.
class FirebaseBlockedRepository implements BlockedRepository {
  FirebaseBlockedRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('private')
        .doc('blocked').collection('items');
  }

  @override
  Stream<List<BlockedUser>> watchBlocked() {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col.snapshots().map((snap) => snap.docs
        .map((d) => BlockedUser(d.id, name: d.data()['name'] as String?))
        .toList());
  }

  @override
  Future<void> block(String id, {String? name}) async {
    final col = _col();
    if (col == null || id.isEmpty) return;
    await col.doc(id).set({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unblock(String id) async {
    final col = _col();
    if (col == null || id.isEmpty) return;
    await col.doc(id).delete();
  }
}
