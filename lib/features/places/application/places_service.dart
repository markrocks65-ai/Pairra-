import '../domain/places_query.dart';
import '../domain/places_repository.dart';
import '../domain/venue.dart';
import '../domain/venue_category.dart';
import 'location_coarsener.dart';
import 'rate_limiter.dart';
import 'venue_cache.dart';

/// The app-facing local-discovery service. It is provider-agnostic — it holds a
/// [PlacesRepository] and adds the cross-cutting concerns: coarse-location
/// privacy, result caching, rate limiting, approximate-distance computation,
/// and the high-level search methods the UI calls.
///
/// The UI depends on this service, never on a specific provider.
class PlacesService {
  PlacesService(
    this._repository, {
    VenueCache? cache,
    RateLimiter? rateLimiter,
  })  : _cache = cache ?? VenueCache(),
        _rateLimiter = rateLimiter ?? RateLimiter();

  final PlacesRepository _repository;
  final VenueCache _cache;
  final RateLimiter _rateLimiter;

  /// The primary entry point. Coarsens the origin, checks the cache, respects
  /// the rate limit, then applies approximate-distance filtering/sorting.
  Future<List<Venue>> search(PlacesQuery query) async {
    // 1. Never send an exact location to a provider.
    final coarse = query.origin == null
        ? null
        : LocationCoarsener.coarsen(
            query.origin!.approxLat, query.origin!.approxLng);
    final q = coarse == null ? query : query.copyWith(origin: coarse);

    final key = q.cacheKey;

    // 2. Serve fresh cache when available.
    final fresh = _cache.getFresh(key);
    if (fresh != null) return fresh;

    // 3. Respect the provider's rate limit — fall back to (stale) cache.
    if (!_rateLimiter.tryAcquire()) {
      return _cache.getStale(key) ?? const [];
    }

    // 4. Query the provider and apply approximate distance.
    final raw = await _repository.search(q);
    final result = _applyDistance(raw, q);
    _cache.put(key, result);
    return result;
  }

  List<Venue> _applyDistance(List<Venue> venues, PlacesQuery q) {
    final origin = q.origin;
    var list = origin != null
        ? [
            for (final v in venues)
              v.withDistance(
                  v.location.distanceKmTo(origin.approxLat, origin.approxLng)),
          ]
        : [...venues];
    if (q.maxDistanceKm != null) {
      list = list
          .where((v) => (v.distanceKm ?? 0) <= q.maxDistanceKm!)
          .toList();
    }
    list.sort((a, b) {
      if (origin != null) {
        return (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0);
      }
      final r = (b.rating ?? 0).compareTo(a.rating ?? 0);
      return r != 0 ? r : (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0);
    });
    return list;
  }

  Future<Venue?> venueById(String id) => _repository.venueById(id);

  // --- High-level search methods (the required capabilities) ----------------

  Future<List<Venue>> searchNearby(SearchOrigin origin,
          {double? maxDistanceKm, int limit = 30}) =>
      search(PlacesQuery(
          origin: origin, maxDistanceKm: maxDistanceKm, limit: limit));

  Future<List<Venue>> searchByCategory(VenueCategory category,
          {SearchOrigin? origin}) =>
      search(PlacesQuery(categories: {category}, origin: origin));

  Future<List<Venue>> searchByPrice(int maxPriceLevel,
          {SearchOrigin? origin}) =>
      search(PlacesQuery(maxPriceLevel: maxPriceLevel, origin: origin));

  Future<List<Venue>> searchByDistance(SearchOrigin origin, double maxKm) =>
      search(PlacesQuery(origin: origin, maxDistanceKm: maxKm));

  Future<List<Venue>> searchByRating(double minRating, {SearchOrigin? origin}) =>
      search(PlacesQuery(minRating: minRating, origin: origin));

  Future<List<Venue>> searchByDateType(Set<String> dateTypes,
          {SearchOrigin? origin}) =>
      search(PlacesQuery(dateTypes: dateTypes, origin: origin));

  Future<List<Venue>> searchOpenNow({SearchOrigin? origin, DateTime? at}) =>
      search(PlacesQuery(origin: origin, openNow: at == null, openAt: at));
}
