import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/moderation/application/moderation_service.dart';
import 'package:pairra/features/moderation/data/in_memory_moderation_repository.dart';
import 'package:pairra/features/moderation/domain/auto_moderation.dart';
import 'package:pairra/features/moderation/domain/moderation_case.dart';
import 'package:pairra/features/moderation/domain/report_subject.dart';
import 'package:pairra/features/safety/domain/report.dart';

ModerationService _service(InMemoryModerationRepository repo) => ModerationService(
      repo,
      const NoopAutoModerator(),
      reporterId: 'reporter1',
      clock: () => DateTime(2026, 1, 1, 12),
    );

void main() {
  group('SafetyEscalation', () {
    test('severe categories escalate to urgent', () {
      for (final r in SafetyEscalation.severe) {
        expect(SafetyEscalation.isEscalated(r), isTrue);
        expect(SafetyEscalation.priorityFor(r), ModerationPriority.urgent);
      }
    });

    test('elevated vs normal categories', () {
      expect(SafetyEscalation.priorityFor(ReportReason.harassment),
          ModerationPriority.high);
      expect(SafetyEscalation.priorityFor(ReportReason.spam),
          ModerationPriority.normal);
      expect(SafetyEscalation.isEscalated(ReportReason.spam), isFalse);
    });
  });

  group('ModerationService', () {
    test('report user files a case; severe reason escalates', () async {
      final repo = InMemoryModerationRepository();
      final outcome = await _service(repo).reportUser(
          targetId: 'u1', targetName: 'Alex', reason: ReportReason.threats);

      expect(outcome.escalated, isTrue);
      final cases = repo.all;
      expect(cases.length, 1);
      final c = cases.single;
      expect(c.subject.type, ReportSubjectType.user);
      expect(c.subject.targetUserId, 'u1');
      expect(c.reason, ReportReason.threats);
      expect(c.priority, ModerationPriority.urgent);
      expect(c.status, ModerationStatus.pending);
      // Reporter identity is stored for internal audit only.
      expect(c.reporterId, 'reporter1');
      // No automated moderation connected yet.
      expect(c.autoSignal.reviewed, isFalse);
    });

    test('report message captures the evidence snapshot', () async {
      final repo = InMemoryModerationRepository();
      await _service(repo).reportMessage(
        targetId: 'u1',
        messageId: 'm1',
        contentSnapshot: 'a nasty message',
        reason: ReportReason.harassment,
      );
      final c = repo.all.single;
      expect(c.subject.type, ReportSubjectType.message);
      expect(c.subject.contentSnapshot, 'a nasty message');
      expect(c.escalated, isFalse);
      expect(c.priority, ModerationPriority.high);
    });

    test('report photo records the photo reference', () async {
      final repo = InMemoryModerationRepository();
      await _service(repo).reportPhoto(
        targetId: 'u1',
        photoId: 'ph1',
        reason: ReportReason.nonConsensualContent,
      );
      final c = repo.all.single;
      expect(c.subject.type, ReportSubjectType.photo);
      expect(c.subject.photoId, 'ph1');
      expect(c.escalated, isTrue);
    });

    test('the reporter outcome never leaks who else reported', () {
      // ReportOutcome intentionally exposes only caseId + escalated.
      const outcome = ReportOutcome(caseId: 'x', escalated: false);
      expect(outcome.caseId, 'x');
      expect(outcome.escalated, isFalse);
    });
  });

  group('InMemoryModerationRepository queue', () {
    test('orders urgent cases before normal ones', () async {
      final repo = InMemoryModerationRepository();
      final service = _service(repo);
      await service.reportUser(targetId: 'a', reason: ReportReason.spam);
      await service.reportUser(targetId: 'b', reason: ReportReason.threats);

      final queue = await repo.queue();
      expect(queue.first.priority, ModerationPriority.urgent);
    });

    test('status can be updated (moderator side)', () async {
      final repo = InMemoryModerationRepository();
      await _service(repo).reportUser(targetId: 'a', reason: ReportReason.spam);
      final id = repo.all.single.id;
      await repo.updateStatus(id, ModerationStatus.dismissed,
          resolutionNote: 'no action');
      expect(repo.all.single.status, ModerationStatus.dismissed);
      expect(repo.all.single.resolutionNote, 'no action');
    });
  });
}
