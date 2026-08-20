import 'moderation_case.dart';

/// The moderation store — the backend structure for review. Clients only ever
/// SUBMIT; the queue and case details are server-only (Admin SDK / moderation
/// console), never exposed to any user. The [queue]/[updateStatus] methods
/// model the moderator side of a real backend.
abstract interface class ModerationRepository {
  /// Files a new case (client-callable).
  Future<void> submit(ModerationCase moderationCase);

  /// Moderator/back-office side — NOT for end users. A real implementation is
  /// guarded by admin auth + security rules.
  Future<List<ModerationCase>> queue({ModerationStatus? status});

  Future<void> updateStatus(String id, ModerationStatus status,
      {String? resolutionNote});
}
