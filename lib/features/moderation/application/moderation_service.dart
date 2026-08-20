// Private named param can't be an initializing formal.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../safety/domain/report.dart';
import '../data/in_memory_moderation_repository.dart';
import '../domain/auto_moderation.dart';
import '../domain/moderation_case.dart';
import '../domain/moderation_repository.dart';
import '../domain/report_subject.dart';

/// Returned to the reporter — deliberately minimal. Never reveals anything
/// about the report queue or the reported user's other reports.
@immutable
class ReportOutcome {
  const ReportOutcome({required this.caseId, required this.escalated});
  final String caseId;
  final bool escalated;
}

/// The one place reports are filed. Builds a [ModerationCase], runs the
/// (placeholder) automated scan, and submits it to the server-only queue. It
/// does NOT expose the queue, and never returns who else reported someone.
class ModerationService {
  ModerationService(
    this._repo,
    this._auto, {
    String reporterId = 'self',
    DateTime Function()? clock,
  })  : _reporterId = reporterId,
        _clock = clock ?? DateTime.now;

  final ModerationRepository _repo;
  final AutoModerator _auto;
  final String _reporterId;
  final DateTime Function() _clock;

  Future<ReportOutcome> reportUser({
    required String targetId,
    String? targetName,
    required ReportReason reason,
    String? note,
  }) =>
      _file(ReportSubject.user(targetId, name: targetName), reason, note);

  Future<ReportOutcome> reportMessage({
    required String targetId,
    String? targetName,
    required String messageId,
    required String contentSnapshot,
    required ReportReason reason,
    String? note,
  }) =>
      _file(
        ReportSubject.message(targetId,
            name: targetName,
            messageId: messageId,
            contentSnapshot: contentSnapshot),
        reason,
        note,
      );

  Future<ReportOutcome> reportPhoto({
    required String targetId,
    String? targetName,
    required String photoId,
    required ReportReason reason,
    String? note,
  }) =>
      _file(ReportSubject.photo(targetId, name: targetName, photoId: photoId),
          reason, note);

  Future<ReportOutcome> _file(
      ReportSubject subject, ReportReason reason, String? note) async {
    final now = _clock();

    // Placeholder automated moderation pass.
    final ModerationSignal signal = switch (subject.type) {
      ReportSubjectType.message =>
        await _auto.scanText(subject.contentSnapshot ?? ''),
      ReportSubjectType.photo =>
        await _auto.scanImageRef(subject.photoId ?? ''),
      ReportSubjectType.user => const ModerationSignal.notReviewed(),
    };

    final moderationCase = ModerationCase(
      id: 'case_${now.microsecondsSinceEpoch}',
      subject: subject,
      reason: reason,
      reporterId: _reporterId,
      createdAt: now,
      priority: SafetyEscalation.priorityFor(reason),
      escalated: SafetyEscalation.isEscalated(reason),
      note: note,
      autoSignal: signal,
    );
    await _repo.submit(moderationCase);
    return ReportOutcome(
        caseId: moderationCase.id, escalated: moderationCase.escalated);
  }
}

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => InMemoryModerationRepository(),
);

final autoModeratorProvider =
    Provider<AutoModerator>((ref) => const NoopAutoModerator());

final moderationServiceProvider = Provider<ModerationService>((ref) {
  return ModerationService(
    ref.watch(moderationRepositoryProvider),
    ref.watch(autoModeratorProvider),
  );
});
