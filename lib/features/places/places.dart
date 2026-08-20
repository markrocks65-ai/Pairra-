/// PAIRRA local-discovery service — provider-agnostic venue search for date
/// planning. Import this barrel to use the venue types, the query, and the
/// [PlacesService]. Swap the underlying provider via `placesRepositoryProvider`.
library;

export 'application/location_coarsener.dart';
export 'application/places_providers.dart';
export 'application/places_service.dart';
export 'application/rate_limiter.dart';
export 'application/venue_cache.dart';
export 'data/mock_places_repository.dart';
export 'domain/places_query.dart';
export 'domain/places_repository.dart';
export 'domain/venue.dart';
export 'domain/venue_category.dart';
export 'domain/venue_hours.dart';
export 'domain/venue_location.dart';
export 'domain/venue_price_range.dart';
