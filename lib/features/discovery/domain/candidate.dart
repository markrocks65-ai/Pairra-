import 'package:flutter/foundation.dart';

import '../../onboarding/domain/onboarding_profile.dart';

/// A discoverable other user: their profile plus a mock flag for whether they'd
/// like the current user back (so a mutual match can be simulated without a
/// real backend). [likesYou] is never shown in the UI — it only decides whether
/// a like becomes a match.
@immutable
class Candidate {
  const Candidate({
    required this.id,
    required this.profile,
    this.likesYou = false,
  });

  final String id;
  final OnboardingProfile profile;
  final bool likesYou;
}
