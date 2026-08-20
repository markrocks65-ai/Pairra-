/// The weighted dimensions PAIRRA scores compatibility across. Each is scored
/// independently (and reciprocally, where direction matters) and then combined
/// using configurable [CompatibilityWeights].
///
/// [sensitive] categories (sexual compatibility) are never surfaced with
/// specifics — only a band/percentage — so another user's private preferences
/// are never exposed.
enum CompatibilityCategory {
  sexual('Sexual compatibility', sensitive: true),
  relationshipIntent('Relationship goals'),
  datingPreferences('Dating preferences'),
  agePreference('Age fit'),
  distance('Distance'),
  interests('Interests'),
  lifestyle('Lifestyle'),
  communication('Communication'),
  personality('Personality'),
  availability('Availability');

  const CompatibilityCategory(this.label, {this.sensitive = false});

  final String label;
  final bool sensitive;
}
