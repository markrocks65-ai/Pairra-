import 'dart:async';

import '../domain/message.dart';
import '../domain/messaging_repository.dart';

/// Session-scoped in-memory [MessagingRepository] for dev/mock and tests. Keeps
/// a per-conversation message list and re-emits on send, so the UI behaves the
/// same as against a real backend (without persistence).
class InMemoryMessagingRepository implements MessagingRepository {
  final Map<String, List<Message>> _messages = {};
  final Map<String, StreamController<List<Message>>> _controllers = {};

  @override
  String get selfId => Message.selfId;

  StreamController<List<Message>> _controllerFor(String cid) =>
      _controllers.putIfAbsent(
        cid,
        () => StreamController<List<Message>>.broadcast(
          onListen: () => _emit(cid),
        ),
      );

  void _emit(String cid) {
    if (_controllers[cid]?.hasListener ?? false) {
      _controllers[cid]!.add(List.unmodifiable(_messages[cid] ?? const []));
    }
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) =>
      _controllerFor(conversationId).stream;

  @override
  Future<void> sendText(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final msg = Message(
      id: '${conversationId}_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: selfId,
      type: MessageType.text,
      text: trimmed,
      sentAt: DateTime.now(),
    );
    (_messages[conversationId] ??= []).add(msg);
    _emit(conversationId);
  }

  @override
  Future<void> markRead(String conversationId) async {}
}
