import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/compatibility_category.dart';
import '../domain/compatibility_explanation.dart';
import '../domain/compatibility_profile.dart';
import '../domain/compatibility_score.dart';
import '../domain/compatibility_weights.dart';
import '../domain/role_compatibility.dart';

/// A category's raw outcome: a 0..1 [score] and whether there was enough data
/// to score it at all.
typedef _Outcome = ({double score, bool hasData});

/// The full result of evaluating two profiles: the score (overall + sub-scores)
/// and a privacy-safe explanation.
@immutable
class CompatibilityAssessment {
  const CompatibilityAssessment({
    required this.score,
    required this.explanation,
  });

  final CompatibilityScore score;
  final CompatibilityExplanation explanation;
}

/// The dedicated compatibility engine. **All** compatibility math lives here —
/// never in UI widgets. It computes each category reciprocally (does A fit B's
/// preferences AND B fit A's), combines them with configurable
/// [CompatibilityWeights], and produces a privacy-safe explanation.
///
/// Pure and deterministic: given the same inputs it returns the same result,
/// which makes it straightforward to unit-test.
class CompatibilityService {
  const CompatibilityService({this.weights = CompatibilityWeights.standard});

  final CompatibilityWeights weights;

  /// Scores + explanation for a pair.
  CompatibilityAssessment evaluate(
      CompatibilityProfile a, CompatibilityProfile b) {
    final outcomes = _outcomes(a, b);

    final categoryScores = [
      for (final category in CompatibilityCategory.values)
        CompatibilityCategoryScore(
          category: category,
          value: outcomes[category]!.score,
          hasData: outcomes[category]!.hasData,
        ),
    ];

    // Weighted mean over categories that actually have data (renormalized), so
    // a missing category never counts as a zero.
    var weightedSum = 0.0;
    var usedWeight = 0.0;
    for (final category in CompatibilityCategory.values) {
      final outcome = outcomes[category]!;
      if (!outcome.hasData) continue;
      final w = weights.of(category);
      weightedSum += outcome.score * w;
      usedWeight += w;
    }
    final overall = usedWeight > 0 ? weightedSum / usedWeight : 0.0;

    final score = CompatibilityScore(
      overall: _clamp01(overall),
      categories: categoryScores,
    );

    return CompatibilityAssessment(
      score: score,
      explanation: _explain(a, b, outcomes, score),
    );
  }

  /// Just the score, when the explanation isn't needed.
  CompatibilityScore score(CompatibilityProfile a, CompatibilityProfile b) =>
      evaluate(a, b).score;

  // --- Category scorers (each reciprocal where direction matters) -----------

  Map<CompatibilityCategory, _Outcome> _outcomes(
      CompatibilityProfile a, CompatibilityProfile b) {
    return {
      CompatibilityCategory.sexual: _sexual(a, b),
      CompatibilityCategory.relationshipIntent: _relationshipIntent(a, b),
      CompatibilityCategory.datingPreferences: _datingPreferences(a, b),
      CompatibilityCategory.agePreference: _agePreference(a, b),
      CompatibilityCategory.distance: _distance(a, b),
      CompatibilityCategory.interests: _interests(a, b),
      CompatibilityCategory.lifestyle: _lifestyle(a, b),
      CompatibilityCategory.communication: _communication(a, b),
      CompatibilityCategory.personality: _personality(a, b),
      CompatibilityCategory.availability: _availability(a, b),
    };
  }

  _Outcome _sexual(CompatibilityProfile a, CompatibilityProfile b) {
    final intrinsic =
        RoleCompatibility.intrinsicRoleScore(a.roles, b.roles);
    if (intrinsic == null) return (score: 0, hasData: false);
    // Reciprocal preference satisfaction — role alone doesn't decide it.
    final pref = RoleCompatibility.preferenceSatisfaction(
      a.roles,
      b.roles,
      a.preferences.preferredRoles,
      b.preferences.preferredRoles,
    );
    // Multiplicative: intrinsic role fit sets the ceiling; stated preferences
    // modulate it down. So Top+Top stays low even with open preferences, and a
    // mismatch in what each wants pulls a physically-good pairing down.
    return (score: _clamp01(intrinsic * (0.6 + 0.4 * pref)), hasData: true);
  }

  _Outcome _relationshipIntent(
      CompatibilityProfile a, CompatibilityProfile b) {
    final parts = <double>[];
    final intents = _jaccard(a.datingIntentions, b.datingIntentions);
    if (intents != null) parts.add(intents);
    final rel = _jaccard(
        a.preferences.relationshipTypes, b.preferences.relationshipTypes);
    if (rel != null) parts.add(rel);
    if (parts.isEmpty) return (score: 0, hasData: false);
    return (score: _avg(parts), hasData: true);
  }

  _Outcome _datingPreferences(
      CompatibilityProfile a, CompatibilityProfile b) {
    final parts = <double>[];
    final dates = _jaccard(a.firstDates, b.firstDates);
    if (dates != null) parts.add(dates);
    if (a.budgetId != null && b.budgetId != null) {
      final ba = int.tryParse(a.budgetId!) ?? 2;
      final bb = int.tryParse(b.budgetId!) ?? 2;
      parts.add(_clamp01(1 - (ba - bb).abs() / 3));
    }
    if (parts.isEmpty) return (score: 0, hasData: false);
    return (score: _avg(parts), hasData: true);
  }

  _Outcome _agePreference(CompatibilityProfile a, CompatibilityProfile b) {
    if (a.age == null || b.age == null) return (score: 0, hasData: false);
    final aAcceptsB =
        _rangeFit(b.age!, a.preferences.ageMin, a.preferences.ageMax);
    final bAcceptsA =
        _rangeFit(a.age!, b.preferences.ageMin, b.preferences.ageMax);
    return (score: math.min(aAcceptsB, bAcceptsA), hasData: true);
  }

  _Outcome _distance(CompatibilityProfile a, CompatibilityProfile b) {
    final la = a.location, lb = b.location;
    if (la == null || lb == null) return (score: 0, hasData: false);
    final d = la.distanceKmTo(lb);
    final aOk = _distanceFit(d, a.preferences.maxDistanceKm);
    final bOk = _distanceFit(d, b.preferences.maxDistanceKm);
    return (score: math.min(aOk, bOk), hasData: true);
  }

  _Outcome _interests(CompatibilityProfile a, CompatibilityProfile b) {
    final j = _jaccard(a.interests, b.interests);
    return j == null ? (score: 0, hasData: false) : (score: j, hasData: true);
  }

  _Outcome _lifestyle(CompatibilityProfile a, CompatibilityProfile b) {
    final parts = <double>[];
    final smoking = _ordinalSim(a.lifestyle.smoking, b.lifestyle.smoking,
        const ['no', 'sometimes', 'yes']);
    if (smoking != null) parts.add(smoking);
    final drinking = _ordinalSim(a.lifestyle.drinking, b.lifestyle.drinking,
        const ['no', 'socially', 'regularly']);
    if (drinking != null) parts.add(drinking);
    final pets = _genericSim(a.lifestyle.pets, b.lifestyle.pets);
    if (pets != null) parts.add(pets);
    final children = _genericSim(a.lifestyle.children, b.lifestyle.children);
    if (children != null) parts.add(children);
    if (parts.isEmpty) return (score: 0, hasData: false);
    return (score: _avg(parts), hasData: true);
  }

  _Outcome _communication(CompatibilityProfile a, CompatibilityProfile b) {
    final j = _jaccard(
        a.lifestyle.communicationStyles, b.lifestyle.communicationStyles);
    return j == null ? (score: 0, hasData: false) : (score: j, hasData: true);
  }

  _Outcome _personality(CompatibilityProfile a, CompatibilityProfile b) {
    final shared =
        a.personality.keys.where(b.personality.containsKey).toList();
    if (shared.isEmpty) return (score: 0, hasData: false);
    var sum = 0.0;
    for (final k in shared) {
      sum += a.personality[k] == b.personality[k] ? 1.0 : 0.6;
    }
    return (score: sum / shared.length, hasData: true);
  }

  _Outcome _availability(CompatibilityProfile a, CompatibilityProfile b) {
    final j = _jaccard(a.availability, b.availability);
    return j == null ? (score: 0, hasData: false) : (score: j, hasData: true);
  }

  // --- Explanation (privacy-safe) -------------------------------------------

  CompatibilityExplanation _explain(
    CompatibilityProfile a,
    CompatibilityProfile b,
    Map<CompatibilityCategory, _Outcome> outcomes,
    CompatibilityScore score,
  ) {
    final highlights = <String>[];
    final considerations = <String>[];

    bool strong(CompatibilityCategory c, [double t = 0.7]) {
      final o = outcomes[c]!;
      return o.hasData && o.score >= t;
    }

    bool weak(CompatibilityCategory c, [double t = 0.45]) {
      final o = outcomes[c]!;
      return o.hasData && o.score < t;
    }

    // Sexual: BAND ONLY — never any role specifics.
    if (strong(CompatibilityCategory.sexual)) {
      final band = score
          .categoryScore(CompatibilityCategory.sexual)!
          .band
          .label
          .toLowerCase();
      highlights.add('Your sexual compatibility looks $band.');
    }
    if (strong(CompatibilityCategory.relationshipIntent)) {
      highlights.add('Your relationship goals are aligned.');
    }

    final sharedInterests = _humanizeList(
        a.interests.where(b.interests.contains).take(3).toList());
    if (sharedInterests != null) {
      highlights.add('You share interests in $sharedInterests.');
    }

    if (strong(CompatibilityCategory.datingPreferences, 0.6)) {
      final dates = _humanizeList(
          a.firstDates.where(b.firstDates.contains).take(2).toList());
      highlights.add(dates != null
          ? 'You both enjoy $dates dates.'
          : 'You like similar kinds of first dates.');
    }
    if (strong(CompatibilityCategory.distance, 0.75)) {
      highlights.add('You\'re within easy reach of each other.');
    }
    if (strong(CompatibilityCategory.lifestyle, 0.75)) {
      highlights.add('Your lifestyles line up well.');
    }
    if (strong(CompatibilityCategory.communication)) {
      highlights.add('You communicate in similar ways.');
    }
    if (strong(CompatibilityCategory.personality)) {
      highlights.add('Your personalities complement each other.');
    }
    if (strong(CompatibilityCategory.availability)) {
      highlights.add('Your schedules tend to overlap.');
    }

    // Considerations — gentle, non-sensitive.
    if (weak(CompatibilityCategory.distance)) {
      considerations.add('You\'re a bit far apart.');
    }
    if (weak(CompatibilityCategory.agePreference)) {
      considerations.add('Your age preferences don\'t fully overlap.');
    }
    if (weak(CompatibilityCategory.relationshipIntent)) {
      considerations.add('You may be looking for different things.');
    }
    if (weak(CompatibilityCategory.lifestyle)) {
      considerations.add('There are some lifestyle differences to talk through.');
    }
    if (weak(CompatibilityCategory.availability)) {
      considerations.add('Your schedules may not line up easily.');
    }

    return CompatibilityExplanation(
      highlights: highlights.take(4).toList(),
      considerations: considerations.take(2).toList(),
    );
  }
}

// --- Pure helpers ------------------------------------------------------------

double _clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

double _avg(List<double> xs) =>
    xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

/// Jaccard overlap; `null` when either set is empty (can't compare).
double? _jaccard(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return null;
  final inter = a.intersection(b).length;
  final union = a.union(b).length;
  return union == 0 ? null : inter / union;
}

/// 1.0 inside the range, decaying to 0 by 8 years outside it.
double _rangeFit(int age, int min, int max) {
  if (age >= min && age <= max) return 1.0;
  final out = age < min ? min - age : age - max;
  return _clamp01(1 - out / 8);
}

/// 1.0 within [maxKm], reaching 0 at twice [maxKm].
double _distanceFit(double d, double maxKm) {
  if (maxKm <= 0) return d <= 0 ? 1 : 0;
  if (d <= maxKm) return 1;
  return _clamp01(1 - (d - maxKm) / maxKm);
}

double? _ordinalSim(String? a, String? b, List<String> order) {
  if (a == null || b == null) return null;
  final ia = order.indexOf(a), ib = order.indexOf(b);
  if (ia < 0 || ib < 0) return a == b ? 1.0 : 0.4;
  return _clamp01(1 - (ia - ib).abs() / (order.length - 1));
}

double? _genericSim(String? a, String? b) {
  if (a == null || b == null) return null;
  return a == b ? 1.0 : 0.4;
}

/// "fitness, travel and music" from ids; returns null for an empty list.
String? _humanizeList(List<String> ids) {
  if (ids.isEmpty) return null;
  final words = ids.map(_humanize).toList();
  if (words.length == 1) return words.first;
  return '${words.sublist(0, words.length - 1).join(', ')} and ${words.last}';
}

String _humanize(String id) => id.split('_').join(' ').toLowerCase();
