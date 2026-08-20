import 'package:flutter/foundation.dart';

/// Lifecycle of a date.
enum DateStatus { suggested, upcoming, past }

/// One stop in a date itinerary (e.g. "7:00 PM — Dinner"). Optionally tied to a
/// venue; carries its own cost range so the total can be estimated.
@immutable
class ItineraryStop {
  const ItineraryStop({
    required this.time,
    required this.title,
    this.venueId,
    this.venueName,
    this.costMin = 0,
    this.costMax = 0,
    this.note,
  });

  /// Minutes from midnight (kept simple/serializable).
  final int time;
  final String title;
  final String? venueId;
  final String? venueName;
  final int costMin;
  final int costMax;
  final String? note;

  String get timeLabel {
    final h24 = time ~/ 60;
    final m = (time % 60).toString().padLeft(2, '0');
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h:$m ${h24 < 12 ? 'AM' : 'PM'}';
  }

  ItineraryStop copyWith({int? time, String? title, String? note}) =>
      ItineraryStop(
        time: time ?? this.time,
        title: title ?? this.title,
        venueId: venueId,
        venueName: venueName,
        costMin: costMin,
        costMax: costMax,
        note: note ?? this.note,
      );
}

/// A planned date — an itinerary the user has built or saved. `id` is stable;
/// `matchId`/`otherName` link it to the person, when applicable.
@immutable
class PlannedDate {
  const PlannedDate({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.itinerary,
    required this.costMin,
    required this.costMax,
    required this.createdAt,
    this.status = DateStatus.upcoming,
    this.matchId,
    this.otherName,
  });

  final String id;
  final String title;
  final DateTime dateTime;
  final List<ItineraryStop> itinerary;
  final int costMin;
  final int costMax;
  final DateTime createdAt;
  final DateStatus status;
  final String? matchId;
  final String? otherName;

  bool get isPast =>
      status == DateStatus.past || dateTime.isBefore(DateTime.now());
}
