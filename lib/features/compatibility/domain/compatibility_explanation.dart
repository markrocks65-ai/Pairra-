import 'package:flutter/foundation.dart';

/// A privacy-safe, human explanation of a compatibility result. Highlights and
/// considerations are generated ONLY from shared/aggregate signals — they never
/// name another user's sensitive preferences (roles are referenced by band
/// only, e.g. "Your sexual compatibility looks strong").
@immutable
class CompatibilityExplanation {
  const CompatibilityExplanation({
    required this.highlights,
    required this.considerations,
  });

  /// Positive, shareable reasons the pair fits (e.g. overlapping interests).
  final List<String> highlights;

  /// Gentle, non-sensitive "things to explore" (e.g. distance).
  final List<String> considerations;

  /// The standard estimate disclaimer to show alongside any score.
  static const String disclaimer =
      'Compatibility is an algorithmic estimate based on what you both shared '
      '— not an exact science.';
}
