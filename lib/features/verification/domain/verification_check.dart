/// The verification checks PAIRRA supports. Copy explains each to the user.
enum VerificationCheckType {
  photo(
    'Photo verification',
    'A quick selfie check confirms your photos are really you.',
  ),
  identity(
    'Identity verification',
    'A document check confirms your identity for a higher trust level.',
  );

  const VerificationCheckType(this.label, this.description);
  final String label;
  final String description;
}
