import 'package:flutter/foundation.dart';

import 'notification_type.dart';

/// Per-category channel switches.
@immutable
class ChannelPrefs {
  const ChannelPrefs({this.push = true, this.email = true, this.inApp = true});

  final bool push;
  final bool email;
  final bool inApp;

  bool enabled(NotificationChannel channel) => switch (channel) {
        NotificationChannel.push => push,
        NotificationChannel.email => email,
        NotificationChannel.inApp => inApp,
      };

  ChannelPrefs copyWith({bool? push, bool? email, bool? inApp}) => ChannelPrefs(
        push: push ?? this.push,
        email: email ?? this.email,
        inApp: inApp ?? this.inApp,
      );
}

/// A daily quiet window during which non-safety push/email are held back.
@immutable
class QuietHours {
  const QuietHours({
    this.enabled = true,
    this.startMinute = 22 * 60,
    this.endMinute = 8 * 60,
  });

  final bool enabled;
  final int startMinute; // minutes from midnight
  final int endMinute;

  bool contains(DateTime when) {
    if (!enabled) return false;
    final m = when.hour * 60 + when.minute;
    if (startMinute == endMinute) return false;
    return startMinute < endMinute
        ? (m >= startMinute && m < endMinute)
        : (m >= startMinute || m < endMinute); // wraps past midnight
  }

  QuietHours copyWith({bool? enabled, int? startMinute, int? endMinute}) =>
      QuietHours(
        enabled: enabled ?? this.enabled,
        startMinute: startMinute ?? this.startMinute,
        endMinute: endMinute ?? this.endMinute,
      );
}

/// The user's notification preferences: per-category channels + quiet hours.
@immutable
class NotificationPreferences {
  const NotificationPreferences({this.byCategory = const {}, this.quietHours =
      const QuietHours()});

  final Map<NotificationCategory, ChannelPrefs> byCategory;
  final QuietHours quietHours;

  ChannelPrefs channels(NotificationCategory category) =>
      byCategory[category] ?? const ChannelPrefs();

  NotificationPreferences setChannel(
      NotificationCategory category, NotificationChannel channel, bool value) {
    final current = channels(category);
    final updated = switch (channel) {
      NotificationChannel.push => current.copyWith(push: value),
      NotificationChannel.email => current.copyWith(email: value),
      NotificationChannel.inApp => current.copyWith(inApp: value),
    };
    return NotificationPreferences(
      byCategory: {...byCategory, category: updated},
      quietHours: quietHours,
    );
  }

  NotificationPreferences setQuietHours(QuietHours hours) =>
      NotificationPreferences(byCategory: byCategory, quietHours: hours);
}
