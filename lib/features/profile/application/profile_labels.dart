import '../../../core/config/onboarding_options.dart';
import '../../../core/config/option.dart';
import '../../../core/config/preference_config.dart';
import '../../onboarding/domain/onboarding_profile.dart';

/// Turns stored option ids back into human-readable labels for display. Keeps
/// all id→label lookups in one place so the profile view never guesses.
abstract final class ProfileLabels {
  static String? single(List<Option> options, String? id) {
    if (id == null) return null;
    for (final o in options) {
      if (o.id == id) return o.label;
    }
    return null;
  }

  static List<String> many(List<Option> options, Set<String> ids) {
    return [
      for (final o in options)
        if (ids.contains(o.id)) o.label,
    ];
  }

  static List<String> intentions(Set<String> ids) =>
      many(OnboardingOptions.datingIntentions, ids);

  static List<String> interests(Set<String> ids) =>
      many(OnboardingOptions.interests, ids);

  static List<String> relationshipTypes(Set<String> ids) =>
      many(OnboardingOptions.relationshipTypes, ids);

  static List<String> firstDates(Set<String> ids) =>
      many(OnboardingOptions.firstDates, ids);

  static String? smoking(String? id) => single(OnboardingOptions.smoking, id);
  static String? drinking(String? id) => single(OnboardingOptions.drinking, id);
  static String? pets(String? id) => single(OnboardingOptions.pets, id);
  static String? children(String? id) => single(OnboardingOptions.children, id);
  static String? budget(String? id) => single(OnboardingOptions.budgets, id);

  /// Resolves the role vocabulary that applies to this profile — prefers the
  /// set actually used (stored [roleSetId]), else derives from gender +
  /// orientation.
  static RoleSet? roleSet(OnboardingProfile p) {
    if (p.roleSetId != null) {
      for (final set in PreferenceConfig.allRoleSets) {
        if (set.id == p.roleSetId) return set;
      }
    }
    return PreferenceConfig.roleSetFor(
      genderId: p.genderId,
      orientationId: p.orientationId,
    );
  }

  static List<String> roleLabels(OnboardingProfile p, Set<String> ids) {
    final set = roleSet(p);
    if (set == null) return const [];
    return many(set.roles, ids);
  }

  static String? gender(OnboardingProfile p) {
    if (p.genderId == 'self_describe' && (p.genderCustom ?? '').isNotEmpty) {
      return p.genderCustom;
    }
    return single(PreferenceConfig.genderIdentities, p.genderId);
  }

  static String? orientation(OnboardingProfile p) {
    if (p.orientationId == 'self_describe' &&
        (p.orientationCustom ?? '').isNotEmpty) {
      return p.orientationCustom;
    }
    return single(PreferenceConfig.orientations, p.orientationId);
  }
}
