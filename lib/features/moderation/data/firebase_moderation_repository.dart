import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/moderation_case.dart';
import '../domain/moderation_repository.dart';

/// Production [ModerationRepository]. Clients may only SUBMIT reports; the queue
/// is server-only (admins read via custom-claim rules, never end users). A
/// submitted `moderationCases` document must carry `reporterId == auth.uid` and
/// `status == 'pending'` (enforced by the rules); the server's
/// onModerationCaseCreated trigger acknowledges receipt to the reporter.
class FirebaseModerationRepository implements ModerationRepository {
  FirebaseModerationRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String _clip(String s, int max) => s.length > max ? s.substring(0, max) : s;

  @override
  Future<void> submit(ModerationCase moderationCase) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final s = moderationCase.subject;
    final note = moderationCase.note;
    final snapshot = s.contentSnapshot;
    await _db.collection('moderationCases').add({
      'reporterId': uid, // rules require this to equal the caller
      'subjectId': s.targetUserId,
      'subjectType': s.type.name,
      'reason': moderationCase.reason.name,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      if (s.targetName != null) 'subjectName': s.targetName,
      if (s.messageId != null) 'messageId': s.messageId,
      if (s.photoId != null) 'photoId': s.photoId,
      if (note != null && note.trim().isNotEmpty) 'note': _clip(note, 2000),
      if (snapshot != null && snapshot.isNotEmpty)
        'contentSnapshot': _clip(snapshot, 5000),
    });
  }

  // The queue and case status are server-only; a client never reads or mutates
  // them. These satisfy the interface but intentionally do nothing here.
  @override
  Future<List<ModerationCase>> queue({ModerationStatus? status}) async =>
      const [];

  @override
  Future<void> updateStatus(String id, ModerationStatus status,
      {String? resolutionNote}) async {}
}
