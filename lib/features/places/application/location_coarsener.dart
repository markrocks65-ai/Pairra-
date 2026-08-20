import '../domain/places_query.dart';

/// Reduces a precise device location to an approximate origin BEFORE any query
/// leaves the app. This is how PAIRRA "uses approximate coordinates" and never
/// exposes the user's exact location to a provider or another user.
abstract final class LocationCoarsener {
  /// Snaps [lat]/[lng] to a coarse grid. The default ~0.01° (~1.1 km) cell is
  /// enough for "nearby" search while discarding precise position.
  static SearchOrigin coarsen(double lat, double lng,
      {double precisionDegrees = 0.01}) {
    double snap(double v) =>
        (v / precisionDegrees).roundToDouble() * precisionDegrees;
    return SearchOrigin(snap(lat), snap(lng));
  }
}
