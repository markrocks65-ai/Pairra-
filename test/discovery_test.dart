import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/compatibility/application/compatibility_service.dart';
import 'package:pairra/features/discovery/application/discovery_controller.dart';
import 'package:pairra/features/discovery/application/matches_controller.dart';
import 'package:pairra/features/discovery/data/mock_discovery_repository.dart';
import 'package:pairra/features/discovery/domain/discovery_filters.dart';
import 'package:pairra/features/discovery/domain/match.dart';
import 'package:pairra/features/onboarding/domain/onboarding_profile.dart';
import 'package:pairra/features/safety/application/safety_controllers.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 5));

OnboardingProfile _self() => OnboardingProfile(
      displayName: 'Me',
      dateOfBirth: DateTime(DateTime.now().year - 30, 1, 1),
      genderId: 'man',
      orientationId: 'gay',
      sexualRoles: const {'top'},
      interests: const {'fitness', 'travel', 'music'},
      datingIntentions: const {'long_term'},
      lookingFor: const LookingForPrefs(
        preferredRoles: {'bottom', 'vers_bottom'},
        ageMin: 24,
        ageMax: 45,
        maxDistanceKm: 60,
      ),
      location: const ApproximateLocation(
          granted: true, approxLat: 40.71, approxLng: -74.0),
    );

DiscoveryController _controller(
  MatchesController matches, {
  BlockedProfilesController? blocked,
  bool premium = false,
}) =>
    DiscoveryController(
      MockDiscoveryRepository(latency: Duration.zero),
      const CompatibilityService(),
      _self(),
      matches,
      blocked ?? BlockedProfilesController(),
      premium: premium,
    );

void main() {
  test('candidates load ranked most-compatible first', () async {
    final c = _controller(MatchesController());
    await _settle();

    expect(c.state.loading, isFalse);
    expect(c.state.queue.length, greaterThan(1));
    for (var i = 0; i < c.state.queue.length - 1; i++) {
      expect(
        c.state.queue[i].score.overall,
        greaterThanOrEqualTo(c.state.queue[i + 1].score.overall),
        reason: 'queue must be sorted descending by compatibility',
      );
    }
  });

  test('like on a mutual candidate creates a match; pass never does', () async {
    final matches = MatchesController();
    final c = _controller(matches);
    await _settle();

    var expectedMatches = 0;
    while (c.state.current != null) {
      final mutual = c.state.current!.candidate.likesYou;
      final Match? result = c.like();
      if (mutual) {
        expect(result, isNotNull);
        expectedMatches++;
      } else {
        expect(result, isNull);
      }
    }

    expect(c.state.exhausted, isTrue);
    expect(matches.state.length, expectedMatches);
    expect(expectedMatches, greaterThan(0), reason: 'mock has mutual likers');
  });

  test('pass advances without creating a match', () async {
    final matches = MatchesController();
    final c = _controller(matches);
    await _settle();

    final first = c.state.current;
    c.pass();
    expect(c.state.current, isNot(equals(first)));
    expect(matches.state, isEmpty);
  });

  test('MatchesController de-duplicates by id', () {
    final matches = MatchesController();
    final m = Match(
      id: 'x',
      profile: const OnboardingProfile(displayName: 'X'),
      compatibilityPercent: 90,
      matchedAt: DateTime.now(),
    );
    matches.add(m);
    matches.add(m);
    expect(matches.state.length, 1);
  });

  test('maybe advances without a match', () async {
    final c = _controller(MatchesController());
    await _settle();
    final first = c.state.current;
    c.maybe();
    expect(c.state.current, isNot(equals(first)));
  });

  test('a minimum-compatibility filter shrinks the queue', () async {
    final c = _controller(MatchesController());
    await _settle();
    final before = c.state.queue.length;

    c.setFilters(const DiscoveryFilters(minCompatibility: 100));
    expect(c.state.queue.length, lessThan(before));

    // Every remaining candidate clears the threshold.
    for (final sc in c.state.queue) {
      expect(sc.score.percent, greaterThanOrEqualTo(100));
    }
  });

  test('an intention filter only keeps candidates who share it', () async {
    final c = _controller(MatchesController());
    await _settle();

    c.setFilters(const DiscoveryFilters(intentions: {'long_term'}));
    for (final sc in c.state.queue) {
      expect(sc.candidate.profile.datingIntentions, contains('long_term'));
    }
  });

  test('blocking removes a candidate and records it app-wide', () async {
    final blocked = BlockedProfilesController();
    final c = _controller(MatchesController(), blocked: blocked);
    await _settle();

    final id = c.state.current!.candidate.id;
    c.block(id);
    expect(blocked.isBlocked(id), isTrue);
    expect(c.state.queue.any((sc) => sc.candidate.id == id), isFalse);
  });

  test('free users consume likes; premium is unlimited', () async {
    final free = _controller(MatchesController());
    await _settle();
    expect(free.remainingLikes, 12);
    expect(free.canLike, isTrue);
    free.like();
    expect(free.remainingLikes, 11, reason: 'a like was consumed');

    final premium = _controller(MatchesController(), premium: true);
    await _settle();
    expect(premium.remainingLikes, isNull, reason: 'unlimited');
    premium.like();
    expect(premium.canLike, isTrue);
    expect(premium.remainingLikes, isNull);
  });

}
