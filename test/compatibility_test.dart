import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/compatibility/application/compatibility_reasons.dart';
import 'package:pairra/features/compatibility/application/compatibility_service.dart';
import 'package:pairra/features/compatibility/domain/compatibility_category.dart';
import 'package:pairra/features/compatibility/domain/compatibility_explanation.dart';
import 'package:pairra/features/compatibility/domain/compatibility_profile.dart';
import 'package:pairra/features/compatibility/domain/compatibility_weights.dart';
import 'package:pairra/features/compatibility/domain/role_compatibility.dart';

const _service = CompatibilityService();

CompatibilityProfile p({
  Set<String> roles = const {},
  Set<String> preferredRoles = const {},
  int? age,
  int prefAgeMin = 18,
  int prefAgeMax = 99,
  GeoApprox? location,
  double maxDistanceKm = 80,
  Set<String> interests = const {},
  Set<String> intentions = const {},
}) {
  return CompatibilityProfile(
    roles: roles,
    age: age,
    location: location,
    interests: interests,
    datingIntentions: intentions,
    preferences: CompatibilityPreferences(
      preferredRoles: preferredRoles,
      ageMin: prefAgeMin,
      ageMax: prefAgeMax,
      maxDistanceKm: maxDistanceKm,
    ),
  );
}

double _sexual(CompatibilityProfile a, CompatibilityProfile b) =>
    _service.score(a, b).categoryScore(CompatibilityCategory.sexual)!.value;

void main() {
  group('Role matrix (intrinsic, reciprocal-symmetric)', () {
    double? s(Set<String> a, Set<String> b) =>
        RoleCompatibility.intrinsicRoleScore(a, b);

    test('classic pairings', () {
      expect(s({'top'}, {'bottom'}), 1.0);
      expect(s({'bottom'}, {'top'}), 1.0, reason: 'symmetric');
      expect(s({'versatile'}, {'bottom'}), 0.85);
      expect(s({'versatile'}, {'top'}), 0.85);
      expect(s({'versatile'}, {'versatile'}), 0.90);
      expect(s({'side'}, {'side'}), 0.60);
      expect(s({'top'}, {'top'}), 0.10);
    });

    test('unknown / prefer-not-to-say yields no data (null)', () {
      expect(s({'prefer_not_to_say'}, {'top'}), isNull);
      expect(s({}, {'top'}), isNull);
    });
  });

  group('Sexual compatibility (role + reciprocal preference)', () {
    test('Top+Bottom with aligned preferences is exceptional', () {
      final a = p(roles: {'top'}, preferredRoles: {'bottom'});
      final b = p(roles: {'bottom'}, preferredRoles: {'top'});
      expect(_sexual(a, b), greaterThan(0.95));
    });

    test('role alone does not decide it: mismatched preferences lower it', () {
      // Physically Top+Bottom (1.0) but A only wants tops.
      final a = p(roles: {'top'}, preferredRoles: {'top'});
      final b = p(roles: {'bottom'}, preferredRoles: {'top'});
      final aligned = _sexual(
        p(roles: {'top'}, preferredRoles: {'bottom'}),
        b,
      );
      expect(_sexual(a, b), lessThan(aligned));
      expect(_sexual(a, b), lessThan(0.7));
    });

    test('Top+Top is low even with open preferences', () {
      expect(_sexual(p(roles: {'top'}), p(roles: {'top'})), lessThan(0.2));
    });

    test('Vers pairs and Side+Side are reasonable', () {
      expect(_sexual(p(roles: {'versatile'}), p(roles: {'bottom'})),
          greaterThan(0.7));
      expect(_sexual(p(roles: {'versatile'}), p(roles: {'versatile'})),
          greaterThan(0.7));
      expect(_sexual(p(roles: {'side'}), p(roles: {'side'})),
          inInclusiveRange(0.45, 0.75));
    });
  });

  group('Reciprocal non-role categories', () {
    test('age fit is reciprocal — both ranges must contain the other', () {
      // A(25) wants 30–40; B(45) wants 20–30. Each falls outside the other.
      final a = p(age: 25, prefAgeMin: 30, prefAgeMax: 40);
      final b = p(age: 45, prefAgeMin: 20, prefAgeMax: 30);
      final v = _service
          .score(a, b)
          .categoryScore(CompatibilityCategory.agePreference)!
          .value;
      expect(v, lessThan(0.5));

      final ok = _service
          .score(p(age: 30, prefAgeMin: 25, prefAgeMax: 40),
              p(age: 34, prefAgeMin: 28, prefAgeMax: 36))
          .categoryScore(CompatibilityCategory.agePreference)!
          .value;
      expect(ok, 1.0);
    });

    test('distance respects both users\' maximum', () {
      final near = _service
          .score(
            p(location: const GeoApprox(40.0, -74.0), maxDistanceKm: 50),
            p(location: const GeoApprox(40.1, -74.0), maxDistanceKm: 50),
          )
          .categoryScore(CompatibilityCategory.distance)!
          .value;
      expect(near, 1.0);

      final far = _service
          .score(
            p(location: const GeoApprox(40.0, -74.0), maxDistanceKm: 5),
            p(location: const GeoApprox(41.0, -74.0), maxDistanceKm: 5),
          )
          .categoryScore(CompatibilityCategory.distance)!
          .value;
      expect(far, lessThan(0.2));
    });

    test('interests use Jaccard overlap', () {
      final v = _service
          .score(
            p(interests: {'fitness', 'travel', 'music'}),
            p(interests: {'travel', 'music', 'art'}),
          )
          .categoryScore(CompatibilityCategory.interests)!
          .value;
      expect(v, closeTo(0.5, 0.001));
    });
  });

  group('Overall score', () {
    test('is an estimate with a disclaimer and 0–100 percent', () {
      final r = _service.evaluate(
        p(roles: {'top'}, preferredRoles: {'bottom'}, interests: {'a'}),
        p(roles: {'bottom'}, preferredRoles: {'top'}, interests: {'a'}),
      );
      expect(r.score.isEstimate, isTrue);
      expect(r.score.percent, inInclusiveRange(0, 100));
      expect(CompatibilityExplanation.disclaimer, isNotEmpty);
    });

    test('categories without data are excluded, not counted as zero', () {
      // Only interests present for both → overall equals the interests score.
      final a = p(interests: {'fitness', 'travel'});
      final b = p(interests: {'fitness', 'travel'});
      final score = _service.score(a, b);
      expect(score.categoryScore(CompatibilityCategory.sexual)!.hasData,
          isFalse);
      expect(score.categoryScore(CompatibilityCategory.interests)!.hasData,
          isTrue);
      expect(score.overall, 1.0);
    });

    test('is reciprocal-symmetric: order does not change the result', () {
      final a = p(
          roles: {'top'},
          preferredRoles: {'bottom'},
          age: 30,
          interests: {'x', 'y'});
      final b = p(
          roles: {'bottom'},
          preferredRoles: {'top'},
          age: 32,
          interests: {'y', 'z'});
      expect(_service.score(a, b).overall,
          closeTo(_service.score(b, a).overall, 1e-9));
    });

    test('weights are configurable and change the outcome', () {
      // Great sexual fit, zero interests overlap.
      final a = p(roles: {'top'}, preferredRoles: {'bottom'}, interests: {'a1'});
      final b = p(roles: {'bottom'}, preferredRoles: {'top'}, interests: {'b1'});

      final standard = _service.score(a, b).overall;
      final interestHeavy = const CompatibilityService(
        weights: CompatibilityWeights({
          CompatibilityCategory.sexual: 0.1,
          CompatibilityCategory.interests: 5.0,
        }),
      ).score(a, b).overall;

      expect(interestHeavy, lessThan(standard));
    });
  });

  group('CompatibilityReasons ("Why you\'re seeing him")', () {
    test('lists strong categories, privacy-safe, capped', () {
      final score = _service
          .score(
            p(
                roles: {'top'},
                preferredRoles: {'bottom'},
                age: 30,
                prefAgeMin: 25,
                prefAgeMax: 40,
                interests: {'fitness', 'travel'},
                intentions: {'long_term'}),
            p(
                roles: {'bottom'},
                preferredRoles: {'top'},
                age: 32,
                prefAgeMin: 25,
                prefAgeMax: 40,
                interests: {'fitness', 'travel'},
                intentions: {'long_term'}),
          );
      final reasons = CompatibilityReasons.from(score);

      expect(reasons, isNotEmpty);
      expect(reasons.length, lessThanOrEqualTo(4));
      // Sexual dimension appears only as a band-style phrase, never a role.
      final joined = reasons.join(' ').toLowerCase();
      for (final banned in ['bottom', 'versatile', ' top', 'side']) {
        expect(joined.contains(banned), isFalse);
      }
      expect(reasons, contains('Relationship goals align'));
    });
  });

  group('Privacy of the explanation', () {
    test('never names sensitive role specifics', () {
      final r = _service.evaluate(
        p(roles: {'top'}, preferredRoles: {'bottom'}, interests: {'fitness'}),
        p(roles: {'bottom'}, preferredRoles: {'top'}, interests: {'fitness'}),
      );
      final all = [...r.explanation.highlights, ...r.explanation.considerations]
          .join(' ')
          .toLowerCase();
      for (final banned in ['bottom', 'versatile', ' top', 'vers_', 'side']) {
        expect(all.contains(banned), isFalse,
            reason: 'explanation leaked "$banned"');
      }
      // But sexual compatibility is still surfaced as a band.
      expect(
        r.explanation.highlights.any((h) => h.contains('sexual compatibility')),
        isTrue,
      );
    });

    test('names shared interests (non-sensitive) as a highlight', () {
      final r = _service.evaluate(
        p(interests: {'fitness', 'travel'}),
        p(interests: {'fitness', 'travel'}),
      );
      expect(
        r.explanation.highlights.any((h) => h.contains('fitness')),
        isTrue,
      );
    });
  });
}
