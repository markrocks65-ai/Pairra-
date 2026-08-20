import 'message.dart';

/// Backend for a conversation's messages. Messages live at
/// `conversations/{cid}/messages` (participant-scoped, immutable, authored only
/// as yourself). The `reads` map + read receipts are driven by the server
/// `markRead` callable — clients never write conversation metadata directly.
abstract interface class MessagingRepository {
  /// The signed-in user's id, used to decide which messages are "mine".
  String get selfId;

  /// Live stream of a conversation's messages, oldest → newest.
  Stream<List<Message>> watchMessages(String conversationId);

  /// Send a text message as the signed-in user.
  Future<void> sendText(String conversationId, String text);

  /// Mark the conversation read up to now (server-side read position).
  Future<void> markRead(String conversationId);
}
