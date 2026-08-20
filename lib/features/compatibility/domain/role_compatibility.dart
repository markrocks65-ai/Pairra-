import 'dart:math' as math;

/// Canonical role ids (mirrors the gay-male role vocabulary in
/// PreferenceConfig). The matrix below is intentionally isolated and pure so
/// the reciprocal sexual-role logic can be unit-tested directly.
abstract final class RoleIds {
  static const top = 'top';
  static const bottom = 'bottom';
  static const versatile = 'versatile';
  static const versTop = 'vers_top';
  static const versBottom = 'vers_bottom';
  static const side = 'side';
  static const preferNotToSay = 'prefer_not_to_say';

  static const known = {top, bottom, versatile, versTop, versBottom, side};
}

/// Pure reciprocal sexual-role compatibility.
///
/// Two ingredients, deliberately kept apart because "role alone" must NOT
/// decide compatibility:
///  1. [intrinsicRoleScore] — how well the two role sets physically pair
///     (Top+Bottom high, Top+Top low, Vers flexible, Side+Side moderate).
///  2. [preferenceSatisfaction] — reciprocal: does each person's role fall in
///     the other's *preferred* roles.
///
/// The service blends the two, so a great physical pairing with mismatched
/// stated preferences still scores lower.
abstract final class RoleCompatibility {
  /// Symmetric base affinity for a single role pair, 0..1. Unknown pairs fall
  /// back to a neutral-low value.
  static double pairAffinity(String a, String b) {
    final key = ([a, b]..sort()).join('|');
    return _matrix[key] ?? 0.3;
  }

  static final Map<String, double> _matrix = {
    _k(RoleIds.top, RoleIds.bottom): 1.00,
    _k(RoleIds.top, RoleIds.versBottom): 0.95,
    _k(RoleIds.bottom, RoleIds.versTop): 0.95,
    _k(RoleIds.top, RoleIds.versatile): 0.85,
    _k(RoleIds.bottom, RoleIds.versatile): 0.85,
    _k(RoleIds.versatile, RoleIds.versTop): 0.85,
    _k(RoleIds.versatile, RoleIds.versBottom): 0.85,
    _k(RoleIds.versTop, RoleIds.versBottom): 0.92,
    _k(RoleIds.versatile, RoleIds.versatile): 0.90,
    _k(RoleIds.side, RoleIds.side): 0.60,
    _k(RoleIds.top, RoleIds.versTop): 0.45,
    _k(RoleIds.bottom, RoleIds.versBottom): 0.45,
    _k(RoleIds.versTop, RoleIds.versTop): 0.40,
    _k(RoleIds.versBottom, RoleIds.versBottom): 0.40,
    _k(RoleIds.side, RoleIds.versatile): 0.30,
    _k(RoleIds.side, RoleIds.top): 0.20,
    _k(RoleIds.side, RoleIds.bottom): 0.20,
    _k(RoleIds.side, RoleIds.versTop): 0.22,
    _k(RoleIds.side, RoleIds.versBottom): 0.22,
    _k(RoleIds.top, RoleIds.top): 0.10,
    _k(RoleIds.bottom, RoleIds.bottom): 0.10,
  };

  static String _k(String a, String b) => ([a, b]..sort()).join('|');

  static Set<String> _knownOnly(Set<String> roles) =>
      roles.where(RoleIds.known.contains).toSet();

  /// Best physical pairing across the two role sets, or `null` when either side
  /// has no usable role (unknown / "prefer not to say") — signalling the sexual
  /// category has insufficient data rather than a low score.
  static double? intrinsicRoleScore(Set<String> aRoles, Set<String> bRoles) {
    final a = _knownOnly(aRoles);
    final b = _knownOnly(bRoles);
    if (a.isEmpty || b.isEmpty) return null;
    var best = 0.0;
    for (final ra in a) {
      for (final rb in b) {
        final v = pairAffinity(ra, rb);
        if (v > best) best = v;
      }
    }
    return best;
  }

  /// How well [roles] satisfy [preferred]. Empty preferences = open = 1.0.
  static double _covers(Set<String> preferred, Set<String> roles) {
    if (preferred.isEmpty) return 1.0;
    final known = _knownOnly(roles);
    if (known.isEmpty) return 1.0; // nothing to judge against → don't penalize
    final hit = known.where(preferred.contains).length;
    return hit / known.length;
  }

  /// Reciprocal preference satisfaction: BOTH people's stated role preferences
  /// must be met, so we take the weaker of the two directions.
  static double preferenceSatisfaction(
    Set<String> aRoles,
    Set<String> bRoles,
    Set<String> aPreferredRoles,
    Set<String> bPreferredRoles,
  ) {
    final aWantsB = _covers(aPreferredRoles, bRoles);
    final bWantsA = _covers(bPreferredRoles, aRoles);
    return math.min(aWantsB, bWantsA);
  }
}
