import '../domain/venue.dart';

/// A small TTL cache for public venue results. Caching public venue info is
/// permitted by (and reduces load on) the underlying provider; the TTL should
/// be set within the provider's terms. Nothing user-identifying is cached — the
/// key is a coarse query (see [PlacesQuery.cacheKey]).
class VenueCache {
  VenueCache({this.ttl = const Duration(minutes: 15), DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final Duration ttl;
  final DateTime Function() _now;
  final Map<String, _Entry> _entries = {};

  /// Fresh (non-expired) result, or null.
  List<Venue>? getFresh(String key) {
    final e = _entries[key];
    if (e == null) return null;
    return _now().isBefore(e.expires) ? e.venues : null;
  }

  /// Any cached result, even if expired — used as a fallback when rate-limited.
  List<Venue>? getStale(String key) => _entries[key]?.venues;

  void put(String key, List<Venue> venues) =>
      _entries[key] = _Entry(venues, _now().add(ttl));

  void clear() => _entries.clear();
}

class _Entry {
  _Entry(this.venues, this.expires);
  final List<Venue> venues;
  final DateTime expires;
}
