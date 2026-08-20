import '../domain/match.dart';
import '../domain/matches_repository.dart';

/// Default [MatchesRepository] used before Firebase is wired (and in tests).
/// Emits an empty match list; the in-memory controller can still hold locally
/// added (mock) matches. Unmatch is a no-op.
class NoopMatchesRepository implements MatchesRepository {
  const NoopMatchesRepository();

  @override
  Stream<List<Match>> watchMatches() => Stream.value(const []);

  @override
  Future<void> unmatch(String matchId) async {}
}
