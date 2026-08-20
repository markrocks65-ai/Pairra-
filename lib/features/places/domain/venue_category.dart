/// Categories of public venue PAIRRA can surface for dates. Deliberately a
/// consolidated, provider-agnostic set — concrete providers (Google Places,
/// Foursquare, Yelp) map their own taxonomies onto these. There is no private
/// residence category: date suggestions are always public places.
enum VenueCategory {
  restaurant('Restaurant'),
  coffee('Coffee'),
  movie('Movie'),
  park('Park'),
  museum('Museum'),
  activity('Activity'),
  entertainment('Entertainment'),
  nightlife('Nightlife'),
  event('Event');

  const VenueCategory(this.label);
  final String label;
}
