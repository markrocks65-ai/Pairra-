import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/notifications/application/notification_dispatcher.dart';
import 'package:pairra/features/notifications/application/notifications_controllers.dart';
import 'package:pairra/features/notifications/domain/app_notification.dart';
import 'package:pairra/features/notifications/domain/notification_policy.dart';
import 'package:pairra/features/notifications/domain/notification_preferences.dart';
import 'package:pairra/features/notifications/domain/notification_type.dart';
import 'package:pairra/features/notifications/domain/push_provider.dart';

class _FakePush implements PushProvider {
  int sent = 0;
  @override
  bool get isConnected => true;
  @override
  Future<void> send({required String title, required String body}) async =>
      sent++;
}

DateTime _at(int hour) => DateTime(2026, 1, 1, hour);

void main() {
  group('QuietHours', () {
    const q = QuietHours(); // 22:00–08:00, wraps midnight
    test('wraps past midnight', () {
      expect(q.contains(_at(23)), isTrue);
      expect(q.contains(_at(3)), isTrue);
      expect(q.contains(_at(12)), isFalse);
    });
  });

  group('NotificationPolicy', () {
    const prefs = NotificationPreferences();

    test('safety is always in-app and ignores quiet hours', () {
      final d =
          NotificationPolicy.decide(NotificationType.safetyCheckIn, prefs, _at(23));
      expect(d.inApp, isTrue);
      expect(d.push, isTrue, reason: 'safety bypasses quiet hours');
    });

    test('non-safety holds push during quiet hours but still logs in-app', () {
      final night =
          NotificationPolicy.decide(NotificationType.newMatch, prefs, _at(23));
      expect(night.inApp, isTrue);
      expect(night.push, isFalse);

      final day =
          NotificationPolicy.decide(NotificationType.newMatch, prefs, _at(12));
      expect(day.push, isTrue);
    });

    test('a disabled channel is respected', () {
      final off = prefs.setChannel(
          NotificationCategory.activity, NotificationChannel.push, false);
      final d = NotificationPolicy.decide(NotificationType.like, off, _at(12));
      expect(d.push, isFalse);
      expect(d.inApp, isTrue);
    });
  });

  group('NotificationDispatcher', () {
    test('records in-app and sends push when allowed', () {
      final inbox = NotificationsController();
      final push = _FakePush();
      final dispatcher = NotificationDispatcher(
        inbox: inbox,
        push: push,
        preferences: () => const NotificationPreferences(),
        clock: () => _at(12),
      );
      dispatcher.dispatch(NotificationType.newMatch,
          title: 'New match', body: 'x');
      expect(inbox.state.length, 1);
      expect(push.sent, 1);
    });

    test('throttles excessive marketing notifications', () {
      final inbox = NotificationsController();
      final dispatcher = NotificationDispatcher(
        inbox: inbox,
        push: _FakePush(),
        preferences: () => const NotificationPreferences(),
        clock: () => _at(12),
      );
      dispatcher.dispatch(NotificationType.dateSuggestion, title: 'a', body: 'x');
      dispatcher.dispatch(NotificationType.dateSuggestion, title: 'b', body: 'y');
      expect(inbox.state.length, 1, reason: 'second marketing item suppressed');
    });

    test('safety is delivered even during quiet hours', () {
      final inbox = NotificationsController();
      final push = _FakePush();
      final dispatcher = NotificationDispatcher(
        inbox: inbox,
        push: push,
        preferences: () => const NotificationPreferences(),
        clock: () => _at(23),
      );
      dispatcher.dispatch(NotificationType.safetyCheckIn,
          title: 'Checking in', body: 'x');
      expect(inbox.state.length, 1);
      expect(push.sent, 1);
    });
  });

  group('NotificationsController', () {
    test('tracks unread and marks read', () {
      final c = NotificationsController();
      c.add(AppNotification(
          id: 'a',
          type: NotificationType.newMatch,
          title: 't',
          body: 'b',
          createdAt: DateTime.now()));
      expect(c.unreadCount, 1);
      c.markRead('a');
      expect(c.unreadCount, 0);
    });
  });
}
