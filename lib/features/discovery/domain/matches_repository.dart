import 'match.dart';

/// Source of the signed-in user's mutual matches. Clients can only READ matches
/// (the server creates them via `onLikeCreated`); unmatching goes through a
/// server callable, never a direct write.
abstract interface class MatchesRepository {
  /// Live stream of the user's active matches, most recent first.
  Stream<List<Match>> watchMatches();

  /// Unmatch (participant-only, server-verified via the `unmatch` callable).
  Future<void> unmatch(String matchId);
}
