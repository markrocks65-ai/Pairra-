import 'package:flutter/foundation.dart';

import '../../onboarding/domain/onboarding_profile.dart';
import 'message.dart';

/// A conversation with a match. [id] equals the match id. [otherTyping] is a
/// transient flag reserved for the future typing indicator (never persisted).
@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.otherId,
    required this.otherProfile,
    required this.lastActivity,
    this.lastMessage,
    this.unreadCount = 0,
    this.otherTyping = false,
  });

  final String id;
  final String otherId;
  final OnboardingProfile otherProfile;
  final DateTime lastActivity;
  final Message? lastMessage;
  final int unreadCount;
  final bool otherTyping;

  String get otherName => (otherProfile.displayName ?? 'Match').trim();

  Conversation copyWith({
    Message? lastMessage,
    DateTime? lastActivity,
    int? unreadCount,
    bool? otherTyping,
  }) {
    return Conversation(
      id: id,
      otherId: otherId,
      otherProfile: otherProfile,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      otherTyping: otherTyping ?? this.otherTyping,
    );
  }
}
