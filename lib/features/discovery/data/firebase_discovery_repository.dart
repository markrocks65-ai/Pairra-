import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/models/profile_photo.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../domain/candidate.dart';
import '../domain/discovery_repository.dart';

/// Production [DiscoveryRepository]. Calls the server-side `discoverProfiles`
/// Cloud Function, which ranks real candidates for the signed-in user and
/// returns SANITIZED cards only — display name, age, bio, photos, interests,
/// intentions, gender/orientation, a coarse area label and a single distance
/// scalar. It deliberately never returns coordinates, sexual roles, or private
/// preferences (see functions/index.js + SECURITY.md), so the mapped profile
/// intentionally leaves those fields empty.
class FirebaseDiscoveryRepository implements DiscoveryRepository {
  FirebaseDiscoveryRepository([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<List<Candidate>> fetchCandidates() async {
    final res = await _functions.httpsCallable('discoverProfiles').call();
    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data as Map)
        : const <String, dynamic>{};
    // states: ok | empty | unavailable (profile not complete yet).
    if (data['state'] != 'ok') return const [];
    final list = (data['profiles'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((m) => _toCandidate(Map<String, dynamic>.from(m)))
        .where((c) => c.id.isNotEmpty)
        .toList();
  }

  Candidate _toCandidate(Map<String, dynamic> card) {
    final uid = (card['uid'] ?? '').toString();
    final age = (card['age'] as num?)?.toInt();
    return Candidate(
      id: uid,
      // discoverProfiles never signals reciprocal likes; "who likes you" is a
      // separate (premium) surface, so a discovery card is always false here.
      likesYou: false,
      profile: OnboardingProfile(
        status: OnboardingStatus.complete,
        displayName: card['displayName'] as String?,
        bio: card['bio'] as String?,
        dateOfBirth:
            age == null ? null : DateTime(DateTime.now().year - age, 6, 15),
        genderId: card['genderId'] as String?,
        genderCustom: card['genderCustom'] as String?,
        orientationId: card['orientationId'] as String?,
        orientationCustom: card['orientationCustom'] as String?,
        interests: _stringSet(card['interests']),
        datingIntentions: _stringSet(card['datingIntentions']),
        photos: _photos(card['photos'], uid),
        // Coarse area label only — the server never ships coordinates.
        location: ApproximateLocation(
          granted: card['areaLabel'] != null,
          areaLabel: card['areaLabel'] as String?,
        ),
      ),
    );
  }

  Set<String> _stringSet(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toSet() : <String>{};

  List<ProfilePhoto> _photos(dynamic v, String uid) {
    if (v is! List) return const [];
    final out = <ProfilePhoto>[];
    for (var i = 0; i < v.length; i++) {
      final p = v[i];
      var id = '${uid}_$i';
      var seed = 'p1';
      String? url;
      if (p is String) {
        if (p.startsWith('http')) {
          url = p;
        } else {
          seed = p;
        }
      } else if (p is Map) {
        final m = Map<String, dynamic>.from(p);
        id = (m['id'] ?? id).toString();
        url = m['url'] as String?;
        seed = (m['placeholderSeed'] ?? m['seed'] ?? seed).toString();
      }
      out.add(ProfilePhoto(
        id: id,
        placeholderSeed: seed,
        url: url,
        moderation: PhotoModerationStatus.approved,
      ));
    }
    return out;
  }
}
