import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../foundations/device_capabilities.dart';
import 'accessibility_controller.dart';
import 'accessibility_settings.dart';

/// Provides the resolved accessibility state to the widget tree via an
/// [InheritedWidget]. Glass and motion components read
/// `PairraA11y.of(context)` — they depend on this simple inherited value
/// rather than on Riverpod directly, which keeps every design-system widget
/// portable and trivially testable (wrap in [PairraA11y.override] in tests).
class PairraA11y extends InheritedWidget {
  const PairraA11y({
    super.key,
    required this.data,
    required super.child,
  });

  final ResolvedAccessibility data;

  /// Reads the nearest resolved accessibility state, or a safe all-off
  /// [ResolvedAccessibility.fallback] if no scope is present.
  static ResolvedAccessibility of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<PairraA11y>();
    return scope?.data ?? ResolvedAccessibility.fallback;
  }

  /// Test/preview helper to force a specific accessibility state around a
  /// subtree. (Named `withData` rather than `override` so it doesn't shadow
  /// the `@override` annotation inside this class.)
  static Widget withData({
    required ResolvedAccessibility data,
    required Widget child,
  }) {
    return PairraA11y(data: data, child: child);
  }

  @override
  bool updateShouldNotify(PairraA11y oldWidget) => data != oldWidget.data;
}

/// Root wiring widget: merges the Riverpod manual overrides with the live
/// [MediaQuery] OS signals and exposes the result through [PairraA11y].
///
/// Place this just inside `MaterialApp`'s builder (so a [MediaQuery] exists
/// above it) and wrap the app content:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) =>
///       PairraAccessibilityScope(child: child!),
///   ...
/// )
/// ```
class PairraAccessibilityScope extends ConsumerWidget {
  const PairraAccessibilityScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityControllerProvider);
    // Fold in the hardware-tier hint so lower-end devices default to the
    // reduced-effects (blur-off) path without needing an OS or manual signal.
    final resolved = settings.resolve(
      MediaQuery.of(context),
      deviceIsLowEnd: DeviceCapabilities.isLowEnd,
    );
    return PairraA11y(data: resolved, child: child);
  }
}
