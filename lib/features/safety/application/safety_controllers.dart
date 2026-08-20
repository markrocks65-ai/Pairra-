import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/blocked_user.dart';

/// App-wide blocklist. Blocking is cross-feature (discovery, matches, messaging
/// all respect it) and takes effect immediately. In memory for now;
/// Firestore-backed later. Report submissions go through the moderation module.
class BlockedProfilesController extends StateNotifier<List<BlockedUser>> {
  BlockedProfilesController() : super(const []);

  bool isBlocked(String id) => state.any((b) => b.id == id);

  void block(String id, {String? name}) {
    if (isBlocked(id)) return;
    state = [BlockedUser(id, name: name), ...state];
  }

  void unblock(String id) {
    if (!isBlocked(id)) return;
    state = state.where((b) => b.id != id).toList();
  }

  void clear() => state = const [];
}

final blockedProfilesProvider =
    StateNotifierProvider<BlockedProfilesController, List<BlockedUser>>(
  (ref) => BlockedProfilesController(),
);
