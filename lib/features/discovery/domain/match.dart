import 'package:flutter/foundation.dart';

import '../../onboarding/domain/onboarding_profile.dart';

/// A mutual match. Stores a snapshot of the matched user's profile plus the
/// compatibility percentage computed at match time, so the Matches list can
/// render without recomputing.
@immutable
class Match {
  const Match({
    required this.id,
    required this.profile,
    required this.compatibilityPercent,
    required this.matchedAt,
    this.otherId = '',
  });

  final String id;

  /// The matched user's uid (used for messaging, block and report). Falls back
  /// to [id] when not set (legacy/mock paths).
  final String otherId;

  final OnboardingProfile profile;
  final int compatibilityPercent;
  final DateTime matchedAt;

  @override
  bool operator ==(Object other) => other is Match && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
