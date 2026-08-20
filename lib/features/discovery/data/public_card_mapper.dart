import '../../../core/models/profile_photo.dart';
import '../../onboarding/domain/onboarding_profile.dart';

/// Maps a sanitized public card (from `discoverProfiles` or a `publicProfiles/*`
/// document — both produced by the server's buildPublicCard) into the app's
/// [OnboardingProfile]. Only non-sensitive fields exist on the card: name, age,
/// bio, photos, interests, intentions, gender/orientation and a coarse area
/// label. Sexual roles, private preferences, lifestyle and coordinates are
/// deliberately never projected, so those fields stay empty here (SECURITY.md).
OnboardingProfile onboardingProfileFromPublicCard(
  Map<String, dynamic> card, {
  String uidForPhotos = '',
}) {
  final age = (card['age'] as num?)?.toInt();
  return OnboardingProfile(
    status: OnboardingStatus.complete,
    displayName: card['displayName'] as String?,
    bio: card['bio'] as String?,
    dateOfBirth:
        age == null ? null : DateTime(DateTime.now().year - age, 6, 15),
    genderId: card['genderId'] as String?,
    genderCustom: card['genderCustom'] as String?,
    orientationId: card['orientationId'] as String?,
    orientationCustom: card['orientationCustom'] as String?,
    interests: _stringSet(card['interests']),
    datingIntentions: _stringSet(card['datingIntentions']),
    photos: _photos(card['photos'], uidForPhotos),
    location: ApproximateLocation(
      granted: card['areaLabel'] != null,
      areaLabel: card['areaLabel'] as String?,
    ),
  );
}

Set<String> _stringSet(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toSet() : <String>{};

List<ProfilePhoto> _photos(dynamic v, String uid) {
  if (v is! List) return const [];
  final out = <ProfilePhoto>[];
  for (var i = 0; i < v.length; i++) {
    final p = v[i];
    var id = '${uid}_$i';
    var seed = 'p1';
    String? url;
    if (p is String) {
      if (p.startsWith('http')) {
        url = p;
      } else {
        seed = p;
      }
    } else if (p is Map) {
      final m = Map<String, dynamic>.from(p);
      id = (m['id'] ?? id).toString();
      url = m['url'] as String?;
      seed = (m['placeholderSeed'] ?? m['seed'] ?? seed).toString();
    }
    out.add(ProfilePhoto(
      id: id,
      placeholderSeed: seed,
      url: url,
      moderation: PhotoModerationStatus.approved,
    ));
  }
  return out;
}
