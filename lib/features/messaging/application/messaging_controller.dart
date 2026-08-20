import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discovery/domain/match.dart';
import '../data/in_memory_messaging_repository.dart';
import '../domain/conversation.dart';
import '../domain/message.dart';
import '../domain/messaging_repository.dart';

/// Messaging store. Conversations are derived from (now real) matches and each
/// is seeded with a single, non-repeating safety reminder shown locally on top
/// of the live message thread. Message send/stream/read go through a
/// [MessagingRepository] (Firestore in production, in-memory in dev/tests).
@immutable
class MessagingState {
  const MessagingState({this.conversations = const {}, this.messages = const {}});

  final Map<String, Conversation> conversations;
  final Map<String, List<Message>> messages;

  /// Conversations, most-recent activity first.
  List<Conversation> get ordered => conversations.values.toList()
    ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

  List<Message> messagesFor(String conversationId) =>
      messages[conversationId] ?? const [];

  Conversation? conversation(String id) => conversations[id];

  /// True when the user hasn't sent anything yet (only the seeded system note).
  bool isFresh(String conversationId) =>
      messagesFor(conversationId).every((m) => m.senderId != Message.selfId);

  MessagingState copyWith({
    Map<String, Conversation>? conversations,
    Map<String, List<Message>>? messages,
  }) =>
      MessagingState(
        conversations: conversations ?? this.conversations,
        messages: messages ?? this.messages,
      );
}

class MessagingController extends StateNotifier<MessagingState> {
  MessagingController(this._repository) : super(const MessagingState());

  final MessagingRepository _repository;
  final Map<String, Message> _systemNotes = {};
  final Map<String, StreamSubscription<List<Message>>> _subs = {};

  /// Creates a conversation for any match that doesn't have one yet, seeded with
  /// a subtle one-time safety reminder. Never removes existing ones, so open
  /// threads survive when new matches arrive.
  void syncMatches(List<Match> matches) {
    final conversations = {...state.conversations};
    final messages = {...state.messages};
    var changed = false;

    for (final match in matches) {
      if (conversations.containsKey(match.id)) continue;
      final name = (match.profile.displayName ?? 'your match').trim();
      final reminder = Message(
        id: '${match.id}_safety',
        conversationId: match.id,
        senderId: Message.systemId,
        type: MessageType.system,
        text: 'You matched with $name. A quick reminder: for a first meet-up, '
            'pick a public place and let a friend know your plans.',
        sentAt: match.matchedAt,
      );
      _systemNotes[match.id] = reminder;
      messages[match.id] = [reminder];
      conversations[match.id] = Conversation(
        id: match.id,
        otherId: match.otherId.isNotEmpty ? match.otherId : match.id,
        otherProfile: match.profile,
        lastActivity: match.matchedAt,
        lastMessage: reminder,
      );
      changed = true;
    }

    if (changed) {
      state = state.copyWith(conversations: conversations, messages: messages);
    }
  }

  /// Begin streaming a conversation's live messages (call when it's opened).
  void openConversation(String conversationId) {
    if (_subs.containsKey(conversationId)) return;
    _subs[conversationId] = _repository.watchMessages(conversationId).listen(
          (msgs) => _applyThread(conversationId, msgs),
          onError: (_) {},
        );
  }

  void _applyThread(String conversationId, List<Message> streamed) {
    if (!mounted) return;
    final note = _systemNotes[conversationId];
    final thread = <Message>[?note, ...streamed];
    final convo = state.conversations[conversationId];
    final last = streamed.isNotEmpty ? streamed.last : note;
    state = state.copyWith(
      messages: {...state.messages, conversationId: thread},
      conversations: convo == null
          ? state.conversations
          : {
              ...state.conversations,
              conversationId: convo.copyWith(
                lastMessage: last,
                lastActivity: last?.sentAt ?? convo.lastActivity,
              ),
            },
    );
  }

  Future<void> sendText(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (!state.conversations.containsKey(conversationId)) return;
    // The sent message arrives back through the live stream (Firestore reflects
    // the pending write immediately via its local cache).
    await _repository.sendText(conversationId, trimmed);
  }

  void markRead(String conversationId) {
    _repository.markRead(conversationId);
    final conversation = state.conversations[conversationId];
    if (conversation == null || conversation.unreadCount == 0) return;
    state = state.copyWith(conversations: {
      ...state.conversations,
      conversationId: conversation.copyWith(unreadCount: 0),
    });
  }

  /// Removes a conversation locally (on unmatch/block).
  void removeConversation(String conversationId) {
    _subs.remove(conversationId)?.cancel();
    _systemNotes.remove(conversationId);
    if (!state.conversations.containsKey(conversationId)) return;
    state = state.copyWith(
      conversations: {...state.conversations}..remove(conversationId),
      messages: {...state.messages}..remove(conversationId),
    );
  }

  void clear() {
    for (final s in _subs.values) {
      s.cancel();
    }
    _subs.clear();
    _systemNotes.clear();
    state = const MessagingState();
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    super.dispose();
  }
}

/// The messaging backend. Defaults to an in-memory store; overridden with a
/// Firestore-backed repository in firebaseBootstrap.
final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => InMemoryMessagingRepository(),
);
