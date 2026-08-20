import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion tokens — durations and curves used across PAIRRA.
///
/// PAIRRA motion is subtle and premium: short, eased, purposeful. Nothing
/// bounces or overshoots aggressively. When reduced-motion is active, the
/// motion widgets in `design_system/motion` collapse these to
/// [AppMotion.instant]. Reference these tokens rather than hard-coding
/// `Duration(milliseconds: ...)` so timing stays consistent.
@immutable
abstract final class AppMotion {
  // Durations ----------------------------------------------------------------

  /// Used to disable animation entirely (reduced-motion fallback).
  static const Duration instant = Duration.zero;

  /// Micro-interactions: button press, chip toggle, ripple.
  static const Duration fast = Duration(milliseconds: 140);

  /// Standard element transitions: cards appearing, fades.
  static const Duration base = Duration(milliseconds: 260);

  /// Larger surfaces: modals, bottom sheets, navigation changes.
  static const Duration slow = Duration(milliseconds: 380);

  /// Expressive, one-off moments: a match reveal, a score counting up.
  static const Duration expressive = Duration(milliseconds: 720);

  // Curves -------------------------------------------------------------------

  /// The house curve — a gentle ease used for most entrances/exits.
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Decelerate — for elements entering the screen.
  static const Curve entrance = Curves.easeOutCubic;

  /// Accelerate — for elements leaving the screen.
  static const Curve exit = Curves.easeInCubic;

  /// A restrained emphasized curve for expressive moments (no big overshoot).
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
}
