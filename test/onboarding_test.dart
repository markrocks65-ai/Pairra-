import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/core/config/preference_config.dart';
import 'package:pairra/features/onboarding/application/onboarding_controller.dart';
import 'package:pairra/features/onboarding/application/onboarding_steps.dart';
import 'package:pairra/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:pairra/features/onboarding/domain/onboarding_profile.dart';
import 'package:pairra/features/onboarding/domain/onboarding_repository.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 5));

/// Counts writes so we can assert keystroke edits are coalesced, not persisted
/// one-per-character (a Firestore cost / battery concern).
class _CountingRepo implements OnboardingRepository {
  int saveCount = 0;
  OnboardingProfile _stored = const OnboardingProfile();

  @override
  Future<OnboardingProfile> load(String uid) async => _stored;

  @override
  Future<void> save(String uid, OnboardingProfile profile) async {
    saveCount++;
    _stored = profile;
  }

  @override
  Future<void> clear(String uid) async => _stored = const OnboardingProfile();
}

void main() {
  group('PreferenceConfig.roleSetFor (configurable, not hard-coded)', () {
    test('gay man gets the gay-male position vocabulary', () {
      final set = PreferenceConfig.roleSetFor(
          genderId: 'man', orientationId: 'gay');
      expect(set?.id, PreferenceConfig.gayMaleRoles.id);
      expect(set!.roles.map((o) => o.id), contains('vers_bottom'));
    });

    test('other audiences get a neutral set, never the gay-male one', () {
      final set = PreferenceConfig.roleSetFor(
          genderId: 'woman', orientationId: 'straight');
      expect(set?.id, PreferenceConfig.genericDynamicsRoles.id);
      expect(set?.id, isNot(PreferenceConfig.gayMaleRoles.id));
    });
  });

  group('OnboardingProfile', () {
    test('age is derived from date of birth and gates on 18', () {
      final now = DateTime.now();
      final adult =
          OnboardingProfile(dateOfBirth: DateTime(now.year - 25, now.month, now.day));
      expect(adult.age, 25);
      expect(adult.isAdult, isTrue);

      final minor =
          OnboardingProfile(dateOfBirth: DateTime(now.year - 15, now.month, now.day));
      expect(minor.isAdult, isFalse);
    });

    test('sensitive fields default to non-public', () {
      const p = OnboardingProfile();
      expect(p.visibilityOf('roles'), FieldVisibility.matchesOnly);
      expect(p.visibilityOf('orientation'), FieldVisibility.matchesOnly);
      expect(p.visibilityOf('gender'), FieldVisibility.public);
    });

    test('readiness estimate grows as the profile fills in', () {
      const empty = OnboardingProfile();
      final full = OnboardingProfile(
        displayName: 'Alex',
        dateOfBirth: DateTime(1995),
        genderId: 'man',
        orientationId: 'gay',
        datingIntentions: const {'long_term'},
        sexualRoles: const {'vers'},
        interests: const {'a', 'b', 'c'},
        personality: const {'q': 'x'},
        datePreferences: const DatePreferences(firstDates: {'coffee'}),
        location: const ApproximateLocation(granted: true, areaLabel: 'x'),
      );
      expect(empty.readinessEstimate, 0);
      expect(full.readinessEstimate, greaterThan(empty.readinessEstimate));
      expect(full.readinessEstimate, lessThanOrEqualTo(100));
    });
  });

  group('OnboardingState.steps (progressive disclosure)', () {
    test('includes the roles step when a role set applies', () {
      const state = OnboardingState(
        draft: OnboardingProfile(genderId: 'man', orientationId: 'gay'),
        loading: false,
      );
      expect(state.steps, contains(OnboardingStep.roles));
      expect(state.steps.length, OnboardingStep.values.length);
    });
  });

  group('OnboardingController (resume + status)', () {
    test('edits persist and a fresh controller resumes them', () async {
      final repo = InMemoryOnboardingRepository(latency: Duration.zero);
      final c1 = OnboardingController(repo, 'user-1');
      await _settle();

      c1.update((p) => p.copyWith(displayName: 'Alex'));
      await _settle();
      expect(c1.state.draft.status, OnboardingStatus.inProgress);
      c1.dispose();

      final c2 = OnboardingController(repo, 'user-1');
      await _settle();
      expect(c2.state.draft.displayName, 'Alex');
      c2.dispose();
    });

    test('rapid edits are debounced into a single persisted write', () async {
      final repo = _CountingRepo();
      final c = OnboardingController(repo, 'typist');
      await _settle();

      // Simulate fast typing: many edits inside the debounce window.
      for (final ch in 'Alexander'.split('')) {
        c.update((p) => p.copyWith(displayName: (p.displayName ?? '') + ch));
      }
      // Before the debounce elapses, nothing (or nearly nothing) is written.
      expect(repo.saveCount, 0);

      // After the window, exactly one coalesced write lands.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(repo.saveCount, 1);
      expect(repo.load('typist'), completion(isA<OnboardingProfile>()));

      c.dispose();
    });

    test('finish flushes immediately rather than waiting out the debounce',
        () async {
      final repo = _CountingRepo();
      final c = OnboardingController(repo, 'finisher');
      await _settle();

      c.finish();
      await _settle(); // well under the 600ms debounce
      expect(repo.saveCount, greaterThanOrEqualTo(1),
          reason: 'a terminal choice persists promptly');

      c.dispose();
    });

    test('finish and skip set the right status', () async {
      final repo = InMemoryOnboardingRepository(latency: Duration.zero);
      final c = OnboardingController(repo, 'user-2');
      await _settle();

      c.finish();
      await _settle();
      expect(c.state.draft.status, OnboardingStatus.complete);
      expect(c.state.draft.completedAt, isNotNull);
      c.dispose();

      final other = OnboardingController(repo, 'user-3');
      await _settle();
      other.skipForNow();
      await _settle();
      expect(other.state.draft.status, OnboardingStatus.skipped);
      other.dispose();
    });
  });
}
