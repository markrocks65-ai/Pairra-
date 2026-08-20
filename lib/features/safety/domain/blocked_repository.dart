import 'blocked_user.dart';

/// App-wide blocklist backend. Blocking is cross-feature (discovery, matches and
/// messaging all respect it) and mutual — the server also hides anyone the user
/// blocked, and hides the user from them. Blocked entries live at
/// `users/{uid}/private/blocked/items/{targetUid}` (owner-scoped).
abstract interface class BlockedRepository {
  Stream<List<BlockedUser>> watchBlocked();
  Future<void> block(String id, {String? name});
  Future<void> unblock(String id);
}
