import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../places/places.dart';
import '../domain/planned_date.dart';
import 'dates_controllers.dart';

/// Suggested venues for the Dates home — a broad nearby query through the
/// [PlacesService] (which handles caching, rate limits and coarse location).
final suggestedVenuesProvider = FutureProvider<List<Venue>>((ref) {
  return ref
      .watch(placesServiceProvider)
      .search(const PlacesQuery(maxDistanceKm: 25));
});

final plannedDatesProvider =
    StateNotifierProvider<PlannedDatesController, List<PlannedDate>>(
  (ref) => PlannedDatesController(),
);

final savedPlacesProvider =
    StateNotifierProvider<SavedPlacesController, List<Venue>>(
  (ref) => SavedPlacesController(),
);
