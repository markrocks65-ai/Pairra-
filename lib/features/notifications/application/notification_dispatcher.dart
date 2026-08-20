// Private named params can't be initializing formals.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_notification.dart';
import '../domain/notification_policy.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_type.dart';
import '../domain/push_provider.dart';
import 'notifications_controllers.dart';

/// The single entry point for raising a notification. It applies the delivery
/// policy (preferences + quiet hours + safety separation) and an anti-spam
/// throttle so users are never flooded, then records the in-app item and
/// (when connected) sends a push.
class NotificationDispatcher {
  NotificationDispatcher({
    required NotificationsController inbox,
    required PushProvider push,
    required NotificationPreferences Function() preferences,
    DateTime Function()? clock,
    this.marketingMinInterval = const Duration(hours: 12),
  })  : _inbox = inbox,
        _push = push,
        _preferences = preferences,
        _clock = clock ?? DateTime.now;

  final NotificationsController _inbox;
  final PushProvider _push;
  final NotificationPreferences Function() _preferences;
  final DateTime Function() _clock;

  /// Marketing/recommendation notifications can't repeat within this window.
  final Duration marketingMinInterval;

  DateTime? _lastMarketing;

  void dispatch(NotificationType type,
      {required String title, required String body}) {
    final now = _clock();

    // Don't send excessive marketing notifications.
    if (type.category == NotificationCategory.marketing &&
        _lastMarketing != null &&
        now.difference(_lastMarketing!) < marketingMinInterval) {
      return;
    }

    final decision = NotificationPolicy.decide(type, _preferences(), now);
    if (!decision.any) return;

    if (type.category == NotificationCategory.marketing) _lastMarketing = now;

    if (decision.inApp) {
      _inbox.add(AppNotification(
        id: 'ntf_${now.microsecondsSinceEpoch}_${type.name}',
        type: type,
        title: title,
        body: body,
        createdAt: now,
      ));
    }
    if (decision.push) {
      _push.send(title: title, body: body);
    }
    // decision.email would call an EmailProvider seam (omitted for now).
  }
}

final pushProviderProvider =
    Provider<PushProvider>((ref) => const UnconnectedPushProvider());

final notificationDispatcherProvider = Provider<NotificationDispatcher>((ref) {
  return NotificationDispatcher(
    inbox: ref.watch(notificationsControllerProvider.notifier),
    push: ref.watch(pushProviderProvider),
    preferences: () => ref.read(notificationPreferencesProvider),
  );
});
