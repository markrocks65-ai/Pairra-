import '../domain/places_query.dart';
import '../domain/places_repository.dart';
import '../domain/venue.dart';
import '../domain/venue_category.dart';
import '../domain/venue_hours.dart';
import '../domain/venue_location.dart';
import '../domain/venue_price_range.dart';

/// A SAMPLE [PlacesRepository]. These venues are illustrative placeholders, NOT
/// real businesses — the UI labels them as sample data. Replace with a real
/// provider (GooglePlacesRepository / FoursquareRepository / YelpRepository) to
/// show genuine local venues; the service and UI don't change.
///
/// Distance filtering/sorting is left to [PlacesService] (it needs the coarse
/// origin); this repo applies every other filter. Every entry is a public place.
class MockPlacesRepository implements PlacesRepository {
  MockPlacesRepository({this.latency = const Duration(milliseconds: 350)});

  final Duration latency;

  @override
  VenueSource get source => VenueSource.sample;

  @override
  Future<List<Venue>> search(PlacesQuery query) async {
    await Future<void>.delayed(latency);
    final at = query.openNow ? DateTime.now() : query.openAt;
    final results = _venues.where((v) {
      if (query.categories.isNotEmpty &&
          !query.categories.contains(v.category)) {
        return false;
      }
      if (query.maxPriceLevel != null && v.price.level > query.maxPriceLevel!) {
        return false;
      }
      if (query.minRating != null && (v.rating ?? 0) < query.minRating!) {
        return false;
      }
      if (query.dateTypes.isNotEmpty &&
          v.vibes.intersection(query.dateTypes).isEmpty) {
        return false;
      }
      if (query.setting == IndoorOutdoor.indoor && !v.indoor) return false;
      if (query.setting == IndoorOutdoor.outdoor && v.indoor) return false;
      if (at != null && v.hours?.isOpenAt(at) == false) return false;
      return true;
    }).toList();
    return results.take(query.limit).toList();
  }

  @override
  Future<Venue?> venueById(String id) async {
    await Future<void>.delayed(latency);
    for (final v in _venues) {
      if (v.id == id) return v;
    }
    return null;
  }

  static Venue _v({
    required String id,
    required String name,
    required VenueCategory category,
    required int level,
    required int min,
    required int max,
    required double lat,
    required double lng,
    required String area,
    required double distance,
    required bool indoor,
    required Set<String> vibes,
    required String seed,
    required double rating,
    required int ratingCount,
    required String hoursLabel,
    required int openMin,
    required int closeMin,
    bool reservable = false,
    String? reservationNote,
    SafetyLabel safety = SafetyLabel.publicVenue,
  }) {
    return Venue(
      id: id,
      name: name,
      category: category,
      price: VenuePriceRange(
          level: level, typicalForTwoMin: min, typicalForTwoMax: max),
      location: VenueLocation(
          approxLat: lat, approxLng: lng, areaLabel: area, distanceKm: distance),
      hours:
          VenueHours(label: hoursLabel, openMinute: openMin, closeMinute: closeMin),
      photoSeed: seed,
      indoor: indoor,
      vibes: vibes,
      rating: rating,
      ratingCount: ratingCount,
      reservable: reservable,
      reservationNote: reservationNote,
      safety: safety,
    );
  }

  static final List<Venue> _venues = [
    _v(
      id: 'v_bistro',
      name: 'The Corner Bistro',
      category: VenueCategory.restaurant,
      level: 2, min: 45, max: 65,
      lat: 40.712, lng: -74.006, area: 'Downtown', distance: 3.5,
      indoor: true,
      vibes: {'romantic', 'food_focused', 'casual'},
      seed: 'p4', rating: 4.6, ratingCount: 312,
      hoursLabel: 'Open until 11 PM', openMin: 660, closeMin: 1380,
      reservable: true, reservationNote: 'Reservations recommended',
      safety: SafetyLabel.popularMeetingSpot,
    ),
    _v(
      id: 'v_roasters',
      name: 'Ember Coffee Roasters',
      category: VenueCategory.coffee,
      level: 1, min: 8, max: 18,
      lat: 40.720, lng: -73.999, area: 'Midtown', distance: 1.2,
      indoor: true,
      vibes: {'casual', 'relaxed', 'low_cost'},
      seed: 'p2', rating: 4.7, ratingCount: 540,
      hoursLabel: 'Open until 8 PM', openMin: 420, closeMin: 1200,
      safety: SafetyLabel.popularMeetingSpot,
    ),
    _v(
      id: 'v_rooftop',
      name: 'Skyline Rooftop Bar',
      category: VenueCategory.nightlife,
      level: 3, min: 40, max: 80,
      lat: 40.706, lng: -74.011, area: 'Riverside', distance: 4.1,
      indoor: false,
      vibes: {'romantic', 'nightlife'},
      seed: 'p3', rating: 4.4, ratingCount: 210,
      hoursLabel: 'Open until 1 AM', openMin: 960, closeMin: 1500,
    ),
    _v(
      id: 'v_park',
      name: 'Willow Riverside Park',
      category: VenueCategory.park,
      level: 1, min: 0, max: 0,
      lat: 40.702, lng: -74.014, area: 'Riverside', distance: 2.0,
      indoor: false,
      vibes: {'relaxed', 'outdoors', 'low_cost', 'casual'},
      seed: 'p6', rating: 4.8, ratingCount: 900,
      hoursLabel: 'Open until dusk', openMin: 360, closeMin: 1200,
      safety: SafetyLabel.popularMeetingSpot,
    ),
    _v(
      id: 'v_museum',
      name: 'City Museum of Modern Art',
      category: VenueCategory.museum,
      level: 2, min: 24, max: 40,
      lat: 40.730, lng: -73.990, area: 'Arts District', distance: 5.5,
      indoor: true,
      vibes: {'relaxed', 'activity'},
      seed: 'p5', rating: 4.5, ratingCount: 430,
      hoursLabel: 'Open until 6 PM', openMin: 600, closeMin: 1080,
    ),
    _v(
      id: 'v_bowl',
      name: 'Strike Lanes',
      category: VenueCategory.activity,
      level: 2, min: 30, max: 50,
      lat: 40.735, lng: -73.995, area: 'Uptown', distance: 6.2,
      indoor: true,
      vibes: {'activity', 'casual', 'adventurous'},
      seed: 'p1', rating: 4.2, ratingCount: 180,
      hoursLabel: 'Open until midnight', openMin: 720, closeMin: 1440,
    ),
    _v(
      id: 'v_minigolf',
      name: 'Glow Mini Golf',
      category: VenueCategory.activity,
      level: 1, min: 22, max: 34,
      lat: 40.738, lng: -73.992, area: 'Uptown', distance: 7.0,
      indoor: true,
      vibes: {'activity', 'adventurous', 'low_cost', 'casual'},
      seed: 'p2', rating: 4.3, ratingCount: 150,
      hoursLabel: 'Open until 11 PM', openMin: 720, closeMin: 1380,
    ),
    _v(
      id: 'v_arcade',
      name: 'Pixel Palace Arcade',
      category: VenueCategory.entertainment,
      level: 2, min: 25, max: 45,
      lat: 40.714, lng: -74.002, area: 'Downtown', distance: 3.9,
      indoor: true,
      vibes: {'activity', 'casual', 'nightlife'},
      seed: 'p3', rating: 4.1, ratingCount: 205,
      hoursLabel: 'Open until 2 AM', openMin: 720, closeMin: 1560,
    ),
    _v(
      id: 'v_cinema',
      name: 'Grand Independent Cinema',
      category: VenueCategory.movie,
      level: 2, min: 28, max: 44,
      lat: 40.719, lng: -73.997, area: 'Midtown', distance: 4.6,
      indoor: true,
      vibes: {'relaxed', 'casual'},
      seed: 'p4', rating: 4.4, ratingCount: 260,
      hoursLabel: 'Screenings until 11 PM', openMin: 720, closeMin: 1380,
      reservable: true, reservationNote: 'Book seats online',
    ),
    _v(
      id: 'v_dessert',
      name: 'Velvet Dessert House',
      category: VenueCategory.restaurant,
      level: 2, min: 18, max: 30,
      lat: 40.713, lng: -74.004, area: 'Downtown', distance: 3.6,
      indoor: true,
      vibes: {'romantic', 'food_focused', 'relaxed'},
      seed: 'p5', rating: 4.7, ratingCount: 380,
      hoursLabel: 'Open until midnight', openMin: 720, closeMin: 1440,
      safety: SafetyLabel.popularMeetingSpot,
    ),
  ];
}
