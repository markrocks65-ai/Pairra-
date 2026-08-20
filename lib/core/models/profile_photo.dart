import 'package:flutter/foundation.dart';

/// Future image-safety state for a photo. Real automated + human moderation is
/// a later backend system; this enum lets the UI show honest placeholders
/// ("Pending review") now without claiming moderation is actually running.
enum PhotoModerationStatus {
  pending('Pending review'),
  approved('Approved'),
  rejected('Not approved');

  const PhotoModerationStatus(this.label);
  final String label;
}

/// A profile photo. Until real image upload/storage is wired in, a photo is a
/// premium gradient placeholder identified by [placeholderSeed]; [url] is the
/// slot for the real image later. Every photo carries a [moderation] status so
/// the image-safety pipeline can attach to this shape without a model change.
@immutable
class ProfilePhoto {
  const ProfilePhoto({
    required this.id,
    required this.placeholderSeed,
    this.url,
    this.moderation = PhotoModerationStatus.pending,
  });

  final String id;
  final String placeholderSeed;
  final String? url;
  final PhotoModerationStatus moderation;

  ProfilePhoto copyWith({
    String? placeholderSeed,
    String? url,
    PhotoModerationStatus? moderation,
  }) =>
      ProfilePhoto(
        id: id,
        placeholderSeed: placeholderSeed ?? this.placeholderSeed,
        url: url ?? this.url,
        moderation: moderation ?? this.moderation,
      );

  @override
  bool operator ==(Object other) => other is ProfilePhoto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
