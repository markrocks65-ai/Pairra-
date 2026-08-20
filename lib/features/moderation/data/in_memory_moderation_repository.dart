import '../domain/moderation_case.dart';
import '../domain/moderation_repository.dart';

/// In-memory [ModerationRepository] standing in for the server-side moderation
/// queue. It is intentionally NOT surfaced in any user-facing screen — it
/// represents the back-office review store. Swap for a Firestore collection
/// (readable only by moderators via security rules) + Cloud Functions later.
class InMemoryModerationRepository implements ModerationRepository {
  final List<ModerationCase> _cases = [];

  @override
  Future<void> submit(ModerationCase moderationCase) async {
    _cases.add(moderationCase);
  }

  @override
  Future<List<ModerationCase>> queue({ModerationStatus? status}) async {
    final list = _cases
        .where((c) => status == null || c.status == status)
        .toList()
      ..sort((a, b) {
        final p = b.priority.index.compareTo(a.priority.index);
        return p != 0 ? p : a.createdAt.compareTo(b.createdAt);
      });
    return list;
  }

  @override
  Future<void> updateStatus(String id, ModerationStatus status,
      {String? resolutionNote}) async {
    final i = _cases.indexWhere((c) => c.id == id);
    if (i < 0) return;
    _cases[i] =
        _cases[i].copyWith(status: status, resolutionNote: resolutionNote);
  }

  /// Test/inspection helper (not a client API).
  List<ModerationCase> get all => List.unmodifiable(_cases);
}
