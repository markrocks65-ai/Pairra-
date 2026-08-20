import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A coarse location. PAIRRA only ever works with approximate positions; this
/// carries no more precision than a general area and is used solely to compute
/// an approximate distance — never exposed as coordinates.
@immutable
class GeoApprox {
  const GeoApprox(this.lat, this.lng);

  final double lat;
  final double lng;

  /// Great-circle distance in kilometers (haversine).
  double distanceKmTo(GeoApprox other) {
    const earthKm = 6371.0;
    double rad(double d) => d * math.pi / 180.0;
    final dLat = rad(other.lat - lat);
    final dLng = rad(other.lng - lng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat)) *
            math.cos(rad(other.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

/// Self lifestyle attributes relevant to compatibility.
@immutable
class CompatibilityLifestyle {
  const CompatibilityLifestyle({
    this.smoking,
    this.drinking,
    this.pets,
    this.children,
    this.communicationStyles = const {},
  });

  final String? smoking;
  final String? drinking;
  final String? pets;
  final String? children;
  final Set<String> communicationStyles;
}

/// The "what I'm looking for" half of a profile — the preferences the OTHER
/// person is scored against. Kept separate from self attributes so reciprocal
/// scoring (does A fit B's prefs AND B fit A's prefs) is explicit.
@immutable
class CompatibilityPreferences {
  const CompatibilityPreferences({
    this.preferredRoles = const {},
    this.relationshipTypes = const {},
    this.ageMin = 18,
    this.ageMax = 99,
    this.maxDistanceKm = 80,
  });

  final Set<String> preferredRoles;
  final Set<String> relationshipTypes;
  final int ageMin;
  final int ageMax;
  final double maxDistanceKm;
}

/// The engine's input: everything (and only what) the compatibility algorithm
/// needs about one user. Deliberately decoupled from the onboarding/profile
/// models so the algorithm is pure and independently testable; an adapter maps
/// the app's profile onto this shape.
@immutable
class CompatibilityProfile {
  const CompatibilityProfile({
    this.id = 'anon',
    this.roles = const {},
    this.age,
    this.location,
    this.interests = const {},
    this.lifestyle = const CompatibilityLifestyle(),
    this.personality = const {},
    this.datingIntentions = const {},
    this.firstDates = const {},
    this.budgetId,
    this.availability = const {},
    this.preferences = const CompatibilityPreferences(),
    this.revealRoles = false,
  });

  /// Opaque id for reference/logging. Never surfaced in results.
  final String id;

  // --- Self ---
  final Set<String> roles;
  final int? age;
  final GeoApprox? location;
  final Set<String> interests;
  final CompatibilityLifestyle lifestyle;
  final Map<String, String> personality;
  final Set<String> datingIntentions;
  final Set<String> firstDates;
  final String? budgetId;

  /// Availability windows (e.g. 'weekday_evenings', 'weekends'). Optional.
  final Set<String> availability;

  // --- Preferences (the other person is scored against these) ---
  final CompatibilityPreferences preferences;

  /// Whether this user has opted to reveal detailed role info. The engine never
  /// exposes specifics regardless; this exists for a future "both revealed"
  /// product surface.
  final bool revealRoles;
}
