import '../domain/ai_models.dart';
import '../domain/ai_provider.dart';
import '../domain/ai_task.dart';

/// The default assistant: a local, deterministic template engine. It is a
/// genuine helper (not a stub) that runs offline with no external model, and by
/// construction can only use the sanitized inputs it's given — so it never
/// leaks private data, never claims to be human, and never guarantees outcomes.
/// Swap for a model-backed [AiProvider] for richer help.
class LocalAiProvider implements AiProvider {
  const LocalAiProvider();

  @override
  String get name => 'On-device assistant';

  @override
  bool get isModelBacked => false;

  @override
  Future<AiResponse> complete(AiRequest request) async {
    return switch (request.task) {
      AiTask.conversationStarters => _starters(request),
      AiTask.profileImprovement => _profile(request),
      AiTask.dateIdeas ||
      AiTask.firstDateSuggestions =>
        _dateIdeas(request),
      AiTask.datePlanning => _datePlanning(request),
      AiTask.relationshipCommunication => _communication(),
      AiTask.messageDrafting => _reply(request),
      AiTask.compatibilityExplanation => _compatibility(request),
    };
  }

  static String _label(String id) => id.split('_').join(' ');

  AiResponse _starters(AiRequest r) {
    final shared = r.sharedInterests.toList();
    if (shared.isNotEmpty) {
      return AiResponse(
        intro: 'A few openers based on what you have in common:',
        suggestions: [
          for (final id in shared.take(3))
            AiSuggestion('You both like ${_label(id)} — what got you into it?'),
        ],
      );
    }
    return const AiResponse(
      intro: 'A few easy openers to break the ice:',
      suggestions: [
        AiSuggestion('What\'s been the best part of your week?'),
        AiSuggestion('Coffee person or something stronger?'),
        AiSuggestion('What\'s something you could talk about for hours?'),
      ],
    );
  }

  AiResponse _profile(AiRequest r) {
    final photos = r.profileHints['photos'] ?? 0;
    final bio = r.profileHints['bioLength'] ?? 0;
    final interests = r.profileHints['interests'] ?? 0;
    final intentions = r.profileHints['intentions'] ?? 0;

    final tips = <String>[
      if (photos < 2)
        'Add a couple more photos — a clear face photo plus one that shows a hobby works well.',
      if (bio == 0)
        'Write a short bio. Even one genuine line about what you enjoy helps a lot.'
      else if (bio < 40)
        'Your bio is brief — try adding a hobby or what you\'re looking for.',
      if (interests < 3)
        'Add a few more interests so we can find people you\'ll click with.',
      if (intentions == 0)
        'Set your dating intention so matches know what you\'re after.',
    ];
    if (tips.isEmpty) {
      tips.add(
          'Your profile looks solid. Refreshing a photo now and then keeps it lively.');
    }
    return AiResponse(
      intro: 'Here\'s how to make your profile shine:',
      suggestions: [for (final t in tips) AiSuggestion(t, copyable: false)],
    );
  }

  AiResponse _dateIdeas(AiRequest r) {
    if (r.venueLines.isNotEmpty) {
      return AiResponse(
        intro: 'A few nearby date ideas:',
        suggestions: [
          for (final line in r.venueLines.take(4))
            AiSuggestion(line, copyable: false),
        ],
      );
    }
    return const AiResponse(
      intro: 'A few relaxed first-date ideas:',
      suggestions: [
        AiSuggestion('Grab a coffee somewhere low-key.', copyable: false),
        AiSuggestion('Take a walk somewhere green.', copyable: false),
        AiSuggestion('Try a light activity like mini golf.', copyable: false),
      ],
    );
  }

  AiResponse _datePlanning(AiRequest r) {
    final v = r.venueLines;
    if (v.length >= 2) {
      return AiResponse(
        intro: 'Here\'s a simple plan you could build on:',
        suggestions: [
          AiSuggestion(
              'Start with ${v[0]}, then head to ${v[1]}${v.length > 2 ? ', and finish at ${v[2]}' : ''}.',
              copyable: false),
        ],
      );
    }
    return _dateIdeas(r);
  }

  AiResponse _communication() {
    return const AiResponse(
      intro: 'A few gentle communication tips:',
      suggestions: [
        AiSuggestion('Be clear and kind about what you\'re looking for.',
            copyable: false),
        AiSuggestion('Ask questions and really listen to the answers.',
            copyable: false),
        AiSuggestion('Respect boundaries — yours and theirs.', copyable: false),
        AiSuggestion(
            'If plans change, a quick honest message goes a long way.',
            copyable: false),
      ],
    );
  }

  AiResponse _reply(AiRequest r) {
    final incoming = (r.userText ?? '').trim();
    if (incoming.isEmpty) {
      return const AiResponse(
        intro:
            'Paste the message you\'d like to reply to and I\'ll suggest a few responses.',
      );
    }
    return const AiResponse(
      intro:
          'Here are a few ways you could reply — pick one, make it yours, and send it yourself:',
      suggestions: [
        AiSuggestion('I love that — tell me more!'),
        AiSuggestion('That\'s really interesting. What got you into it?'),
        AiSuggestion('Okay, now you have to tell me the whole story 😄'),
      ],
    );
  }

  AiResponse _compatibility(AiRequest r) {
    if (r.compatibilityReasons.isEmpty) {
      return const AiResponse(
        intro: 'You\'ve got a few things in common — worth exploring in person.',
      );
    }
    return AiResponse(
      intro: 'Here\'s why you two could click:',
      suggestions: [
        for (final reason in r.compatibilityReasons)
          AiSuggestion(reason, copyable: false),
      ],
    );
  }
}
