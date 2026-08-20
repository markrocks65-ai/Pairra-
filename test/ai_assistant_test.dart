import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/features/ai_assistant/data/local_ai_provider.dart';
import 'package:pairra/features/ai_assistant/domain/ai_guardrails.dart';
import 'package:pairra/features/ai_assistant/domain/ai_models.dart';
import 'package:pairra/features/ai_assistant/domain/ai_task.dart';

const _p = LocalAiProvider();

void main() {
  test('local provider is honest about being non-model-backed', () {
    expect(_p.isModelBacked, isFalse);
    expect(_p.name.isNotEmpty, isTrue);
  });

  group('Guardrails', () {
    test('disclaimer states it is an AI, not a person', () {
      expect(AiGuardrails.disclaimer.toLowerCase(), contains('not a person'));
      expect(AiGuardrails.disclaimer.toLowerCase(), contains('ai'));
    });

    test('system prompt forbids the key behaviours', () {
      final p = AiGuardrails.systemPrompt.toLowerCase();
      expect(p, contains('pretend to be a human'));
      expect(p, contains('medical'));
      expect(p, contains('guarantee'));
      expect(p, contains('private information about another user'));
      expect(p, contains('sensitive preferences'));
    });
  });

  group('LocalAiProvider tasks', () {
    test('conversation starters use shared interests when available', () async {
      final r = await _p.complete(const AiRequest(
          task: AiTask.conversationStarters,
          sharedInterests: {'fitness', 'travel'}));
      expect(r.suggestions, isNotEmpty);
      expect(r.suggestions.first.text.toLowerCase(), contains('fitness'));
    });

    test('profile improvement gives actionable tips for a sparse profile',
        () async {
      final r = await _p.complete(const AiRequest(
        task: AiTask.profileImprovement,
        profileHints: {'photos': 0, 'bioLength': 0, 'interests': 0},
      ));
      expect(r.suggestions.length, greaterThanOrEqualTo(3));
    });

    test('date ideas use real (provided) venue data', () async {
      final r = await _p.complete(const AiRequest(
        task: AiTask.dateIdeas,
        venueLines: ['The Corner Bistro · Restaurant · \$45–\$65 for two'],
      ));
      expect(r.suggestions.single.text, contains('Corner Bistro'));
    });

    test('reply drafting returns copyable suggestions the user sends', () async {
      final r = await _p.complete(
          const AiRequest(task: AiTask.messageDrafting, userText: 'hey!'));
      expect(r.suggestions, isNotEmpty);
      expect(r.suggestions.every((s) => s.copyable), isTrue);

      final empty =
          await _p.complete(const AiRequest(task: AiTask.messageDrafting));
      expect(empty.suggestions, isEmpty);
    });

    test('compatibility explanation only echoes safe reasons, no roles',
        () async {
      final r = await _p.complete(const AiRequest(
        task: AiTask.compatibilityExplanation,
        compatibilityReasons: [
          'Relationship goals align',
          'Strong preference compatibility',
        ],
      ));
      final all = ([r.intro, ...r.suggestions.map((s) => s.text)].join(' '))
          .toLowerCase();
      for (final banned in ['bottom', 'versatile', ' top', 'side']) {
        expect(all.contains(banned), isFalse);
      }
    });

    test('communication tips make no guarantees or medical claims', () async {
      final r =
          await _p.complete(const AiRequest(task: AiTask.relationshipCommunication));
      final all = [r.intro, ...r.suggestions.map((s) => s.text)]
          .join(' ')
          .toLowerCase();
      expect(r.suggestions, isNotEmpty);
      for (final banned in ['guarantee', 'cure', 'diagnos', 'you\'ll find love']) {
        expect(all.contains(banned), isFalse);
      }
    });
  });
}
