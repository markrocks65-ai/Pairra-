import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/message.dart';
import '../domain/messaging_repository.dart';

/// Production [MessagingRepository]. Streams `conversations/{cid}/messages`
/// (participant-scoped, immutable), sends messages authored as the signed-in
/// user, and marks a conversation read via the server `markRead` callable. A
/// message's own senderId is normalized to [Message.selfId] so the UI's
/// `isMine` check works unchanged.
class FirebaseMessagingRepository implements MessagingRepository {
  FirebaseMessagingRepository(this._db, this._auth, this._functions);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  static const int _maxLen = 5000;
  static const int _pageSize = 100;

  @override
  String get selfId => _auth.currentUser?.uid ?? Message.selfId;

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final uid = _auth.currentUser?.uid;
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(_pageSize)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        final data = d.data();
        final rawSender = (data['senderId'] ?? '').toString();
        final ts = data['createdAt'];
        return Message(
          id: d.id,
          conversationId: conversationId,
          // Normalize my own uid to the selfId sentinel so isMine works.
          senderId: rawSender == uid ? Message.selfId : rawSender,
          type: MessageType.text,
          text: data['text'] as String?,
          sentAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
          status: MessageStatus.sent,
        );
      }).toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt)); // oldest → newest
      return list;
    });
  }

  @override
  Future<void> sendText(String conversationId, String text) async {
    final uid = _auth.currentUser?.uid;
    final trimmed = text.trim();
    if (uid == null || trimmed.isEmpty) return;
    await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
      'senderId': uid,
      'text': trimmed.length > _maxLen ? trimmed.substring(0, _maxLen) : trimmed,
      'createdAt': FieldValue.serverTimestamp(),
      // Consumed by the server-side rate-limit hook.
      'createdAtIso': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> markRead(String conversationId) async {
    try {
      await _functions.httpsCallable('markRead').call({'cid': conversationId});
    } catch (_) {}
  }
}
