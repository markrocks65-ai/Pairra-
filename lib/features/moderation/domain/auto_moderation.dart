import 'package:flutter/foundation.dart';

/// Result of an automated-moderation scan. Placeholder for a future system
/// (text classifier, image safety model). Until one is connected, everything is
/// [notReviewed] and human review decides.
@immutable
class ModerationSignal {
  const ModerationSignal({
    required this.reviewed,
    this.flagged = false,
    this.confidence = 0,
    this.label,
  });

  const ModerationSignal.notReviewed() : this(reviewed: false);

  final bool reviewed;
  final bool flagged;
  final double confidence;
  final String? label;
}

/// Seam for future automated moderation (spam/abuse text classification, image
/// safety). Default [NoopAutoModerator] does nothing but return "not reviewed",
/// so nothing is auto-actioned until a real system is wired in.
abstract interface class AutoModerator {
  bool get isEnabled;
  Future<ModerationSignal> scanText(String text);
  Future<ModerationSignal> scanImageRef(String reference);
}

class NoopAutoModerator implements AutoModerator {
  const NoopAutoModerator();

  @override
  bool get isEnabled => false;

  @override
  Future<ModerationSignal> scanText(String text) async =>
      const ModerationSignal.notReviewed();

  @override
  Future<ModerationSignal> scanImageRef(String reference) async =>
      const ModerationSignal.notReviewed();
}
