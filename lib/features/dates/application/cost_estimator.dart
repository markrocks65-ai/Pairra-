import 'package:flutter/foundation.dart';

import '../../places/places.dart';
import '../domain/planned_date.dart';

/// An inclusive cost range. PAIRRA always shows a range — never false precision.
@immutable
class CostRange {
  const CostRange(this.min, this.max);

  final int min;
  final int max;

  bool get isFree => min == 0 && max == 0;

  /// "$45–$65 for two" (or "Free").
  String get label => isFree ? 'Free' : '\$$min–\$$max for two';

  /// "$45–$65".
  String get shortLabel => isFree ? 'Free' : '\$$min–\$$max';
}

/// Pure cost math for dates. Sums per-stop / per-venue ranges into a total
/// range; deliberately no averaging into a single fake number.
abstract final class CostEstimator {
  static CostRange forItinerary(List<ItineraryStop> stops) {
    var min = 0, max = 0;
    for (final s in stops) {
      min += s.costMin;
      max += s.costMax;
    }
    return CostRange(min, max);
  }

  static CostRange forVenues(Iterable<Venue> venues) {
    var min = 0, max = 0;
    for (final v in venues) {
      min += v.costForTwoMin;
      max += v.costForTwoMax;
    }
    return CostRange(min, max);
  }
}
