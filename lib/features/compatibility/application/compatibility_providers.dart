import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'compatibility_service.dart';

/// The app-wide compatibility engine. Stateless and pure, so a single const
/// instance is shared. Override in tests/experiments to swap weights.
final compatibilityServiceProvider = Provider<CompatibilityService>(
  (ref) => const CompatibilityService(),
);
