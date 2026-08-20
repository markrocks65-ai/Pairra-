import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// A coarse, dependency-free read on how much visual budget a device has.
///
/// The Liquid Glass system already knows how to degrade — [ResolvedAccessibility]
/// carries `reduceGlassEffects`, and every surface honours it — but until now the
/// only things that could *turn that on automatically* were OS signals
/// (battery-saver / "reduce animations") and the manual Settings toggle. A brand
/// new budget Android phone, fully charged and with no accessibility settings,
/// would therefore be asked to paint the full triple-`BackdropFilter` treatment
/// (nav bar + card badge + info panel) at 60–120fps. This closes that gap by
/// giving the accessibility pipeline a hardware-tier hint.
///
/// The signal is deliberately conservative: we only claim "low-end" when we're
/// fairly sure, so we never strip the premium look from a capable device. It is
/// a *hint* into an existing graceful-degradation path, not a hard gate.
///
/// This is intentionally dependency-free (no `device_info_plus`) so it can ship
/// today. `Platform.numberOfProcessors` is a weak proxy for total capability;
/// the right long-term signal is physical RAM (`< ~3 GB` is the usual low-end
/// line). When a device-info dependency becomes acceptable, back [_isLowEnd]
/// with RAM and keep this same public surface — no call site changes.
abstract final class DeviceCapabilities {
  DeviceCapabilities._();

  static bool? _cached;

  /// Whether this device should default to the reduced-effects (blur-off) path.
  /// Computed once and cached — hardware tier does not change at runtime.
  static bool get isLowEnd => _cached ??= _compute();

  /// Test seam: force the tier (pass `null` to fall back to auto-detection).
  @visibleForTesting
  static set debugOverride(bool? value) => _cached = value;

  static bool _compute() {
    // Web and desktop are treated as high-capability: they don't hit the mobile
    // GPU-bound blur ceiling in the same way, and `Platform` is unavailable on
    // web, so guard before touching it.
    if (kIsWeb) return false;
    if (!(Platform.isAndroid || Platform.isIOS)) return false;

    // Core count is the only capability proxy available without a plugin. Two
    // or fewer active cores is a strong low-end signal across the Android
    // fleet; we stay at this conservative threshold rather than risk demoting
    // capable octa-core mid-range devices. iOS hardware floor is high enough
    // that no shipping iPhone trips this.
    return Platform.numberOfProcessors <= 2;
  }
}
