import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A venue's location — APPROXIMATE only. PAIRRA never stores or exposes exact
/// coordinates for the user, and treats venue coordinates as coarse too. The
/// human-facing value is [areaLabel] + [distanceKm]; raw coordinates exist only
/// to compute an approximate distance.
@immutable
class VenueLocation {
  const VenueLocation({
    required this.approxLat,
    required this.approxLng,
    required this.areaLabel,
    this.distanceKm,
  });

  final double approxLat;
  final double approxLng;
  final String areaLabel;

  /// Approximate distance from the searcher's coarse location, filled in by the
  /// service. Null when unknown.
  final double? distanceKm;

  /// Great-circle distance (km) to another approximate point.
  double distanceKmTo(double lat, double lng) {
    const earthKm = 6371.0;
    double rad(double d) => d * math.pi / 180.0;
    final dLat = rad(lat - approxLat);
    final dLng = rad(lng - approxLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(approxLat)) *
            math.cos(rad(lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  VenueLocation copyWith({double? distanceKm}) => VenueLocation(
        approxLat: approxLat,
        approxLng: approxLng,
        areaLabel: areaLabel,
        distanceKm: distanceKm ?? this.distanceKm,
      );
}
