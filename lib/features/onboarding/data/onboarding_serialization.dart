import '../../../core/models/profile_photo.dart';
import '../domain/onboarding_profile.dart';

/// Serializes [OnboardingProfile] (the shared onboarding/profile draft) to and
/// from a plain map, for Firestore persistence. Kept out of the model so the
/// domain stays free of storage concerns, and unit-tested via round-trip.
///
/// Sets are stored as lists, enums as their `name`, and dates as ISO-8601
/// strings for portability.
abstract final class OnboardingSerializer {
  static Map<String, dynamic> toMap(OnboardingProfile p) => {
        'status': p.status.name,
        'displayName': p.displayName,
        'avatarSeed': p.avatarSeed,
        'bio': p.bio,
        'photos': [for (final ph in p.photos) _photoToMap(ph)],
        // NOTE: verification status is intentionally NOT persisted here. This
        // document is owner-writable, so allowing it would let a client
        // self-verify. Verification is a server-only field elsewhere.
        'dateOfBirth': p.dateOfBirth?.toIso8601String(),
        'genderId': p.genderId,
        'genderCustom': p.genderCustom,
        'orientationId': p.orientationId,
        'orientationCustom': p.orientationCustom,
        'datingIntentions': p.datingIntentions.toList(),
        'roleSetId': p.roleSetId,
        'sexualRoles': p.sexualRoles.toList(),
        'lookingFor': _lookingForToMap(p.lookingFor),
        'lifestyle': _lifestyleToMap(p.lifestyle),
        'interests': p.interests.toList(),
        'personality': p.personality,
        'datePreferences': _dateePrefsToMap(p.datePreferences),
        'location': _locationToMap(p.location),
        'privacy': _privacyToMap(p.privacy),
        'fieldVisibility': {
          for (final e in p.fieldVisibility.entries) e.key: e.value.name,
        },
        'completedAt': p.completedAt?.toIso8601String(),
      };

  static OnboardingProfile fromMap(Map<String, dynamic> m) => OnboardingProfile(
        status: _enum(OnboardingStatus.values, m['status'],
            OnboardingStatus.notStarted),
        displayName: m['displayName'] as String?,
        avatarSeed: m['avatarSeed'] as String?,
        bio: m['bio'] as String?,
        photos: [
          for (final ph in (m['photos'] as List? ?? const []))
            _photoFromMap(Map<String, dynamic>.from(ph as Map)),
        ],
        dateOfBirth: _date(m['dateOfBirth']),
        genderId: m['genderId'] as String?,
        genderCustom: m['genderCustom'] as String?,
        orientationId: m['orientationId'] as String?,
        orientationCustom: m['orientationCustom'] as String?,
        datingIntentions: _stringSet(m['datingIntentions']),
        roleSetId: m['roleSetId'] as String?,
        sexualRoles: _stringSet(m['sexualRoles']),
        lookingFor: _lookingForFromMap(_asMap(m['lookingFor']) ?? const {}),
        lifestyle: _lifestyleFromMap(_asMap(m['lifestyle']) ?? const {}),
        interests: _stringSet(m['interests']),
        personality: _stringMap(m['personality']),
        datePreferences:
            _datePrefsFromMap(_asMap(m['datePreferences']) ?? const {}),
        location: _locationFromMap(_asMap(m['location']) ?? const {}),
        privacy: _privacyFromMap(_asMap(m['privacy']) ?? const {}),
        fieldVisibility: {
          for (final e in (_asMap(m['fieldVisibility']) ?? const {}).entries)
            e.key: _enum(FieldVisibility.values, e.value, FieldVisibility.public),
        },
        completedAt: _date(m['completedAt']),
      );

  // --- Sub-objects ----------------------------------------------------------

  static Map<String, dynamic> _photoToMap(ProfilePhoto p) => {
        'id': p.id,
        'placeholderSeed': p.placeholderSeed,
        'url': p.url,
        'moderation': p.moderation.name,
      };

  static ProfilePhoto _photoFromMap(Map<String, dynamic> m) => ProfilePhoto(
        id: m['id'] as String? ?? '',
        placeholderSeed: m['placeholderSeed'] as String? ?? 'p1',
        url: m['url'] as String?,
        moderation: _enum(PhotoModerationStatus.values, m['moderation'],
            PhotoModerationStatus.pending),
      );

  static Map<String, dynamic> _lookingForToMap(LookingForPrefs l) => {
        'preferredRoles': l.preferredRoles.toList(),
        'relationshipTypes': l.relationshipTypes.toList(),
        'ageMin': l.ageMin,
        'ageMax': l.ageMax,
        'maxDistanceKm': l.maxDistanceKm,
      };

  static LookingForPrefs _lookingForFromMap(Map<String, dynamic> m) =>
      LookingForPrefs(
        preferredRoles: _stringSet(m['preferredRoles']),
        relationshipTypes: _stringSet(m['relationshipTypes']),
        ageMin: (m['ageMin'] as num?)?.toInt() ?? 18,
        ageMax: (m['ageMax'] as num?)?.toInt() ?? 60,
        maxDistanceKm: (m['maxDistanceKm'] as num?)?.toDouble() ?? 50,
      );

  static Map<String, dynamic> _lifestyleToMap(LifestylePrefs l) => {
        'smoking': l.smoking,
        'drinking': l.drinking,
        'pets': l.pets,
        'children': l.children,
        'communicationStyles': l.communicationStyles.toList(),
      };

  static LifestylePrefs _lifestyleFromMap(Map<String, dynamic> m) =>
      LifestylePrefs(
        smoking: m['smoking'] as String?,
        drinking: m['drinking'] as String?,
        pets: m['pets'] as String?,
        children: m['children'] as String?,
        communicationStyles: _stringSet(m['communicationStyles']),
      );

  static Map<String, dynamic> _dateePrefsToMap(DatePreferences d) =>
      {'firstDates': d.firstDates.toList(), 'budgetId': d.budgetId};

  static DatePreferences _datePrefsFromMap(Map<String, dynamic> m) =>
      DatePreferences(
        firstDates: _stringSet(m['firstDates']),
        budgetId: m['budgetId'] as String?,
      );

  static Map<String, dynamic> _locationToMap(ApproximateLocation l) => {
        'granted': l.granted,
        'areaLabel': l.areaLabel,
        'approxLat': l.approxLat,
        'approxLng': l.approxLng,
      };

  static ApproximateLocation _locationFromMap(Map<String, dynamic> m) =>
      ApproximateLocation(
        granted: m['granted'] as bool? ?? false,
        areaLabel: m['areaLabel'] as String?,
        approxLat: (m['approxLat'] as num?)?.toDouble(),
        approxLng: (m['approxLng'] as num?)?.toDouble(),
      );

  static Map<String, dynamic> _privacyToMap(PrivacySettings s) => {
        'profileVisibility': s.profileVisibility.name,
        'preferencesVisible': s.preferencesVisible,
        'appearInDiscovery': s.appearInDiscovery,
        'showDistance': s.showDistance,
        'appearOutsideRange': s.appearOutsideRange,
        'showOnlineStatus': s.showOnlineStatus,
        'allowMessageRequests': s.allowMessageRequests,
      };

  static PrivacySettings _privacyFromMap(Map<String, dynamic> m) =>
      PrivacySettings(
        profileVisibility: _enum(FieldVisibility.values,
            m['profileVisibility'], FieldVisibility.public),
        preferencesVisible: m['preferencesVisible'] as bool? ?? false,
        appearInDiscovery: m['appearInDiscovery'] as bool? ?? true,
        showDistance: m['showDistance'] as bool? ?? true,
        appearOutsideRange: m['appearOutsideRange'] as bool? ?? false,
        showOnlineStatus: m['showOnlineStatus'] as bool? ?? true,
        allowMessageRequests: m['allowMessageRequests'] as bool? ?? false,
      );

  // --- Primitives -----------------------------------------------------------

  static Set<String> _stringSet(Object? v) =>
      v is List ? v.map((e) => e.toString()).toSet() : const {};

  static Map<String, String> _stringMap(Object? v) => v is Map
      ? {for (final e in v.entries) e.key.toString(): e.value.toString()}
      : const {};

  static Map<String, dynamic>? _asMap(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  static T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final e in values) {
      if (e.name == name) return e;
    }
    return fallback;
  }
}
