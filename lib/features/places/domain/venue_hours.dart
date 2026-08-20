import 'package:flutter/foundation.dart';

/// Opening hours. Carries a human [label] plus optional structured open/close
/// minutes-of-day so the service can answer "open now"/"open at" queries.
/// [closeMinute] may exceed 1440 to express closing after midnight (e.g. a bar
/// open until 1 AM = 1500).
@immutable
class VenueHours {
  const VenueHours({required this.label, this.openMinute, this.closeMinute});

  final String label;
  final int? openMinute;
  final int? closeMinute;

  bool get hasStructuredHours => openMinute != null && closeMinute != null;

  /// Whether the venue is open at [when]. Returns null when hours are unknown.
  bool? isOpenAt(DateTime when) {
    final open = openMinute, close = closeMinute;
    if (open == null || close == null) return null;
    final m = when.hour * 60 + when.minute;
    if (close > 1440) {
      // Wraps past midnight.
      return m >= open || m <= (close - 1440);
    }
    return m >= open && m <= close;
  }
}
