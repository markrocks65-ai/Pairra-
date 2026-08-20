import '../../onboarding/domain/onboarding_profile.dart';
import '../domain/compatibility_profile.dart';

/// Adapts the app's [OnboardingProfile] onto the engine's pure
/// [CompatibilityProfile]. This is the only place the two models meet — the
/// engine itself stays decoupled from onboarding/profile internals, so it can
/// be tested and evolved independently.
abstract final class CompatibilityProfileMapper {
  static CompatibilityProfile fromOnboarding(
    OnboardingProfile p, {
    String id = 'self',
  }) {
    final loc = p.location;
    final geo = (loc.approxLat != null && loc.approxLng != null)
        ? GeoApprox(loc.approxLat!, loc.approxLng!)
        : null;

    return CompatibilityProfile(
      id: id,
      roles: p.sexualRoles,
      age: p.age,
      location: geo,
      interests: p.interests,
      lifestyle: CompatibilityLifestyle(
        smoking: p.lifestyle.smoking,
        drinking: p.lifestyle.drinking,
        pets: p.lifestyle.pets,
        children: p.lifestyle.children,
        communicationStyles: p.lifestyle.communicationStyles,
      ),
      personality: p.personality,
      datingIntentions: p.datingIntentions,
      firstDates: p.datePreferences.firstDates,
      budgetId: p.datePreferences.budgetId,
      // Availability isn't collected in onboarding yet — left empty, which the
      // engine treats as "insufficient data" rather than a zero.
      availability: const {},
      preferences: CompatibilityPreferences(
        preferredRoles: p.lookingFor.preferredRoles,
        relationshipTypes: p.lookingFor.relationshipTypes,
        ageMin: p.lookingFor.ageMin,
        ageMax: p.lookingFor.ageMax,
        maxDistanceKm: p.lookingFor.maxDistanceKm,
      ),
      revealRoles: p.visibilityOf('roles') == FieldVisibility.public,
    );
  }
}
