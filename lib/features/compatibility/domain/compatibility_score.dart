import 'package:flutter/foundation.dart';

import 'compatibility_category.dart';

/// Human-friendly band for a 0..1 score. Used for privacy-safe display of
/// sensitive categories ("Sexual compatibility: Strong") and for overall tone.
enum CompatibilityBand {
  limited('Limited'),
  moderate('Moderate'),
  strong('Strong'),
  exceptional('Exceptional');

  const CompatibilityBand(this.label);
  final String label;

  static CompatibilityBand fromScore(double score) {
    if (score >= 0.85) return CompatibilityBand.exceptional;
    if (score >= 0.70) return CompatibilityBand.strong;
    if (score >= 0.50) return CompatibilityBand.moderate;
    return CompatibilityBand.limited;
  }
}

/// A single category's sub-score. [hasData] is false when neither profile
/// provided enough information to score the category — such categories are
/// excluded from the overall (rather than counted as zero).
@immutable
class CompatibilityCategoryScore {
  const CompatibilityCategoryScore({
    required this.category,
    required this.value,
    required this.hasData,
  });

  final CompatibilityCategory category;

  /// 0..1.
  final double value;
  final bool hasData;

  int get percent => (value * 100).round();
  CompatibilityBand get band => CompatibilityBand.fromScore(value);
}

/// The overall reciprocal compatibility score plus its sub-scores. Presented as
/// a percentage (e.g. "96% Compatible") but flagged as an [isEstimate] — an
/// algorithmic estimate, never scientific truth.
@immutable
class CompatibilityScore {
  const CompatibilityScore({
    required this.overall,
    required this.categories,
  });

  /// 0..1 overall.
  final double overall;

  /// Sub-scores for every category (including those without data).
  final List<CompatibilityCategoryScore> categories;

  int get percent => (overall * 100).round();
  CompatibilityBand get band => CompatibilityBand.fromScore(overall);

  /// Always true — the score is an estimate, and callers should present it that
  /// way (see [CompatibilityExplanation.disclaimer]).
  bool get isEstimate => true;

  /// Sub-scores that actually have data, strongest first.
  List<CompatibilityCategoryScore> get rankedWithData =>
      categories.where((c) => c.hasData).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  CompatibilityCategoryScore? categoryScore(CompatibilityCategory c) {
    for (final s in categories) {
      if (s.category == c) return s;
    }
    return null;
  }
}
