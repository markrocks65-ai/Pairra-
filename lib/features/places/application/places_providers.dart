import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_places_repository.dart';
import '../domain/places_repository.dart';
import 'places_service.dart';
import 'venue_cache.dart';

/// The active places provider. Defaults to the SAMPLE repository; override with
/// a real provider (Google Places / Foursquare / Yelp) in one place:
///
/// ```dart
/// placesRepositoryProvider.overrideWithValue(GooglePlacesRepository(apiKey))
/// ```
final placesRepositoryProvider = Provider<PlacesRepository>(
  (ref) => MockPlacesRepository(),
);

/// The app-facing local-discovery service (caching + rate limiting + coarse
/// location on top of whichever provider is active). The UI depends on this.
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService(
    ref.watch(placesRepositoryProvider),
    cache: VenueCache(ttl: const Duration(minutes: 15)),
  );
});
