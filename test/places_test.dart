import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/places/places.dart';

MockPlacesRepository _repo() => MockPlacesRepository(latency: Duration.zero);

/// Counts provider calls, to prove caching/rate-limiting.
class _CountingRepo implements PlacesRepository {
  int calls = 0;

  @override
  VenueSource get source => VenueSource.sample;

  @override
  Future<List<Venue>> search(PlacesQuery query) async {
    calls++;
    return const [
      Venue(
        id: 'a',
        name: 'A',
        category: VenueCategory.park,
        price: VenuePriceRange(level: 1),
        location: VenueLocation(approxLat: 40.71, approxLng: -74.0, areaLabel: 'x'),
        photoSeed: 'p1',
        indoor: false,
        vibes: {},
        rating: 4.0,
      ),
    ];
  }

  @override
  Future<Venue?> venueById(String id) async => null;
}

void main() {
  group('Value objects', () {
    test('price range symbol + estimate', () {
      const p = VenuePriceRange(level: 2, typicalForTwoMin: 45, typicalForTwoMax: 65);
      expect(p.symbol, '\$\$');
      expect(p.estimateLabel, '\$45–\$65');
      expect(const VenuePriceRange(level: 1).estimateLabel, 'Free');
    });

    test('hours isOpenAt handles after-midnight close', () {
      const bar = VenueHours(label: '', openMinute: 960, closeMinute: 1500); // 4pm–1am
      expect(bar.isOpenAt(DateTime(2026, 1, 1, 23)), isTrue);
      expect(bar.isOpenAt(DateTime(2026, 1, 1, 0, 30)), isTrue);
      expect(bar.isOpenAt(DateTime(2026, 1, 1, 12)), isFalse);
      expect(const VenueHours(label: '').isOpenAt(DateTime(2026)), isNull);
    });

    test('location computes an approximate distance', () {
      const loc = VenueLocation(approxLat: 40.71, approxLng: -74.0, areaLabel: 'x');
      expect(loc.distanceKmTo(40.71, -74.0), closeTo(0, 0.01));
      expect(loc.distanceKmTo(40.80, -74.0), greaterThan(5));
    });
  });

  group('LocationCoarsener', () {
    test('snaps to a coarse grid (drops precise position)', () {
      final o = LocationCoarsener.coarsen(40.712533, -74.006109);
      expect(o.approxLat, closeTo(40.71, 1e-9));
      expect(o.approxLng, closeTo(-74.01, 1e-9));
    });
  });

  group('MockPlacesRepository', () {
    test('returns only public, sample venues', () async {
      final venues = await _repo().search(const PlacesQuery());
      expect(venues, isNotEmpty);
      for (final v in venues) {
        expect(v.isSample, isTrue);
        expect(v.safety, isIn(SafetyLabel.values));
      }
    });

    test('filters by category, price, rating and vibe', () async {
      expect(
        (await _repo().search(
                const PlacesQuery(categories: {VenueCategory.coffee})))
            .every((v) => v.category == VenueCategory.coffee),
        isTrue,
      );
      expect(
        (await _repo().search(const PlacesQuery(maxPriceLevel: 1)))
            .every((v) => v.price.level <= 1),
        isTrue,
      );
      expect(
        (await _repo().search(const PlacesQuery(minRating: 4.6)))
            .every((v) => (v.rating ?? 0) >= 4.6),
        isTrue,
      );
      expect(
        (await _repo().search(const PlacesQuery(dateTypes: {'romantic'})))
            .every((v) => v.vibes.contains('romantic')),
        isTrue,
      );
    });

    test('open-at filter respects hours', () async {
      // 2 AM: only very-late venues remain.
      final late = await _repo()
          .search(PlacesQuery(openAt: DateTime(2026, 1, 1, 2)));
      for (final v in late) {
        expect(v.hours?.isOpenAt(DateTime(2026, 1, 1, 2)), isNot(false));
      }
    });
  });

  group('PlacesService', () {
    test('computes approximate distance from a coarse origin and sorts',
        () async {
      final service = PlacesService(_repo());
      final results = await service.search(
        const PlacesQuery(origin: SearchOrigin(40.712, -74.006)),
      );
      expect(results, isNotEmpty);
      expect(results.every((v) => v.distanceKm != null), isTrue);
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].distanceKm!,
            lessThanOrEqualTo(results[i + 1].distanceKm!));
      }
    });

    test('caches results (provider not hit twice for the same query)',
        () async {
      final repo = _CountingRepo();
      final service = PlacesService(repo);
      const q = PlacesQuery(categories: {VenueCategory.park});
      await service.search(q);
      await service.search(q);
      expect(repo.calls, 1);
    });

    test('respects the rate limit, falling back instead of hammering the API',
        () async {
      final repo = _CountingRepo();
      // No tokens, no refill → every acquire fails.
      final service = PlacesService(repo,
          rateLimiter: RateLimiter(capacity: 0, refillPerSecond: 0));
      final result = await service.search(const PlacesQuery());
      expect(repo.calls, 0, reason: 'provider never called when rate-limited');
      expect(result, isEmpty);
    });

    test('searchByCategory returns only that category', () async {
      final service = PlacesService(_repo());
      final coffee = await service.searchByCategory(VenueCategory.coffee);
      expect(coffee.every((v) => v.category == VenueCategory.coffee), isTrue);
    });
  });
}
