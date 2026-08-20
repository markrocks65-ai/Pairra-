import 'package:flutter/foundation.dart';

import '../../../core/config/option.dart';
import '../../places/places.dart';

/// The user's inputs for "create a date". A date-planning concept that maps
/// onto a provider-agnostic [PlacesQuery] via [toPlacesQuery].
@immutable
class DateCriteria {
  const DateCriteria({
    this.vibes = const {},
    this.categories = const {},
    this.maxPriceLevel = 4,
    this.maxDistanceKm = 25,
    this.setting = IndoorOutdoor.any,
    this.when,
  });

  final Set<String> vibes;
  final Set<VenueCategory> categories;
  final int maxPriceLevel;
  final double maxDistanceKm;
  final IndoorOutdoor setting;
  final DateTime? when;

  /// Translates the date criteria into a places query. No origin is attached
  /// here — the service coarsens the user's location when one is available.
  PlacesQuery toPlacesQuery() => PlacesQuery(
        categories: categories,
        maxPriceLevel: maxPriceLevel,
        maxDistanceKm: maxDistanceKm,
        dateTypes: vibes,
        setting: setting,
        openAt: when,
      );

  DateCriteria copyWith({
    Set<String>? vibes,
    Set<VenueCategory>? categories,
    int? maxPriceLevel,
    double? maxDistanceKm,
    IndoorOutdoor? setting,
    DateTime? when,
  }) =>
      DateCriteria(
        vibes: vibes ?? this.vibes,
        categories: categories ?? this.categories,
        maxPriceLevel: maxPriceLevel ?? this.maxPriceLevel,
        maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
        setting: setting ?? this.setting,
        when: when ?? this.when,
      );
}

/// Selectable date "vibe" / type options, as data.
abstract final class DateOptions {
  static const List<Option> vibes = [
    Option('casual', 'Casual'),
    Option('romantic', 'Romantic'),
    Option('adventurous', 'Adventurous'),
    Option('relaxed', 'Relaxed'),
    Option('food_focused', 'Food-focused'),
    Option('activity', 'Activity'),
    Option('nightlife', 'Nightlife'),
    Option('outdoors', 'Outdoors'),
    Option('low_cost', 'Low-cost'),
  ];
}
