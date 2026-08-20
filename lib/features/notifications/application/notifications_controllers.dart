import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_notification.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_type.dart';

/// The in-app notification inbox (session-scoped; Firestore-ready later).
class NotificationsController extends StateNotifier<List<AppNotification>> {
  NotificationsController() : super(const []);

  void add(AppNotification notification) =>
      state = [notification, ...state];

  void markRead(String id) => state = [
        for (final n in state) n.id == id ? n.copyWith(read: true) : n,
      ];

  void markAllRead() =>
      state = [for (final n in state) n.copyWith(read: true)];

  void clear() => state = const [];

  int get unreadCount => state.where((n) => !n.read).length;
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, List<AppNotification>>(
  (ref) => NotificationsController(),
);

final unreadCountProvider = Provider<int>((ref) =>
    ref.watch(notificationsControllerProvider).where((n) => !n.read).length);

/// The user's notification preferences.
class NotificationPreferencesController
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesController() : super(const NotificationPreferences());

  void setChannel(NotificationCategory category, NotificationChannel channel,
          bool value) =>
      state = state.setChannel(category, channel, value);

  void setQuietHours(QuietHours hours) => state = state.setQuietHours(hours);
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesController, NotificationPreferences>(
  (ref) => NotificationPreferencesController(),
);
