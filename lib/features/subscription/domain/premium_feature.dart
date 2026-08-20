/// PAIRRA Premium features. Titles/descriptions are honest about what you get —
/// never a promise of finding love.
enum PremiumFeature {
  unlimitedLikes('Unlimited likes', 'Like as many people as you want.'),
  advancedFilters(
      'Advanced compatibility filters', 'Filter by what matters most to you.'),
  compatibilityBreakdown('Detailed compatibility breakdown',
      'See the full reasoning behind every match.'),
  advancedDiscovery('Advanced discovery', 'Fine-tune who you see and when.'),
  incognito(
      'Incognito mode', 'Browse privately — appear only to people you like.'),
  travelMode('Travel mode', 'Start matching in a city before you arrive.'),
  boost('Profile boost', 'Be seen by more people for a set time.'),
  advancedDatePlanning(
      'Advanced date planning', 'Smarter itineraries and more options.'),
  aiAssistant('AI dating assistant', 'Personalized suggestions and openers.'),
  moreDateRecommendations(
      'More date recommendations', 'A wider set of curated places.'),
  readReceipts('Read receipts', 'Know when your messages have been read.'),
  profileAnalytics('Profile analytics', 'See how your profile is performing.');

  const PremiumFeature(this.title, this.description);
  final String title;
  final String description;
}

/// Meaningful things every user gets for free — including, always, the full set
/// of safety tools. Safety is NEVER paywalled.
abstract final class FreeFeatures {
  static const List<String> items = [
    'Create your full profile',
    'Discover compatible people',
    'Core compatibility scoring',
    'A daily set of likes',
    'Message your matches',
    'Plan dates and save places',
    'All safety tools',
    'Blocking & reporting',
  ];
}
