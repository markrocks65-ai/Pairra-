/// Records the current user's like / pass decisions. A like written to the
/// backend triggers server-side match creation (`onLikeCreated`) when it's
/// mutual — clients never create matches themselves.
abstract interface class LikesRepository {
  /// Record that the signed-in user likes [targetUid]. [superLike] marks a
  /// premium super-like (suppresses the generic "new like" notice).
  Future<void> like(String targetUid, {bool superLike = false});

  /// Record that the signed-in user passed on [targetUid] (so they don't
  /// resurface in discovery).
  Future<void> pass(String targetUid);
}
