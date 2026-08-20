import 'package:flutter/foundation.dart';

import 'compatibility_category.dart';

/// Per-category weights for combining sub-scores into an overall score.
/// Weights are **configuration, not hard-coded in the UI** — tune them here (or
/// load from remote config later) without touching the service or any widget.
///
/// Weights need not sum to 1: the service renormalizes over whichever
/// categories actually have data for a given pair, so a missing category (e.g.
/// availability nobody filled in) never unfairly drags a score down.
@immutable
class CompatibilityWeights {
  const CompatibilityWeights(this.values);

  final Map<CompatibilityCategory, double> values;

  double of(CompatibilityCategory category) => values[category] ?? 0;

  /// The default PAIRRA weighting. Sexual compatibility, relationship intent
  /// and interests lead; "softer" signals contribute less.
  static const CompatibilityWeights standard = CompatibilityWeights({
    CompatibilityCategory.sexual: 0.18,
    CompatibilityCategory.relationshipIntent: 0.15,
    CompatibilityCategory.interests: 0.12,
    CompatibilityCategory.distance: 0.10,
    CompatibilityCategory.lifestyle: 0.10,
    CompatibilityCategory.agePreference: 0.08,
    CompatibilityCategory.personality: 0.08,
    CompatibilityCategory.datingPreferences: 0.07,
    CompatibilityCategory.communication: 0.06,
    CompatibilityCategory.availability: 0.06,
  });

  CompatibilityWeights copyWith(Map<CompatibilityCategory, double> overrides) {
    return CompatibilityWeights({...values, ...overrides});
  }
}
