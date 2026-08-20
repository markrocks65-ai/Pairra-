import 'package:flutter/foundation.dart';

import 'venue_category.dart';

/// Indoor/outdoor preference.
enum IndoorOutdoor { any, indoor, outdoor }

/// A coarse origin point for a search. The service coarsens the user's real
/// location into one of these BEFORE it ever reaches a provider, so an exact
/// position is never sent off-device.
@immutable
class SearchOrigin {
  const SearchOrigin(this.approxLat, this.approxLng);
  final double approxLat;
  final double approxLng;
}

/// A structured venue query supporting every search dimension the service
/// exposes (nearby, category, price, distance, rating, date type/vibe, open
/// hours). Immutable and value-equal so it can key the cache.
@immutable
class PlacesQuery {
  const PlacesQuery({
    this.origin,
    this.categories = const {},
    this.maxPriceLevel,
    this.maxDistanceKm,
    this.minRating,
    this.dateTypes = const {},
    this.setting = IndoorOutdoor.any,
    this.openAt,
    this.openNow = false,
    this.limit = 30,
  });

  final SearchOrigin? origin;
  final Set<VenueCategory> categories;
  final int? maxPriceLevel;
  final double? maxDistanceKm;
  final double? minRating;

  /// Date-type / vibe ids (e.g. 'romantic', 'casual').
  final Set<String> dateTypes;

  final IndoorOutdoor setting;

  /// Filter to venues open at this time.
  final DateTime? openAt;

  /// Filter to venues open right now.
  final bool openNow;

  final int limit;

  PlacesQuery copyWith({
    SearchOrigin? origin,
    Set<VenueCategory>? categories,
    int? maxPriceLevel,
    double? maxDistanceKm,
    double? minRating,
    Set<String>? dateTypes,
    IndoorOutdoor? setting,
    DateTime? openAt,
    bool? openNow,
    int? limit,
  }) {
    return PlacesQuery(
      origin: origin ?? this.origin,
      categories: categories ?? this.categories,
      maxPriceLevel: maxPriceLevel ?? this.maxPriceLevel,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minRating: minRating ?? this.minRating,
      dateTypes: dateTypes ?? this.dateTypes,
      setting: setting ?? this.setting,
      openAt: openAt ?? this.openAt,
      openNow: openNow ?? this.openNow,
      limit: limit ?? this.limit,
    );
  }

  /// Stable string key for caching. Rounds the coarse origin further so nearby
  /// searches share a cache entry (and no precise location lands in a key).
  String get cacheKey {
    final lat = origin == null ? '_' : origin!.approxLat.toStringAsFixed(2);
    final lng = origin == null ? '_' : origin!.approxLng.toStringAsFixed(2);
    final cats = (categories.map((c) => c.name).toList()..sort()).join(',');
    final types = (dateTypes.toList()..sort()).join(',');
    return [
      lat, lng, cats, types,
      maxPriceLevel ?? '', maxDistanceKm ?? '', minRating ?? '',
      setting.name, openNow ? '1' : '0', openAt?.hour ?? '', limit,
    ].join('|');
  }
}
