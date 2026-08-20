import 'package:flutter/foundation.dart';

import 'venue_category.dart';
import 'venue_hours.dart';
import 'venue_location.dart';
import 'venue_price_range.dart';

/// Where a venue's data originated. Until a real provider is connected,
/// everything is [sample] and MUST be presented as example data — never as a
/// real business.
enum VenueSource { sample, google, foursquare, yelp }

/// A subtle, safety-forward label. All venues are public places.
enum SafetyLabel {
  publicVenue('Public venue'),
  popularMeetingSpot('Popular meeting spot');

  const SafetyLabel(this.label);
  final String label;
}

/// The provider-agnostic venue aggregate — composed of the [VenuePriceRange],
/// [VenueLocation] and [VenueHours] value objects. Field set mirrors what a real
/// places API returns, so a concrete provider maps onto it without UI churn.
@immutable
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.location,
    required this.photoSeed,
    required this.indoor,
    required this.vibes,
    this.hours,
    this.rating,
    this.ratingCount,
    this.reservable = false,
    this.reservationNote,
    this.safety = SafetyLabel.publicVenue,
    this.source = VenueSource.sample,
  });

  final String id;
  final String name;
  final VenueCategory category;
  final VenuePriceRange price;
  final VenueLocation location;
  final VenueHours? hours;
  final String photoSeed;
  final bool indoor;
  final Set<String> vibes;
  final double? rating;
  final int? ratingCount;
  final bool reservable;
  final String? reservationNote;
  final SafetyLabel safety;
  final VenueSource source;

  bool get isSample => source == VenueSource.sample;

  // --- Backward-compatible convenience accessors (used across the UI) -------
  double? get distanceKm => location.distanceKm;
  String get areaLabel => location.areaLabel;
  int get priceLevel => price.level;
  String get priceRange => price.symbol;
  int get costForTwoMin => price.typicalForTwoMin;
  int get costForTwoMax => price.typicalForTwoMax;
  String? get openingHoursLabel => hours?.label;
  String get imageSeed => photoSeed;

  Venue withDistance(double? distanceKm) =>
      _copy(location: location.copyWith(distanceKm: distanceKm));

  Venue _copy({VenueLocation? location}) => Venue(
        id: id,
        name: name,
        category: category,
        price: price,
        location: location ?? this.location,
        photoSeed: photoSeed,
        indoor: indoor,
        vibes: vibes,
        hours: hours,
        rating: rating,
        ratingCount: ratingCount,
        reservable: reservable,
        reservationNote: reservationNote,
        safety: safety,
        source: source,
      );
}
