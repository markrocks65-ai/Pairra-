import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/safety/application/safety_controllers.dart';
import 'package:pairra/features/safety/application/safety_plan_controller.dart';
import 'package:pairra/features/safety/domain/report.dart';
import 'package:pairra/features/safety/domain/safety_plan.dart';

SafetyPlan _plan({bool checkIn = true}) {
  final t = DateTime.now().add(const Duration(hours: 1));
  return SafetyPlan(
    id: 'p1',
    meetingName: 'Alex',
    place: 'Cafe',
    time: t,
    createdAt: DateTime.now(),
    checkInEnabled: checkIn,
    checkInAt: checkIn ? t.add(const Duration(hours: 2)) : null,
  );
}

void main() {
  group('BlockedProfilesController', () {
    test('blocks immediately, keeps a name, and unblocks', () {
      final c = BlockedProfilesController();
      c.block('u1', name: 'Alex');
      expect(c.isBlocked('u1'), isTrue);
      expect(c.state.single.displayName, 'Alex');

      c.block('u1'); // dup ignored
      expect(c.state.length, 1);

      c.unblock('u1');
      expect(c.isBlocked('u1'), isFalse);
    });

    test('missing name shows a friendly fallback', () {
      final c = BlockedProfilesController();
      c.block('u2');
      expect(c.state.single.displayName, 'Blocked user');
    });
  });

  test('ReportReason covers the required moderation categories', () {
    expect(ReportReason.values.map((r) => r.name), containsAll(<String>[
      'harassment',
      'threats',
      'spam',
      'scam',
      'impersonation',
      'underageUser',
      'nonConsensualContent',
      'hateSpeech',
      'other',
    ]));
  });

  group('SafetyPlansController', () {
    test('active plan with check-in is pending until marked safe', () {
      final c = SafetyPlansController();
      c.add(_plan());
      expect(c.active.length, 1);
      expect(c.pendingCheckIns.length, 1);

      c.markSafe('p1');
      expect(c.active, isEmpty);
      expect(c.pendingCheckIns, isEmpty);
      expect(c.state.single.status, SafetyPlanStatus.completed);
    });

    test('a plan without check-in is active but not pending', () {
      final c = SafetyPlansController();
      c.add(_plan(checkIn: false));
      expect(c.active.length, 1);
      expect(c.pendingCheckIns, isEmpty);
    });
  });
}
