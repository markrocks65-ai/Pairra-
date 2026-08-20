import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/discovery/application/matches_controller.dart';
import 'package:pairra/features/discovery/data/noop_matches_repository.dart';
import 'package:pairra/features/messaging/data/in_memory_messaging_repository.dart';
import 'package:pairra/features/discovery/domain/match.dart';
import 'package:pairra/features/messaging/application/icebreakers.dart';
import 'package:pairra/features/messaging/application/messaging_controller.dart';
import 'package:pairra/features/onboarding/domain/onboarding_profile.dart';

Match _match(String id, {String name = 'Alex', Set<String> interests = const {}}) =>
    Match(
      id: id,
      profile: OnboardingProfile(displayName: name, interests: interests),
      compatibilityPercent: 90,
      matchedAt: DateTime.now(),
    );

void main() {
  group('Icebreakers', () {
    test('suggests only shared interests, framed and capped', () {
      final out = Icebreakers.suggest(
          {'fitness', 'travel', 'coffee'}, {'travel', 'music', 'coffee'});
      expect(out.length, 2, reason: 'travel + coffee are shared');
      expect(out.first.reason.toLowerCase(), contains('travel'));
      expect(out.first.suggestion, isNotEmpty);

      expect(
        Icebreakers.suggest({'a', 'b', 'c'}, {'a', 'b', 'c'}, max: 2).length,
        2,
      );
    });

    test('no shared interests → no suggestions', () {
      expect(Icebreakers.suggest({'fitness'}, {'art'}), isEmpty);
    });
  });

  group('MessagingController', () {
    MessagingController make() =>
        MessagingController(InMemoryMessagingRepository());
    Future<void> pump() => Future<void>.delayed(Duration.zero);

    test('sync creates a conversation seeded with one system safety note', () {
      final c = make();
      c.syncMatches([_match('m1', name: 'Sam')]);

      final convo = c.state.conversation('m1');
      expect(convo, isNotNull);
      final msgs = c.state.messagesFor('m1');
      expect(msgs.length, 1);
      expect(msgs.single.isSystem, isTrue);
      expect(msgs.single.text, contains('public place'));
      expect(c.state.isFresh('m1'), isTrue);
    });

    test('sendText streams my message onto the thread (trimmed)', () async {
      final c = make();
      c.syncMatches([_match('m1')]);
      c.openConversation('m1');
      await c.sendText('m1', '  hi there  ');
      await pump();

      final msgs = c.state.messagesFor('m1');
      expect(msgs.length, 2);
      expect(msgs.last.isMine, isTrue);
      expect(msgs.last.text, 'hi there', reason: 'trimmed');
      expect(c.state.isFresh('m1'), isFalse);
      expect(c.state.conversation('m1')!.lastMessage!.text, 'hi there');
    });

    test('sync is idempotent for an existing conversation', () async {
      final c = make();
      c.syncMatches([_match('m1')]);
      c.openConversation('m1');
      await c.sendText('m1', 'hey');
      await pump();
      c.syncMatches([_match('m1')]); // matches list re-emitted
      expect(c.state.messagesFor('m1').length, 2);
    });

    test('empty text is ignored', () async {
      final c = make();
      c.syncMatches([_match('m1')]);
      c.openConversation('m1');
      await c.sendText('m1', '   ');
      await pump();
      expect(c.state.messagesFor('m1').length, 1);
    });

    test('removeConversation clears it', () {
      final c = make();
      c.syncMatches([_match('m1')]);
      c.removeConversation('m1');
      expect(c.state.conversation('m1'), isNull);
      expect(c.state.messagesFor('m1'), isEmpty);
    });
  });

  test('MatchesController.remove drops the match', () {
    final matches = MatchesController(const NoopMatchesRepository());
    matches.add(_match('m1'));
    matches.add(_match('m2'));
    matches.remove('m1');
    expect(matches.state.map((m) => m.id), ['m2']);
  });
}
