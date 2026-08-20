import 'package:flutter/foundation.dart';

/// A single supportive safety tip.
@immutable
class SafetyTip {
  const SafetyTip(this.title, this.body);
  final String title;
  final String body;
}

/// A safety article (Before / During / After). Content is data so it can be
/// localized or remotely updated later.
@immutable
class SafetyArticle {
  const SafetyArticle({
    required this.id,
    required this.title,
    required this.intro,
    required this.tips,
  });

  final String id;
  final String title;
  final String intro;
  final List<SafetyTip> tips;
}

/// Static safety guidance. Deliberately warm and reassuring — supportive, not
/// frightening.
abstract final class SafetyContent {
  static const beforeYouMeet = SafetyArticle(
    id: 'before',
    title: 'Before you meet',
    intro: 'A little planning makes a first date feel easy and relaxed.',
    tips: [
      SafetyTip('Meet in public',
          'Pick a busy public place like a café or restaurant for a first date.'),
      SafetyTip('Tell someone your plans',
          'Share who you\'re meeting, where, and when with a friend you trust.'),
      SafetyTip('Keep your own transportation',
          'Arrange your own way there and back so you can leave whenever you like.'),
      SafetyTip('Avoid unfamiliar private locations',
          'Skip private homes or isolated spots for a first meet-up.'),
      SafetyTip('Keep your address private',
          'There\'s no rush — hold off on sharing your home until you trust them.'),
      SafetyTip('Verify who you\'re meeting',
          'A quick video call beforehand is a nice way to confirm it\'s really them.'),
      SafetyTip('Trust your instincts',
          'If something feels off, you don\'t owe anyone an explanation.'),
    ],
  );

  static const duringTheDate = SafetyArticle(
    id: 'during',
    title: 'During the date',
    intro: 'Stay comfortable and in control — you set the pace.',
    tips: [
      SafetyTip('Stay in public',
          'Keep to public, populated places, especially early on.'),
      SafetyTip('Mind your drink',
          'Keep an eye on your drink and don\'t leave it unattended.'),
      SafetyTip('Keep your phone charged',
          'So you can call or check in whenever you want to.'),
      SafetyTip('Check in with your person',
          'A quick text to your trusted contact is all it takes.'),
      SafetyTip('It\'s okay to leave',
          'You can end a date at any time, for any reason. That\'s always fine.'),
    ],
  );

  static const afterTheDate = SafetyArticle(
    id: 'after',
    title: 'After the date',
    intro: 'A few small habits keep things comfortable afterward.',
    tips: [
      SafetyTip('Let your contact know you\'re safe',
          'A quick message closes the loop with whoever you told.'),
      SafetyTip('Take your time',
          'Share more personal details only when you\'re genuinely ready.'),
      SafetyTip('Reflect on how it felt',
          'Notice how you felt around them — that\'s useful information.'),
      SafetyTip('Report anything concerning',
          'If something didn\'t feel right, you can report it — we\'re here for it.'),
    ],
  );

  static const List<SafetyArticle> all = [
    beforeYouMeet,
    duringTheDate,
    afterTheDate,
  ];
}
