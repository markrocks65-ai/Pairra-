import 'verification_check.dart';

/// Thrown when a verification flow is started but no provider is connected.
class VerificationNotConnected implements Exception {
  const VerificationNotConnected();
  @override
  String toString() => 'No verification provider is connected.';
}

/// The seam for third-party identity/photo verification (Onfido, Persona,
/// Veriff, Stripe Identity, …). The app depends only on this interface.
///
/// CRITICAL: a provider only ever *starts* a flow. Verification RESULTS are
/// delivered out-of-band (a signed webhook → server → the user's
/// `VerificationState`). Nothing here — or anywhere on the client — sets a
/// status to `verified`. That is what keeps PAIRRA from faking verification.
///
/// Raw verification data (selfies, ID documents) is handled entirely by the
/// provider and the server; it never touches the profile model and is never
/// exposed. Only the resulting status is ever displayed.
abstract interface class VerificationProvider {
  /// Display name of the connected provider (or a "not connected" marker).
  String get name;

  /// Whether a real provider is wired up. When false, the UI presents the
  /// feature as coming soon / development-only and never fabricates a result.
  bool get isConnected;

  /// Launches the provider's verification flow for [type]. Throws
  /// [VerificationNotConnected] when [isConnected] is false.
  Future<void> start(VerificationCheckType type);
}

/// The default provider: nothing connected. It cannot and does not verify
/// anyone — starting a flow throws so the UI shows the coming-soon state.
class UnconnectedVerificationProvider implements VerificationProvider {
  const UnconnectedVerificationProvider();

  @override
  String get name => 'Not connected';

  @override
  bool get isConnected => false;

  @override
  Future<void> start(VerificationCheckType type) async =>
      throw const VerificationNotConnected();
}
