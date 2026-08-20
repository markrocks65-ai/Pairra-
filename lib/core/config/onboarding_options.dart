import 'package:flutter/foundation.dart';

import 'option.dart';

/// All selectable option lists used across onboarding, centralized as data.
/// UI never hard-codes these — it renders whatever the config provides, so the
/// product can evolve the questions without code changes.
abstract final class OnboardingOptions {
  // Step 3 — dating intentions (multi-select allowed).
  static const List<Option> datingIntentions = [
    Option('long_term', 'Long-term relationship'),
    Option('short_term', 'Short-term dating'),
    Option('casual', 'Casual dating'),
    Option('friends_first', 'Friends first'),
    Option('open', 'Open to seeing where it goes'),
  ];

  // Step 5 — relationship types the user is looking for.
  static const List<Option> relationshipTypes = [
    Option('monogamous', 'Monogamous'),
    Option('non_monogamous', 'Non-monogamous'),
    Option('open', 'Open'),
    Option('undecided', 'Still figuring it out'),
  ];

  // Step 5 — lifestyle (self-attributes, used bidirectionally in matching).
  static const List<Option> smoking = [
    Option('no', 'Non-smoker'),
    Option('sometimes', 'Sometimes'),
    Option('yes', 'Smoker'),
    Option('prefer_not_to_say', 'Prefer not to say'),
  ];

  static const List<Option> drinking = [
    Option('no', 'Don\'t drink'),
    Option('socially', 'Socially'),
    Option('regularly', 'Regularly'),
    Option('prefer_not_to_say', 'Prefer not to say'),
  ];

  static const List<Option> pets = [
    Option('have', 'Have pets'),
    Option('love', 'Love them'),
    Option('none', 'No pets'),
    Option('allergic', 'Allergic'),
  ];

  static const List<Option> children = [
    Option('have', 'Have children'),
    Option('want', 'Want someday'),
    Option('dont_want', 'Don\'t want'),
    Option('open', 'Open to it'),
  ];

  static const List<Option> communicationStyles = [
    Option('texter', 'Texter'),
    Option('caller', 'Prefer calls'),
    Option('in_person', 'In-person person'),
    Option('slow_burn', 'Slow and steady'),
    Option('quick_replies', 'Quick replies'),
  ];

  // Step 6 — interests.
  static const List<Option> interests = [
    Option('fitness', 'Fitness'),
    Option('travel', 'Travel'),
    Option('movies', 'Movies'),
    Option('music', 'Music'),
    Option('gaming', 'Gaming'),
    Option('food', 'Food'),
    Option('cooking', 'Cooking'),
    Option('sports', 'Sports'),
    Option('art', 'Art'),
    Option('books', 'Books'),
    Option('outdoors', 'Outdoors'),
    Option('nightlife', 'Nightlife'),
    Option('technology', 'Technology'),
    Option('pets', 'Pets'),
    Option('fashion', 'Fashion'),
    Option('photography', 'Photography'),
    Option('coffee', 'Coffee'),
    Option('wellness', 'Wellness'),
  ];

  // Step 8 — ideal first dates (multi-select).
  static const List<Option> firstDates = [
    Option('dinner', 'Dinner'),
    Option('coffee', 'Coffee'),
    Option('drinks', 'Drinks'),
    Option('movie', 'Movie'),
    Option('walk', 'Walk'),
    Option('park', 'Park'),
    Option('activity', 'Activity'),
    Option('concert', 'Concert'),
    Option('museum', 'Museum'),
    Option('casual', 'Something casual'),
    Option('adventurous', 'Something adventurous'),
  ];

  // Step 8 — budget preference.
  static const List<Option> budgets = [
    Option('1', '\$', description: 'Low-key'),
    Option('2', '\$\$', description: 'Moderate'),
    Option('3', '\$\$\$', description: 'Nice'),
    Option('4', '\$\$\$\$', description: 'Fancy'),
  ];
}

/// A lightweight personality question. Answers are just compatibility
/// *signals* — never a diagnosis. Each question is a simple either/or spectrum;
/// we store which pole the user leans toward.
@immutable
class PersonalityQuestion {
  const PersonalityQuestion({
    required this.id,
    required this.prompt,
    required this.options,
  });

  final String id;
  final String prompt;

  /// Two (occasionally three) poles. Stored by option id.
  final List<Option> options;
}

/// Step 7 — personality signals. Deliberately playful and non-clinical.
abstract final class PersonalityConfig {
  static const List<PersonalityQuestion> questions = [
    PersonalityQuestion(
      id: 'social_energy',
      prompt: 'After a long week, you\'d rather…',
      options: [
        Option('introvert', 'Cozy night in'),
        Option('extrovert', 'Go out and socialize'),
      ],
    ),
    PersonalityQuestion(
      id: 'planning',
      prompt: 'Your ideal plans are…',
      options: [
        Option('planner', 'Planned ahead'),
        Option('spontaneous', 'Spontaneous'),
      ],
    ),
    PersonalityQuestion(
      id: 'pace',
      prompt: 'When it comes to dating, you tend to…',
      options: [
        Option('slow', 'Take it slow'),
        Option('dive_in', 'Dive right in'),
      ],
    ),
    PersonalityQuestion(
      id: 'weekend',
      prompt: 'A perfect weekend leans more…',
      options: [
        Option('homebody', 'Homebody'),
        Option('adventurer', 'Adventurer'),
      ],
    ),
  ];
}
