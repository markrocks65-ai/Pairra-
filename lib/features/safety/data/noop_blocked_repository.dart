import '../domain/blocked_repository.dart';
import '../domain/blocked_user.dart';

/// Default [BlockedRepository] before Firebase is wired (and in tests). The
/// controller keeps blocks in memory; this backend persists nothing.
class NoopBlockedRepository implements BlockedRepository {
  const NoopBlockedRepository();

  @override
  Stream<List<BlockedUser>> watchBlocked() => const Stream.empty();

  @override
  Future<void> block(String id, {String? name}) async {}

  @override
  Future<void> unblock(String id) async {}
}
