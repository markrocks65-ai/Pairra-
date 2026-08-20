import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/match.dart';

/// In-memory store of the current user's matches (most recent first). Swap for
/// a Firestore-backed store later; the UI reads this provider unchanged.
class MatchesController extends StateNotifier<List<Match>> {
  MatchesController() : super(const []);

  void add(Match match) {
    if (state.any((m) => m.id == match.id)) return;
    state = [match, ...state];
  }

  /// Removes a match (on unmatch/block).
  void remove(String id) {
    if (!state.any((m) => m.id == id)) return;
    state = state.where((m) => m.id != id).toList();
  }

  void clear() => state = const [];
}

final matchesControllerProvider =
    StateNotifierProvider<MatchesController, List<Match>>(
  (ref) => MatchesController(),
);
