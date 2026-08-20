import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairra/design_system/design_system.dart';

void main() {
  group('A11yPreference.resolve', () {
    test('system follows the OS value', () {
      expect(A11yPreference.system.resolve(true), isTrue);
      expect(A11yPreference.system.resolve(false), isFalse);
    });

    test('on/off force the value regardless of OS', () {
      expect(A11yPreference.on.resolve(false), isTrue);
      expect(A11yPreference.off.resolve(true), isFalse);
    });
  });

  group('AccessibilitySettings.resolve', () {
    test('merges OS MediaQuery signals with manual overrides', () {
      const settings = AccessibilitySettings(
        reduceMotion: A11yPreference.on,
        reduceTransparency: A11yPreference.system,
        highContrast: A11yPreference.off,
      );
      const mq = MediaQueryData(
        disableAnimations: false,
        highContrast: true,
        boldText: true,
      );

      final resolved = settings.resolve(mq);

      expect(resolved.reduceMotion, isTrue, reason: 'forced on');
      expect(resolved.highContrast, isFalse, reason: 'forced off');
      // reduceTransparency (system) ties to the OS highContrast heuristic.
      expect(resolved.reduceTransparency, isTrue);
      expect(resolved.boldText, isTrue);
    });
  });

  group('GlassStyle', () {
    test('forLevel produces a translucent tint with blur', () {
      final style = GlassStyle.forLevel(GlassLevel.standard);
      expect(style.blurSigma, greaterThan(0));
      expect(style.tint.a, lessThan(1.0), reason: 'tint is translucent');
    });

    test('toOpaque removes blur and makes the fill fully opaque', () {
      final style = GlassStyle.forLevel(GlassLevel.prominent).toOpaque();
      expect(style.blurSigma, 0);
      expect(style.tint.a, 1.0, reason: 'opaque fallback fill');
    });

    test('toOpaque strengthens the border in high contrast', () {
      final normal = GlassStyle.forLevel(GlassLevel.standard).toOpaque();
      final hc =
          GlassStyle.forLevel(GlassLevel.standard).toOpaque(highContrast: true);
      expect(hc.borderColor, isNot(equals(normal.borderColor)));
    });

    test('subtle level uses no backdrop blur (cheap in lists)', () {
      // Chips/pills/rows render many-at-a-time; a per-widget BackdropFilter each
      // would wreck scroll performance, so subtle is a translucent fill only.
      final subtle = GlassStyle.forLevel(GlassLevel.subtle);
      expect(subtle.blurSigma, 0);
      expect(subtle.tint.a, lessThan(1.0), reason: 'still translucent glass');
    });

    test('withoutBlur drops the blur but keeps translucency', () {
      final base = GlassStyle.forLevel(GlassLevel.prominent);
      final cheap = base.withoutBlur();
      expect(base.blurSigma, greaterThan(0));
      expect(cheap.blurSigma, 0, reason: 'no backdrop resample');
      expect(cheap.tint.a, lessThan(1.0),
          reason: 'still glass, unlike toOpaque');
    });
  });

  group('reduceEffects (performance / lower-end fallback)', () {
    test('the explicit toggle reduces glass effects without going opaque', () {
      const settings = AccessibilitySettings(reduceEffects: A11yPreference.on);
      final resolved = settings.resolve(const MediaQueryData());
      expect(resolved.reduceGlassEffects, isTrue);
      expect(resolved.reduceTransparency, isFalse,
          reason: 'performance path stays translucent');
    });

    test('reduced transparency always implies reduced glass effects', () {
      const settings =
          AccessibilitySettings(reduceTransparency: A11yPreference.on);
      final resolved = settings.resolve(const MediaQueryData());
      expect(resolved.reduceTransparency, isTrue);
      expect(resolved.reduceGlassEffects, isTrue,
          reason: 'no point blurring what we paint over');
    });

    test('effects follow the OS reduce-animations signal by default', () {
      const settings = AccessibilitySettings(); // all system
      expect(
        settings
            .resolve(const MediaQueryData(disableAnimations: true))
            .reduceGlassEffects,
        isTrue,
      );
      expect(
        settings.resolve(const MediaQueryData()).reduceGlassEffects,
        isFalse,
      );
    });

    test('a low-end device defaults into the reduced-effects path', () {
      const settings = AccessibilitySettings(); // all system, no OS signal
      expect(
        settings
            .resolve(const MediaQueryData(), deviceIsLowEnd: true)
            .reduceGlassEffects,
        isTrue,
        reason: 'hardware tier alone should drop backdrop blur',
      );
      expect(
        settings
            .resolve(const MediaQueryData(), deviceIsLowEnd: true)
            .reduceTransparency,
        isFalse,
        reason: 'low-end still keeps the translucent look, just no blur',
      );
    });

    test('an explicit opt-out beats the low-end device hint', () {
      const settings = AccessibilitySettings(reduceEffects: A11yPreference.off);
      expect(
        settings
            .resolve(const MediaQueryData(), deviceIsLowEnd: true)
            .reduceGlassEffects,
        isFalse,
        reason: 'the user chose full effects; the hint must not override that',
      );
    });
  });
}
