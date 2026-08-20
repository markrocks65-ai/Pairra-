import '../domain/likes_repository.dart';

/// Default [LikesRepository] used before Firebase is wired (and in tests). Likes
/// and passes are no-ops; discovery still advances locally via the controller's
/// in-memory "seen" set.
class NoopLikesRepository implements LikesRepository {
  const NoopLikesRepository();

  @override
  Future<void> like(String targetUid, {bool superLike = false}) async {}

  @override
  Future<void> pass(String targetUid) async {}
}
