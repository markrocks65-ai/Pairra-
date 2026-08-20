import 'places_query.dart';
import 'venue.dart';

/// The provider-agnostic contract for a venue data source. Concrete providers
/// (GooglePlacesRepository, FoursquareRepository, YelpRepository, or the mock)
/// implement this; nothing above it knows which provider is in use.
///
/// Implementations MUST:
///  • return only public venues (never private residences),
///  • work with approximate coordinates only,
///  • honor the provider's terms of service and rate limits,
///  • never fabricate data (return empty rather than invent).
abstract interface class PlacesRepository {
  /// Which provider this is (drives the [Venue.source] on returned venues).
  VenueSource get source;

  Future<List<Venue>> search(PlacesQuery query);

  Future<Venue?> venueById(String id);
}
