/// The ordered onboarding steps (progressive disclosure — one topic per
/// screen). The closing "your profile is ready" screen is handled separately
/// by the flow as a non-data page, so it isn't part of this data-step list.
enum OnboardingStep {
  basics('About you', 'The essentials for your profile.'),
  identity('Identity', 'How you identify and who you\'re into.'),
  intentions('Intentions', 'What you\'re hoping to find.'),
  roles('Compatibility', 'Helps us match you reciprocally.'),
  lookingFor('Looking for', 'What matters in a match.'),
  interests('Interests', 'The things you love.'),
  personality('Personality', 'A few quick vibes — not a test.'),
  datePrefs('First dates', 'How you like to meet.'),
  location('Location', 'To find people near you.'),
  privacy('Privacy', 'You\'re in control of what\'s shared.');

  const OnboardingStep(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
