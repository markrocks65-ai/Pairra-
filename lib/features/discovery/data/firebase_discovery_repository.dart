import 'package:cloud_functions/cloud_functions.dart';

import '../domain/candidate.dart';
import '../domain/discovery_repository.dart';
import 'public_card_mapper.dart';

/// Production [DiscoveryRepository]. Calls the server-side `discoverProfiles`
/// Cloud Function, which ranks real candidates for the signed-in user and
/// returns SANITIZED cards only (see functions/index.js + SECURITY.md). Cards
/// are mapped via [onboardingProfileFromPublicCard]; roles/coords/preferences
/// are intentionally absent.
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
    // states: ok | empty | unavailable (caller profile not complete yet).
    if (data['state'] != 'ok') return const [];
    final list = (data['profiles'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((m) {
          final card = Map<String, dynamic>.from(m);
          final uid = (card['uid'] ?? '').toString();
          return Candidate(
            id: uid,
            // discoverProfiles never signals reciprocal likes; "who likes you"
            // is a separate (premium) surface, so a card is always false here.
            likesYou: false,
            profile: onboardingProfileFromPublicCard(card, uidForPhotos: uid),
          );
        })
        .where((c) => c.id.isNotEmpty)
        .toList();
  }
}
