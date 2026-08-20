import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/dates/application/cost_estimator.dart';
import 'package:pairra/features/dates/application/dates_controllers.dart';
import 'package:pairra/features/dates/domain/planned_date.dart';
import 'package:pairra/features/places/places.dart';

PlannedDate _date(String id, DateTime when) => PlannedDate(
      id: id,
      title: 'Date',
      dateTime: when,
      itinerary: const [],
      costMin: 30,
      costMax: 60,
      createdAt: DateTime.now(),
    );

const _venue = Venue(
  id: 'v1',
  name: 'Test',
  category: VenueCategory.park,
  price: VenuePriceRange(level: 1),
  location: VenueLocation(approxLat: 0, approxLng: 0, areaLabel: 'x'),
  photoSeed: 'p1',
  indoor: false,
  vibes: {},
);

void main() {
  group('CostEstimator', () {
    test('sums itinerary ranges without false precision', () {
      const stops = [
        ItineraryStop(time: 1140, title: 'Dinner', costMin: 30, costMax: 60),
        ItineraryStop(time: 1245, title: 'Walk', costMin: 0, costMax: 0),
        ItineraryStop(time: 1275, title: 'Dessert', costMin: 12, costMax: 28),
      ];
      final range = CostEstimator.forItinerary(stops);
      expect(range.min, 42);
      expect(range.max, 88);
      expect(range.label, '\$42–\$88 for two');
    });

    test('a zero range reads as Free', () {
      expect(const CostRange(0, 0).label, 'Free');
    });
  });

  group('Controllers', () {
    test('planned dates split into upcoming and past', () {
      final c = PlannedDatesController();
      c.add(_date('a', DateTime.now().add(const Duration(days: 2))));
      c.add(_date('b', DateTime.now().subtract(const Duration(days: 2))));
      expect(c.upcoming.map((d) => d.id), ['a']);
      expect(c.past.map((d) => d.id), ['b']);
      c.remove('a');
      expect(c.upcoming, isEmpty);
    });

    test('saved places toggle on and off', () {
      final c = SavedPlacesController();
      c.toggle(_venue);
      expect(c.isSaved('v1'), isTrue);
      c.toggle(_venue);
      expect(c.isSaved('v1'), isFalse);
    });
  });
}
