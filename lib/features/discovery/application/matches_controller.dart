import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/noop_matches_repository.dart';
import '../domain/match.dart';
import '../domain/matches_repository.dart';

/// The current user's matches (most recent first). In production this is driven
/// by a live Firestore stream ([MatchesRepository.watchMatches]); before
/// Firebase is wired it stays empty and only holds locally added (mock) matches.
class MatchesController extends StateNotifier<List<Match>> {
  MatchesController(this._repository) : super(const []) {
    _sub = _repository.watchMatches().listen(
      (list) => state = list,
      onError: (_) {},
    );
  }

  final MatchesRepository _repository;
  StreamSubscription<List<Match>>? _sub;

  /// Local optimistic add (used by the mock/dev fake-match path). In production
  /// the stream is authoritative, so real matches arrive on their own.
  void add(Match match) {
    if (state.any((m) => m.id == match.id)) return;
    state = [match, ...state];
  }

  /// Unmatch: optimistically drop it, then ask the server (authoritative). The
  /// stream will reconcile if the server call fails.
  Future<void> remove(String id) async {
    if (state.any((m) => m.id == id)) {
      state = state.where((m) => m.id != id).toList();
    }
    try {
      await _repository.unmatch(id);
    } catch (_) {}
  }

  void clear() => state = const [];

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// The matches backend. Defaults to a no-op (empty) source; overridden with a
/// Firestore-backed repository in firebaseBootstrap.
final matchesRepositoryProvider = Provider<MatchesRepository>(
  (ref) => const NoopMatchesRepository(),
);

final matchesControllerProvider =
    StateNotifierProvider<MatchesController, List<Match>>(
  (ref) => MatchesController(ref.watch(matchesRepositoryProvider)),
);
