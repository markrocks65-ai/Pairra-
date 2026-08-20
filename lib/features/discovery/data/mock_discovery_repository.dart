import '../../../core/models/profile_photo.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../domain/candidate.dart';
import '../domain/discovery_repository.dart';

/// In-memory candidate source with a small, diverse, curated set. Swap for a
/// Firestore/Cloud-Function query later (which would pre-filter by coarse
/// distance/age); the controller and UI don't change.
class MockDiscoveryRepository implements DiscoveryRepository {
  MockDiscoveryRepository({this.latency = const Duration(milliseconds: 350)});

  final Duration latency;

  @override
  Future<List<Candidate>> fetchCandidates() async {
    await Future<void>.delayed(latency);
    return _candidates;
  }

  static DateTime _dob(int age) => DateTime(DateTime.now().year - age, 6, 15);

  static OnboardingProfile _profile({
    required String name,
    required int age,
    required String photoSeed,
    required Set<String> roles,
    required Set<String> preferredRoles,
    required Set<String> interests,
    required Set<String> intentions,
    required String bio,
    required double lat,
    required double lng,
    LifestylePrefs lifestyle = const LifestylePrefs(),
    DatePreferences dates = const DatePreferences(),
  }) {
    return OnboardingProfile(
      status: OnboardingStatus.complete,
      displayName: name,
      dateOfBirth: _dob(age),
      genderId: 'man',
      orientationId: 'gay',
      bio: bio,
      photos: [ProfilePhoto(id: '${name}_1', placeholderSeed: photoSeed)],
      sexualRoles: roles,
      roleSetId: 'masc4masc_positions',
      datingIntentions: intentions,
      interests: interests,
      lifestyle: lifestyle,
      datePreferences: dates,
      lookingFor: LookingForPrefs(
        preferredRoles: preferredRoles,
        ageMin: 24,
        ageMax: 45,
        maxDistanceKm: 60,
      ),
      location: ApproximateLocation(
        granted: true,
        areaLabel: 'Nearby',
        approxLat: lat,
        approxLng: lng,
      ),
    );
  }

  static final List<Candidate> _candidates = [
    Candidate(
      id: 'marcus',
      likesYou: true,
      profile: _profile(
        name: 'Marcus',
        age: 29,
        photoSeed: 'p1',
        roles: {'top'},
        preferredRoles: {'bottom', 'vers_bottom'},
        interests: {'fitness', 'travel', 'coffee', 'food'},
        intentions: {'long_term', 'friends_first'},
        bio: 'Gym in the morning, good coffee, better conversation.',
        lat: 40.71,
        lng: -74.00,
        lifestyle: const LifestylePrefs(
            smoking: 'no', drinking: 'socially', communicationStyles: {'texter'}),
        dates: const DatePreferences(
            firstDates: {'coffee', 'walk'}, budgetId: '2'),
      ),
    ),
    Candidate(
      id: 'dylan',
      profile: _profile(
        name: 'Dylan',
        age: 34,
        photoSeed: 'p3',
        roles: {'bottom'},
        preferredRoles: {'top', 'vers_top'},
        interests: {'art', 'music', 'food', 'books'},
        intentions: {'long_term'},
        bio: 'Museum wanderer and amateur chef.',
        lat: 40.70,
        lng: -74.01,
        lifestyle: const LifestylePrefs(
            smoking: 'no', drinking: 'socially', communicationStyles: {'caller'}),
        dates: const DatePreferences(
            firstDates: {'dinner', 'museum'}, budgetId: '3'),
      ),
    ),
    Candidate(
      id: 'andre',
      likesYou: true,
      profile: _profile(
        name: 'Andre',
        age: 27,
        photoSeed: 'p2',
        roles: {'versatile'},
        preferredRoles: {},
        interests: {'gaming', 'technology', 'fitness', 'music'},
        intentions: {'open', 'casual'},
        bio: 'Building things and leveling up — join me?',
        lat: 40.73,
        lng: -73.99,
        lifestyle: const LifestylePrefs(
            smoking: 'no', drinking: 'no', communicationStyles: {'texter'}),
        dates: const DatePreferences(
            firstDates: {'activity', 'casual'}, budgetId: '2'),
      ),
    ),
    Candidate(
      id: 'leo',
      likesYou: true,
      profile: _profile(
        name: 'Leo',
        age: 31,
        photoSeed: 'p4',
        roles: {'vers_bottom'},
        preferredRoles: {'top', 'vers_top'},
        interests: {'travel', 'nightlife', 'fashion', 'coffee'},
        intentions: {'short_term', 'open'},
        bio: 'Always planning the next trip. Bring your passport.',
        lat: 40.68,
        lng: -73.98,
        lifestyle: const LifestylePrefs(
            smoking: 'sometimes',
            drinking: 'regularly',
            communicationStyles: {'quick_replies'}),
        dates: const DatePreferences(
            firstDates: {'drinks', 'concert'}, budgetId: '3'),
      ),
    ),
    Candidate(
      id: 'sam',
      profile: _profile(
        name: 'Sam',
        age: 41,
        photoSeed: 'p5',
        roles: {'side'},
        preferredRoles: {'side'},
        interests: {'books', 'outdoors', 'cooking', 'coffee'},
        intentions: {'friends_first', 'long_term'},
        bio: 'Trails, long dinners, and a good book.',
        lat: 40.75,
        lng: -74.05,
        lifestyle: const LifestylePrefs(
            smoking: 'no', drinking: 'no', communicationStyles: {'slow_burn'}),
        dates: const DatePreferences(
            firstDates: {'walk', 'coffee'}, budgetId: '2'),
      ),
    ),
    Candidate(
      id: 'noah',
      profile: _profile(
        name: 'Noah',
        age: 25,
        photoSeed: 'p6',
        roles: {'vers_top'},
        preferredRoles: {'bottom', 'vers_bottom'},
        interests: {'fitness', 'sports', 'music', 'travel'},
        intentions: {'casual', 'open'},
        bio: 'Weekend hikes and weeknight sets.',
        lat: 40.72,
        lng: -74.02,
        lifestyle: const LifestylePrefs(
            smoking: 'no',
            drinking: 'socially',
            communicationStyles: {'texter', 'quick_replies'}),
        dates: const DatePreferences(
            firstDates: {'activity', 'drinks'}, budgetId: '2'),
      ),
    ),
  ];
}
