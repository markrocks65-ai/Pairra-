import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/verification.dart';
import '../../profile/application/profile_providers.dart';
import '../domain/verification_provider.dart';

/// The active verification provider. Defaults to "not connected" so the app
/// never fakes verification. Wire a real provider here later:
///
/// ```dart
/// verificationProviderProvider.overrideWithValue(OnfidoVerificationProvider(...))
/// ```
final verificationProviderProvider = Provider<VerificationProvider>(
  (ref) => const UnconnectedVerificationProvider(),
);

/// The current user's verification status (only statuses — never the underlying
/// verification data). Sourced from the profile, which a server updates.
final verificationStateProvider = Provider<VerificationState>(
  (ref) => ref.watch(currentProfileProvider).verification,
);
