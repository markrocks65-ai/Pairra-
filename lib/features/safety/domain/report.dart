/// Reasons a user can report someone/something. Safety and moderation features
/// are first-class and never paywalled.
enum ReportReason {
  harassment('Harassment'),
  threats('Threats'),
  spam('Spam'),
  scam('Scam'),
  impersonation('Impersonation'),
  underageUser('Underage user'),
  nonConsensualContent('Non-consensual sexual content'),
  hateSpeech('Hate speech'),
  other('Other');

  const ReportReason(this.label);
  final String label;
}
