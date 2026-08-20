import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/noop_blocked_repository.dart';
import '../domain/blocked_repository.dart';
import '../domain/blocked_user.dart';

/// App-wide blocklist. Blocking is cross-feature (discovery, matches, messaging
/// all respect it) and takes effect immediately (optimistic), then persists via
/// the [BlockedRepository]. In production the list is driven by a live Firestore
/// stream so it survives relaunches and applies mutual invisibility server-side.
class BlockedProfilesController extends StateNotifier<List<BlockedUser>> {
  BlockedProfilesController(this._repository) : super(const []) {
    _sub = _repository.watchBlocked().listen(
          (list) => state = list,
          onError: (_) {},
        );
  }

  final BlockedRepository _repository;
  StreamSubscription<List<BlockedUser>>? _sub;

  bool isBlocked(String id) => state.any((b) => b.id == id);

  void block(String id, {String? name}) {
    if (!isBlocked(id)) {
      state = [BlockedUser(id, name: name), ...state];
    }
    _repository.block(id, name: name);
  }

  void unblock(String id) {
    if (isBlocked(id)) {
      state = state.where((b) => b.id != id).toList();
    }
    _repository.unblock(id);
  }

  void clear() => state = const [];

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// The blocklist backend. Defaults to a no-op (in-memory) source; overridden
/// with a Firestore-backed repository in firebaseBootstrap.
final blockedRepositoryProvider = Provider<BlockedRepository>(
  (ref) => const NoopBlockedRepository(),
);

final blockedProfilesProvider =
    StateNotifierProvider<BlockedProfilesController, List<BlockedUser>>(
  (ref) => BlockedProfilesController(ref.watch(blockedRepositoryProvider)),
);
