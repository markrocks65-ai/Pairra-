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
  });

  final String id;
  final OnboardingProfile profile;
  final int compatibilityPercent;
  final DateTime matchedAt;

  @override
  bool operator ==(Object other) => other is Match && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
