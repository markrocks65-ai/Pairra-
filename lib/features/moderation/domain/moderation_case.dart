import 'package:flutter/foundation.dart';

import '../../safety/domain/report.dart';
import 'auto_moderation.dart';
import 'report_subject.dart';

/// Review state of a moderation case (the moderator/backend side).
enum ModerationStatus { pending, underReview, actioned, dismissed }

/// Triage priority. Severe categories escalate to [urgent].
enum ModerationPriority { normal, high, urgent }

/// A single moderation case in the review queue — the backend structure a
/// moderation team triages. It records who reported (for internal audit only —
/// NEVER shown to the reported user), the evidence subject, the reason, an
/// automated signal (placeholder), and its review state.
@immutable
class ModerationCase {
  const ModerationCase({
    required this.id,
    required this.subject,
    required this.reason,
    required this.reporterId,
    required this.createdAt,
    required this.priority,
    required this.escalated,
    this.note,
    this.status = ModerationStatus.pending,
    this.autoSignal = const ModerationSignal.notReviewed(),
    this.resolutionNote,
  });

  final String id;
  final ReportSubject subject;
  final ReportReason reason;

  /// Internal only. Never surfaced to the reported user or any client.
  final String reporterId;

  final DateTime createdAt;
  final ModerationPriority priority;
  final bool escalated;
  final String? note;
  final ModerationStatus status;
  final ModerationSignal autoSignal;
  final String? resolutionNote;

  ModerationCase copyWith({ModerationStatus? status, String? resolutionNote}) =>
      ModerationCase(
        id: id,
        subject: subject,
        reason: reason,
        reporterId: reporterId,
        createdAt: createdAt,
        priority: priority,
        escalated: escalated,
        note: note,
        status: status ?? this.status,
        autoSignal: autoSignal,
        resolutionNote: resolutionNote ?? this.resolutionNote,
      );
}

/// Maps report reasons to triage priority and escalation. Severe categories are
/// escalated for urgent human review and surface safety resources to the
/// reporter.
abstract final class SafetyEscalation {
  static const Set<ReportReason> severe = {
    ReportReason.threats,
    ReportReason.underageUser,
    ReportReason.nonConsensualContent,
    ReportReason.hateSpeech,
  };

  static const Set<ReportReason> elevated = {
    ReportReason.harassment,
    ReportReason.scam,
    ReportReason.impersonation,
  };

  static bool isEscalated(ReportReason reason) => severe.contains(reason);

  static ModerationPriority priorityFor(ReportReason reason) {
    if (severe.contains(reason)) return ModerationPriority.urgent;
    if (elevated.contains(reason)) return ModerationPriority.high;
    return ModerationPriority.normal;
  }
}
