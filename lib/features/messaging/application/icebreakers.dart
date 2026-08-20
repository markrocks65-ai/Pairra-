import 'package:flutter/foundation.dart';

/// A suggested opener: a [reason] (shared interest) and a [suggestion] the user
/// can choose to send. Suggestions are ALWAYS presented as optional prompts the
/// user taps and edits — never auto-sent, and never shown as if the other
/// person (or the app) sent them.
@immutable
class Icebreaker {
  const Icebreaker({required this.reason, required this.suggestion});

  final String reason;
  final String suggestion;
}

/// Generates conversation starters from interests the two people share. Pure
/// and deterministic, so it's easy to test.
abstract final class Icebreakers {
  static const _prompts = <String, String>{
    'fitness': 'What\'s your go-to workout?',
    'travel': 'Where\'s the best place you\'ve traveled?',
    'movies': 'Seen anything great lately?',
    'music': 'What have you had on repeat lately?',
    'gaming': 'What are you playing right now?',
    'food': 'Best meal you\'ve had recently?',
    'cooking': 'What\'s your signature dish?',
    'sports': 'Do you play or just watch?',
    'art': 'Been to any good shows lately?',
    'books': 'What are you reading right now?',
    'outdoors': 'What\'s your favorite spot to get outside?',
    'nightlife': 'Where\'s your go-to spot for a night out?',
    'technology': 'What are you geeking out over lately?',
    'pets': 'Tell me about your pet.',
    'fashion': 'Where do you find your style?',
    'photography': 'What do you love to shoot?',
    'coffee': 'What\'s the best coffee near you?',
    'wellness': 'What\'s your favorite way to unwind?',
  };

  static String _label(String id) => id.split('_').join(' ');

  static List<Icebreaker> suggest(
    Set<String> selfInterests,
    Set<String> otherInterests, {
    int max = 3,
  }) {
    final shared = selfInterests.intersection(otherInterests).toList();
    final out = <Icebreaker>[];
    for (final id in shared) {
      out.add(Icebreaker(
        reason: 'You both like ${_label(id)}.',
        suggestion: _prompts[id] ?? 'What got you into ${_label(id)}?',
      ));
      if (out.length >= max) break;
    }
    return out;
  }
}
