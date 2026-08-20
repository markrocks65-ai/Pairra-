import 'package:flutter/foundation.dart';

import 'option.dart';

/// A named set of sexual-role options that applies to a particular audience.
/// Roles are **configuration, not hard-coded enums** — this is what lets PAIRRA
/// launch with a gay-male role vocabulary while supporting other orientations
/// (and future additions) purely as data.
@immutable
class RoleSet {
  const RoleSet({
    required this.id,
    required this.label,
    required this.roles,
    this.sensitive = true,
  });

  final String id;
  final String label;
  final List<Option> roles;

  /// Sensitive role sets default to non-public visibility in the profile.
  final bool sensitive;
}

/// Central resolver for preference vocabularies. The compatibility engine and
/// onboarding both read from here, so the "shape" of preferences is defined in
/// exactly one place.
///
/// The role vocabulary is chosen by the user's gender + orientation via
/// [roleSetFor]. When no set applies, the roles step is simply skipped — the
/// flow adapts rather than forcing an irrelevant question.
abstract final class PreferenceConfig {
  // --- Role sets (configurable) ---------------------------------------------

  /// The initial gay-male experience vocabulary (per the product brief).
  static const RoleSet gayMaleRoles = RoleSet(
    id: 'masc4masc_positions',
    label: 'Position',
    roles: [
      Option('top', 'Top'),
      Option('bottom', 'Bottom'),
      Option('versatile', 'Versatile'),
      Option('vers_top', 'Vers Top'),
      Option('vers_bottom', 'Vers Bottom'),
      Option('side', 'Side'),
      Option('prefer_not_to_say', 'Prefer not to say'),
    ],
  );

  /// A neutral, orientation-agnostic dynamic set used as a sensible default for
  /// audiences without a bespoke vocabulary yet. Expanded over time as data.
  static const RoleSet genericDynamicsRoles = RoleSet(
    id: 'generic_dynamics',
    label: 'Dynamic',
    roles: [
      Option('dominant', 'Dominant'),
      Option('submissive', 'Submissive'),
      Option('switch', 'Switch'),
      Option('prefer_not_to_say', 'Prefer not to say'),
    ],
  );

  static const List<RoleSet> allRoleSets = [gayMaleRoles, genericDynamicsRoles];

  /// Resolves the applicable [RoleSet] for a user, or `null` when the roles
  /// step should be skipped. Matching is intentionally simple and data-driven;
  /// as new audiences are added this becomes a lookup table / remote config.
  static RoleSet? roleSetFor({String? genderId, String? orientationId}) {
    final masc = genderId == 'man' || genderId == 'trans_man';
    final attractedToMen = orientationId == 'gay' ||
        orientationId == 'bisexual' ||
        orientationId == 'pansexual' ||
        orientationId == 'queer';
    if (masc && attractedToMen) return gayMaleRoles;

    // Everyone else: offer the neutral dynamics set (still optional/skippable),
    // rather than assuming or hiding. Returning null here instead would skip
    // the step entirely — a product choice we can flip via config.
    return genericDynamicsRoles;
  }

  // --- Identity vocabularies (never assume) ---------------------------------

  /// Gender identities. Open list + a self-describe entry keep this inclusive.
  static const List<Option> genderIdentities = [
    Option('man', 'Man'),
    Option('woman', 'Woman'),
    Option('non_binary', 'Non-binary'),
    Option('trans_man', 'Trans man'),
    Option('trans_woman', 'Trans woman'),
    Option('genderqueer', 'Genderqueer'),
    Option('agender', 'Agender'),
    Option('self_describe', 'Prefer to self-describe'),
  ];

  /// Sexual orientations. Deliberately does not assume a default.
  static const List<Option> orientations = [
    Option('gay', 'Gay'),
    Option('straight', 'Straight'),
    Option('bisexual', 'Bisexual'),
    Option('pansexual', 'Pansexual'),
    Option('queer', 'Queer'),
    Option('asexual', 'Asexual'),
    Option('questioning', 'Questioning'),
    Option('self_describe', 'Prefer to self-describe'),
  ];
}
