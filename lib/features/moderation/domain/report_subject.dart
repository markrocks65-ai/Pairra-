import 'package:flutter/foundation.dart';

/// What is being reported.
enum ReportSubjectType { user, message, photo }

/// The target of a report, with the minimum evidence a moderator needs. Message
/// text / photo references are captured here for REVIEW ONLY — they live in the
/// server-only moderation store and are never shown to the reported user or
/// anyone else.
@immutable
class ReportSubject {
  const ReportSubject({
    required this.type,
    required this.targetUserId,
    this.targetName,
    this.messageId,
    this.contentSnapshot,
    this.photoId,
  });

  final ReportSubjectType type;
  final String targetUserId;
  final String? targetName;

  final String? messageId;

  /// Evidence snapshot (e.g. the reported message text). Server-only.
  final String? contentSnapshot;

  final String? photoId;

  factory ReportSubject.user(String userId, {String? name}) =>
      ReportSubject(
          type: ReportSubjectType.user, targetUserId: userId, targetName: name);

  factory ReportSubject.message(
    String userId, {
    String? name,
    required String messageId,
    required String contentSnapshot,
  }) =>
      ReportSubject(
        type: ReportSubjectType.message,
        targetUserId: userId,
        targetName: name,
        messageId: messageId,
        contentSnapshot: contentSnapshot,
      );

  factory ReportSubject.photo(
    String userId, {
    String? name,
    required String photoId,
  }) =>
      ReportSubject(
        type: ReportSubjectType.photo,
        targetUserId: userId,
        targetName: name,
        photoId: photoId,
      );
}
