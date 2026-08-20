import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discovery/domain/match.dart';
import '../domain/conversation.dart';
import '../domain/message.dart';

/// In-memory messaging store (session-scoped), same pattern as the other mock
/// stores. Swap for a Firestore-backed repository later — the UI reads this
/// provider unchanged. Conversations are derived from matches; each new one is
/// seeded with a single, non-repeating safety reminder.
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
  MessagingController() : super(const MessagingState());

  /// Creates a conversation for any match that doesn't have one yet, seeded
  /// with a subtle one-time safety reminder. Never removes existing ones, so
  /// typed messages survive when new matches arrive.
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
      messages[match.id] = [reminder];
      conversations[match.id] = Conversation(
        id: match.id,
        otherId: match.id,
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

  void sendText(String conversationId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final conversation = state.conversations[conversationId];
    if (conversation == null) return;

    final message = Message(
      id: '${conversationId}_${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: Message.selfId,
      type: MessageType.text,
      text: trimmed,
      sentAt: DateTime.now(),
      // A real backend advances this to delivered/read (future read receipts).
      status: MessageStatus.sent,
    );

    state = state.copyWith(
      messages: {
        ...state.messages,
        conversationId: [...state.messagesFor(conversationId), message],
      },
      conversations: {
        ...state.conversations,
        conversationId: conversation.copyWith(
          lastMessage: message,
          lastActivity: message.sentAt,
        ),
      },
    );
  }

  void markRead(String conversationId) {
    final conversation = state.conversations[conversationId];
    if (conversation == null || conversation.unreadCount == 0) return;
    state = state.copyWith(conversations: {
      ...state.conversations,
      conversationId: conversation.copyWith(unreadCount: 0),
    });
  }

  /// Removes a conversation locally (on unmatch/block).
  void removeConversation(String conversationId) {
    if (!state.conversations.containsKey(conversationId)) return;
    state = state.copyWith(
      conversations: {...state.conversations}..remove(conversationId),
      messages: {...state.messages}..remove(conversationId),
    );
  }

  void clear() => state = const MessagingState();
}
