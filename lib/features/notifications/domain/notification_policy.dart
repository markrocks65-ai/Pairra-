import 'package:flutter/foundation.dart';

import 'notification_preferences.dart';
import 'notification_type.dart';

/// Which channels a single notification should go out on.
@immutable
class NotificationDecision {
  const NotificationDecision(
      {this.inApp = false, this.push = false, this.email = false});

  final bool inApp;
  final bool push;
  final bool email;

  bool get any => inApp || push || email;
}

/// The pure delivery policy. Combines the user's preferences with quiet hours,
/// and — critically — treats safety separately from everything else.
abstract final class NotificationPolicy {
  static NotificationDecision decide(
    NotificationType type,
    NotificationPreferences prefs,
    DateTime now,
  ) {
    final channels = prefs.channels(type.category);

    // Safety: always in-app, ignores quiet hours, cannot be fully silenced.
    if (type.category.isSafety) {
      return NotificationDecision(
        inApp: true,
        push: channels.push,
        email: channels.email,
      );
    }

    // Everything else honors preferences and quiet hours (push/email are held
    // during quiet hours; the in-app inbox still records it).
    final quiet = prefs.quietHours.contains(now);
    return NotificationDecision(
      inApp: channels.inApp,
      push: channels.push && !quiet,
      email: channels.email && !quiet,
    );
  }
}
