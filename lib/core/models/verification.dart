import 'package:flutter/foundation.dart';

/// Status of a single verification check. Set only by the (future) backend —
/// the app never self-awards [verified]. Until then everything stays [none].
enum VerificationStatus {
  none('Not verified'),
  pending('In review'),
  verified('Verified'),
  rejected('Not verified');

  const VerificationStatus(this.label);
  final String label;

  bool get isVerified => this == VerificationStatus.verified;
}

/// A user's verification state across the checks PAIRRA will support. The
/// architecture is in place now; the verified badge only ever appears when a
/// real backend marks a check [verified] — we never claim verification exists
/// before then.
@immutable
class VerificationState {
  const VerificationState({
    this.photo = VerificationStatus.none,
    this.identity = VerificationStatus.none,
  });

  final VerificationStatus photo;
  final VerificationStatus identity;

  /// The verified badge shows only when a real check has been verified.
  bool get hasBadge => photo.isVerified || identity.isVerified;

  VerificationState copyWith({
    VerificationStatus? photo,
    VerificationStatus? identity,
  }) =>
      VerificationState(
        photo: photo ?? this.photo,
        identity: identity ?? this.identity,
      );
}
