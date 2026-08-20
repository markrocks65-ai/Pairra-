import 'package:flutter/foundation.dart';

enum SafetyPlanStatus { active, completed }

/// A user's plan for a specific date — who/where/when, an optional trusted
/// contact, and an optional check-in. Private to the user; never shared with a
/// match.
@immutable
class SafetyPlan {
  const SafetyPlan({
    required this.id,
    required this.meetingName,
    required this.place,
    required this.time,
    required this.createdAt,
    this.trustedContact,
    this.checkInEnabled = false,
    this.checkInAt,
    this.status = SafetyPlanStatus.active,
  });

  final String id;
  final String meetingName;
  final String place;
  final DateTime time;
  final DateTime createdAt;
  final String? trustedContact;
  final bool checkInEnabled;

  /// When the app should remind the user to check in (default: 2h after start).
  final DateTime? checkInAt;

  final SafetyPlanStatus status;

  bool get isActive => status == SafetyPlanStatus.active;

  /// A check-in is outstanding for this active plan.
  bool get hasPendingCheckIn => isActive && checkInEnabled && checkInAt != null;

  SafetyPlan copyWith({SafetyPlanStatus? status}) => SafetyPlan(
        id: id,
        meetingName: meetingName,
        place: place,
        time: time,
        createdAt: createdAt,
        trustedContact: trustedContact,
        checkInEnabled: checkInEnabled,
        checkInAt: checkInAt,
        status: status ?? this.status,
      );
}
