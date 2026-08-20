import 'package:flutter/foundation.dart';

import '../../../core/models/profile_photo.dart';
import '../../../core/models/verification.dart';

/// How visible a single profile field is to others. Sensitive fields default
/// to [matchesOnly] or [private] so nothing sensitive is exposed by default.
enum FieldVisibility {
  public('Everyone'),
  matchesOnly('Matches only'),
  private('Only me');

  const FieldVisibility(this.label);
  final String label;
}

/// Lifecycle of a user's onboarding. Persisted so the app knows whether to
/// route a first-time user into the flow, and so progress can be resumed.
enum OnboardingStatus { notStarted, inProgress, skipped, complete }

/// What the user is looking for in a match (Step 5).
@immutable
class LookingForPrefs {
  const LookingForPrefs({
    this.preferredRoles = const {},
    this.relationshipTypes = const {},
    this.ageMin = 18,
    this.ageMax = 60,
    this.maxDistanceKm = 50,
  });

  final Set<String> preferredRoles;
  final Set<String> relationshipTypes;
  final int ageMin;
  final int ageMax;
  final double maxDistanceKm;

  LookingForPrefs copyWith({
    Set<String>? preferredRoles,
    Set<String>? relationshipTypes,
    int? ageMin,
    int? ageMax,
    double? maxDistanceKm,
  }) =>
      LookingForPrefs(
        preferredRoles: preferredRoles ?? this.preferredRoles,
        relationshipTypes: relationshipTypes ?? this.relationshipTypes,
        ageMin: ageMin ?? this.ageMin,
        ageMax: ageMax ?? this.ageMax,
        maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      );
}

/// Self lifestyle attributes (Step 5). Used bidirectionally in matching.
@immutable
class LifestylePrefs {
  const LifestylePrefs({
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

  LifestylePrefs copyWith({
    String? smoking,
    String? drinking,
    String? pets,
    String? children,
    Set<String>? communicationStyles,
  }) =>
      LifestylePrefs(
        smoking: smoking ?? this.smoking,
        drinking: drinking ?? this.drinking,
        pets: pets ?? this.pets,
        children: children ?? this.children,
        communicationStyles: communicationStyles ?? this.communicationStyles,
      );
}

/// First-date preferences (Step 8).
@immutable
class DatePreferences {
  const DatePreferences({this.firstDates = const {}, this.budgetId});

  final Set<String> firstDates;
  final String? budgetId;

  DatePreferences copyWith({Set<String>? firstDates, String? budgetId}) =>
      DatePreferences(
        firstDates: firstDates ?? this.firstDates,
        budgetId: budgetId ?? this.budgetId,
      );
}

/// Coarse location only — PAIRRA never stores or exposes an exact position.
/// [approxLat]/[approxLng] are intentionally rounded before storage.
@immutable
class ApproximateLocation {
  const ApproximateLocation({
    this.granted = false,
    this.areaLabel,
    this.approxLat,
    this.approxLng,
  });

  final bool granted;
  final String? areaLabel;
  final double? approxLat;
  final double? approxLng;

  bool get hasLocation => granted && (areaLabel != null || approxLat != null);

  ApproximateLocation copyWith({
    bool? granted,
    String? areaLabel,
    double? approxLat,
    double? approxLng,
  }) =>
      ApproximateLocation(
        granted: granted ?? this.granted,
        areaLabel: areaLabel ?? this.areaLabel,
        approxLat: approxLat ?? this.approxLat,
        approxLng: approxLng ?? this.approxLng,
      );
}

/// Discovery/visibility controls (Step 10).
@immutable
class PrivacySettings {
  const PrivacySettings({
    this.profileVisibility = FieldVisibility.public,
    this.preferencesVisible = false,
    this.appearInDiscovery = true,
    this.showDistance = true,
    this.appearOutsideRange = false,
    this.showOnlineStatus = true,
    this.allowMessageRequests = false,
  });

  final FieldVisibility profileVisibility;
  final bool preferencesVisible;
  final bool appearInDiscovery;
  final bool showDistance;
  final bool appearOutsideRange;

  /// Show an "active recently" indicator to others.
  final bool showOnlineStatus;

  /// Allow messages from people you haven't matched with (off = matches only).
  final bool allowMessageRequests;

  PrivacySettings copyWith({
    FieldVisibility? profileVisibility,
    bool? preferencesVisible,
    bool? appearInDiscovery,
    bool? showDistance,
    bool? appearOutsideRange,
    bool? showOnlineStatus,
    bool? allowMessageRequests,
  }) =>
      PrivacySettings(
        profileVisibility: profileVisibility ?? this.profileVisibility,
        preferencesVisible: preferencesVisible ?? this.preferencesVisible,
        appearInDiscovery: appearInDiscovery ?? this.appearInDiscovery,
        showDistance: showDistance ?? this.showDistance,
        appearOutsideRange: appearOutsideRange ?? this.appearOutsideRange,
        showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
        allowMessageRequests: allowMessageRequests ?? this.allowMessageRequests,
      );
}

/// The onboarding draft. Every field is optional so the profile can be partial,
/// saved, and resumed. Sensitive fields (orientation, sexual roles) default to
/// non-public via [fieldVisibility].
@immutable
class OnboardingProfile {
  const OnboardingProfile({
    this.status = OnboardingStatus.notStarted,
    this.displayName,
    this.avatarSeed,
    this.bio,
    this.photos = const [],
    this.verification = const VerificationState(),
    this.dateOfBirth,
    this.genderId,
    this.genderCustom,
    this.orientationId,
    this.orientationCustom,
    this.datingIntentions = const {},
    this.roleSetId,
    this.sexualRoles = const {},
    this.lookingFor = const LookingForPrefs(),
    this.lifestyle = const LifestylePrefs(),
    this.interests = const {},
    this.personality = const {},
    this.datePreferences = const DatePreferences(),
    this.location = const ApproximateLocation(),
    this.privacy = const PrivacySettings(),
    this.fieldVisibility = defaultFieldVisibility,
    this.completedAt,
  });

  final OnboardingStatus status;

  // Step 1
  final String? displayName;
  final String? avatarSeed;
  final DateTime? dateOfBirth;

  // Profile-only fields (added by the profile editor; not part of onboarding).
  final String? bio;
  final List<ProfilePhoto> photos;
  final VerificationState verification;

  // Step 2
  final String? genderId;
  final String? genderCustom;
  final String? orientationId;
  final String? orientationCustom;

  // Step 3
  final Set<String> datingIntentions;

  // Step 4
  final String? roleSetId;
  final Set<String> sexualRoles;

  // Step 5
  final LookingForPrefs lookingFor;
  final LifestylePrefs lifestyle;

  // Step 6
  final Set<String> interests;

  // Step 7
  final Map<String, String> personality;

  // Step 8
  final DatePreferences datePreferences;

  // Step 9
  final ApproximateLocation location;

  // Step 10
  final PrivacySettings privacy;

  /// Per-field visibility for individually-sensitive attributes.
  final Map<String, FieldVisibility> fieldVisibility;

  final DateTime? completedAt;

  /// Sensitive fields start non-public; the user can widen them intentionally.
  static const Map<String, FieldVisibility> defaultFieldVisibility = {
    'gender': FieldVisibility.public,
    'orientation': FieldVisibility.matchesOnly,
    'roles': FieldVisibility.matchesOnly,
  };

  /// Age derived from [dateOfBirth] — never entered directly.
  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  bool get isAdult => (age ?? 0) >= 18;

  FieldVisibility visibilityOf(String field) =>
      fieldVisibility[field] ??
      defaultFieldVisibility[field] ??
      FieldVisibility.public;

  /// A coarse 0–100 estimate of how much matchable signal the profile carries.
  /// Used only for the closing "match readiness" estimate — explicitly not a
  /// precise or scientific score.
  int get readinessEstimate {
    var filled = 0;
    const total = 10;
    if ((displayName ?? '').trim().isNotEmpty) filled++;
    if (dateOfBirth != null) filled++;
    if (genderId != null && orientationId != null) filled++;
    if (datingIntentions.isNotEmpty) filled++;
    if (sexualRoles.isNotEmpty) filled++;
    if (lookingFor.preferredRoles.isNotEmpty ||
        lookingFor.relationshipTypes.isNotEmpty) {
      filled++;
    }
    if (interests.length >= 3) filled++;
    if (personality.isNotEmpty) filled++;
    if (datePreferences.firstDates.isNotEmpty) filled++;
    if (location.hasLocation) filled++;
    return ((filled / total) * 100).round().clamp(0, 100);
  }

  OnboardingProfile copyWith({
    OnboardingStatus? status,
    String? displayName,
    String? avatarSeed,
    String? bio,
    List<ProfilePhoto>? photos,
    VerificationState? verification,
    DateTime? dateOfBirth,
    String? genderId,
    String? genderCustom,
    String? orientationId,
    String? orientationCustom,
    Set<String>? datingIntentions,
    String? roleSetId,
    Set<String>? sexualRoles,
    LookingForPrefs? lookingFor,
    LifestylePrefs? lifestyle,
    Set<String>? interests,
    Map<String, String>? personality,
    DatePreferences? datePreferences,
    ApproximateLocation? location,
    PrivacySettings? privacy,
    Map<String, FieldVisibility>? fieldVisibility,
    DateTime? completedAt,
  }) {
    return OnboardingProfile(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      verification: verification ?? this.verification,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      genderId: genderId ?? this.genderId,
      genderCustom: genderCustom ?? this.genderCustom,
      orientationId: orientationId ?? this.orientationId,
      orientationCustom: orientationCustom ?? this.orientationCustom,
      datingIntentions: datingIntentions ?? this.datingIntentions,
      roleSetId: roleSetId ?? this.roleSetId,
      sexualRoles: sexualRoles ?? this.sexualRoles,
      lookingFor: lookingFor ?? this.lookingFor,
      lifestyle: lifestyle ?? this.lifestyle,
      interests: interests ?? this.interests,
      personality: personality ?? this.personality,
      datePreferences: datePreferences ?? this.datePreferences,
      location: location ?? this.location,
      privacy: privacy ?? this.privacy,
      fieldVisibility: fieldVisibility ?? this.fieldVisibility,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
