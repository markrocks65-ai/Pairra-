import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'accessibility_settings.dart';

/// Holds the user's manual accessibility overrides. This is the Riverpod
/// source of truth; a Settings screen will drive these setters, and
/// persistence (shared_preferences) can be layered in here later without
/// touching any consumer.
class AccessibilityController extends StateNotifier<AccessibilitySettings> {
  AccessibilityController([AccessibilitySettings? initial])
      : super(initial ?? const AccessibilitySettings());

  void setReduceMotion(A11yPreference value) =>
      state = state.copyWith(reduceMotion: value);

  void setReduceTransparency(A11yPreference value) =>
      state = state.copyWith(reduceTransparency: value);

  void setHighContrast(A11yPreference value) =>
      state = state.copyWith(highContrast: value);

  /// "Reduce visual effects" — drops backdrop blur / heavy motion for
  /// performance & battery on lower-end devices.
  void setReduceEffects(A11yPreference value) =>
      state = state.copyWith(reduceEffects: value);

  void reset() => state = const AccessibilitySettings();
}

/// The manual-overrides provider. Read this to build the resolved state at the
/// app root (see `PairraAccessibilityScope`), or to drive Settings toggles.
final accessibilityControllerProvider =
    StateNotifierProvider<AccessibilityController, AccessibilitySettings>(
  (ref) => AccessibilityController(),
);
