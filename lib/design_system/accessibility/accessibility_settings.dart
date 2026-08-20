import 'package:flutter/widgets.dart';

/// A tri-state preference: follow the OS, or force on/off. Most PAIRRA users
/// will leave everything on [system]; the manual overrides exist so the app
/// can offer explicit toggles in Settings that don't depend on OS support
/// (notably reduced transparency, which not every platform surfaces).
enum A11yPreference {
  system,
  on,
  off;

  /// Resolves this preference against the OS-provided [systemValue].
  bool resolve(bool systemValue) => switch (this) {
        A11yPreference.system => systemValue,
        A11yPreference.on => true,
        A11yPreference.off => false,
      };
}

/// The user's manual accessibility overrides (persisted in Settings later).
/// These are merged with live OS signals from [MediaQuery] to produce a
/// [ResolvedAccessibility].
@immutable
class AccessibilitySettings {
  const AccessibilitySettings({
    this.reduceMotion = A11yPreference.system,
    this.reduceTransparency = A11yPreference.system,
    this.highContrast = A11yPreference.system,
    this.reduceEffects = A11yPreference.system,
  });

  final A11yPreference reduceMotion;
  final A11yPreference reduceTransparency;
  final A11yPreference highContrast;

  /// "Reduce visual effects" — a performance/battery preference that drops
  /// backdrop blur and heavy motion across the app. Distinct from
  /// [reduceTransparency] (an accessibility need) even though both render glass
  /// opaque; a user on a lower-end device can opt into this without asking for
  /// the high-contrast/opaque accessibility treatment. Defaults to following
  /// the OS "reduce animations" signal, which is what battery-saver toggles.
  final A11yPreference reduceEffects;

  AccessibilitySettings copyWith({
    A11yPreference? reduceMotion,
    A11yPreference? reduceTransparency,
    A11yPreference? highContrast,
    A11yPreference? reduceEffects,
  }) {
    return AccessibilitySettings(
      reduceMotion: reduceMotion ?? this.reduceMotion,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      highContrast: highContrast ?? this.highContrast,
      reduceEffects: reduceEffects ?? this.reduceEffects,
    );
  }

  /// Merges these manual overrides with the current [MediaQueryData] to yield
  /// the concrete booleans widgets act on.
  ///
  /// Note: Flutter's [MediaQueryData] does not expose a cross-platform
  /// "reduce transparency" signal, so when [reduceTransparency] is
  /// [A11yPreference.system] we tie it to `highContrast` as a sensible OS
  /// heuristic (users who ask for high contrast benefit from opaque surfaces).
  /// The explicit in-app toggle bypasses this entirely.
  ///
  /// [deviceIsLowEnd] lets the caller fold in a hardware-tier hint (see
  /// `DeviceCapabilities.isLowEnd`): a low-end device defaults to the
  /// reduced-effects (blur-off) path even with no OS or manual signal. A user
  /// who has *explicitly* turned reduce-effects [A11yPreference.off] still wins
  /// — the hint only raises the floor, it never overrides an explicit opt-out.
  ResolvedAccessibility resolve(MediaQueryData mq,
      {bool deviceIsLowEnd = false}) {
    final hc = highContrast.resolve(mq.highContrast);
    final reduceTransparencyValue = reduceTransparency.resolve(mq.highContrast);
    // Effects are reduced when the user asks (or the OS is minimizing motion,
    // which battery-saver does), and always when transparency is reduced —
    // there is no point paying for blur we're about to paint over anyway. A
    // low-end device also defaults into this path, unless the user explicitly
    // opted out (reduceEffects == off), which we honour above all.
    final reduceEffectsValue = reduceEffects == A11yPreference.off
        ? false
        : reduceEffects.resolve(mq.disableAnimations) ||
            reduceTransparencyValue ||
            deviceIsLowEnd;
    return ResolvedAccessibility(
      reduceMotion: reduceMotion.resolve(mq.disableAnimations),
      reduceTransparency: reduceTransparencyValue,
      reduceGlassEffects: reduceEffectsValue,
      highContrast: hc,
      boldText: mq.boldText,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AccessibilitySettings &&
      other.reduceMotion == reduceMotion &&
      other.reduceTransparency == reduceTransparency &&
      other.highContrast == highContrast &&
      other.reduceEffects == reduceEffects;

  @override
  int get hashCode =>
      Object.hash(reduceMotion, reduceTransparency, highContrast, reduceEffects);
}

/// The resolved, concrete accessibility state that widgets read via
/// `PairraA11y.of(context)`. Immutable snapshot for the current build.
@immutable
class ResolvedAccessibility {
  const ResolvedAccessibility({
    required this.reduceMotion,
    required this.reduceTransparency,
    required this.highContrast,
    required this.boldText,
    this.reduceGlassEffects = false,
  });

  /// When true, motion utilities skip animation and present final state.
  final bool reduceMotion;

  /// When true, glass components render as opaque dark surfaces (no blur,
  /// no translucency) — an accessibility need.
  final bool reduceTransparency;

  /// When true, glass surfaces skip their backdrop blur for performance/battery
  /// (the "reduce visual effects" / lower-end-device path). Implied whenever
  /// [reduceTransparency] is on. Surfaces stay translucent unless transparency
  /// is also reduced, so the look degrades gracefully rather than all-or-nothing.
  final bool reduceGlassEffects;

  /// When true, borders/text are strengthened for contrast.
  final bool highContrast;

  /// Mirrors the OS "bold text" setting.
  final bool boldText;

  /// Safe default (everything off) for tests / non-scoped contexts.
  static const ResolvedAccessibility fallback = ResolvedAccessibility(
    reduceMotion: false,
    reduceTransparency: false,
    reduceGlassEffects: false,
    highContrast: false,
    boldText: false,
  );

  @override
  bool operator ==(Object other) =>
      other is ResolvedAccessibility &&
      other.reduceMotion == reduceMotion &&
      other.reduceTransparency == reduceTransparency &&
      other.reduceGlassEffects == reduceGlassEffects &&
      other.highContrast == highContrast &&
      other.boldText == boldText;

  @override
  int get hashCode => Object.hash(reduceMotion, reduceTransparency,
      reduceGlassEffects, highContrast, boldText);
}
