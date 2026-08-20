import 'candidate.dart';

/// Source of discoverable candidates. Behind an interface so the mock list can
/// be swapped for a Firestore/Cloud-Function query (which would also do the
/// coarse geo/age pre-filtering) without touching the controller or UI.
abstract interface class DiscoveryRepository {
  Future<List<Candidate>> fetchCandidates();
}
