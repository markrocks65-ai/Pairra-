import 'package:flutter/foundation.dart';

/// Message kinds. [system] carries app-generated notices (safety reminder,
/// unmatch). [image]/[voice] are wired into the model now for future photo
/// sharing and voice messages, though composing them isn't enabled yet.
enum MessageType { text, image, voice, system }

/// Delivery state — the backbone for future read receipts. Client sets
/// [sending] → [sent]; a real backend will drive [delivered]/[read].
enum MessageStatus { sending, sent, delivered, read }

/// Automated-moderation state, for future message moderation / spam detection.
/// Everything is [none] until a moderation backend exists.
enum MessageModeration { none, pending, flagged }

/// A single chat message. The extra fields ([mediaUrl], [voiceMs], [status],
/// [moderation]) exist so photo sharing, voice messages, read receipts and
/// moderation can ship without a model migration.
@immutable
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.sentAt,
    this.type = MessageType.text,
    this.text,
    this.mediaUrl,
    this.voiceMs,
    this.status = MessageStatus.sent,
    this.moderation = MessageModeration.none,
  });

  final String id;
  final String conversationId;

  /// Sender id — the current user is [selfId]; app notices use `'system'`.
  final String senderId;

  final DateTime sentAt;
  final MessageType type;
  final String? text;

  /// Future photo/voice payload location.
  final String? mediaUrl;

  /// Future voice-message duration.
  final int? voiceMs;

  final MessageStatus status;
  final MessageModeration moderation;

  static const String selfId = 'self';
  static const String systemId = 'system';

  bool get isSystem => type == MessageType.system;
  bool get isMine => senderId == selfId;

  Message copyWith({
    MessageStatus? status,
    MessageModeration? moderation,
    String? text,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      sentAt: sentAt,
      type: type,
      text: text ?? this.text,
      mediaUrl: mediaUrl,
      voiceMs: voiceMs,
      status: status ?? this.status,
      moderation: moderation ?? this.moderation,
    );
  }
}
