import '../domain/compatibility_category.dart';
import '../domain/compatibility_score.dart';

/// Generates the short, privacy-safe "Why you're seeing him" checklist from a
/// [CompatibilityScore]. Pure formatting of an already-computed score (no
/// scoring logic here), so it stays testable and out of the UI.
///
/// Sensitive categories are phrased as bands only — e.g. sexual compatibility
/// becomes "Strong preference compatibility", never a role. Only categories
/// that have data and clear the [threshold] are included.
abstract final class CompatibilityReasons {
  static const _labels = <CompatibilityCategory, String>{
    CompatibilityCategory.relationshipIntent: 'Relationship goals align',
    CompatibilityCategory.sexual: 'Strong preference compatibility',
    CompatibilityCategory.interests: 'Shared interests',
    CompatibilityCategory.distance: 'Within your preferred distance',
    CompatibilityCategory.agePreference: 'Ages line up',
    CompatibilityCategory.lifestyle: 'Lifestyles are compatible',
    CompatibilityCategory.datingPreferences: 'Similar taste in dates',
    CompatibilityCategory.communication: 'Similar communication styles',
    CompatibilityCategory.personality: 'Personalities complement',
    CompatibilityCategory.availability: 'Schedules tend to overlap',
  };

  /// Priority order (strongest signals first).
  static const _order = <CompatibilityCategory>[
    CompatibilityCategory.relationshipIntent,
    CompatibilityCategory.sexual,
    CompatibilityCategory.interests,
    CompatibilityCategory.distance,
    CompatibilityCategory.agePreference,
    CompatibilityCategory.lifestyle,
    CompatibilityCategory.datingPreferences,
    CompatibilityCategory.communication,
    CompatibilityCategory.personality,
    CompatibilityCategory.availability,
  ];

  static List<String> from(
    CompatibilityScore score, {
    double threshold = 0.65,
    int max = 4,
  }) {
    final reasons = <String>[];
    for (final category in _order) {
      final sub = score.categoryScore(category);
      if (sub != null && sub.hasData && sub.value >= threshold) {
        reasons.add(_labels[category]!);
        if (reasons.length >= max) break;
      }
    }
    return reasons;
  }
}
