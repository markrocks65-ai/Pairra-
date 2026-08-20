import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../accessibility/accessibility_scope.dart';

/// Wraps any tappable content with PAIRRA's signature press feedback: a subtle
/// scale-down (and optional opacity dip) while pressed. Used by
/// LiquidGlassButton, chips, cards, nav items and the FAB so every interactive
/// glass element feels physical and consistent.
///
/// Accessibility — this is the single tap primitive, so it centralizes the
/// a11y that every button needs:
///  • **Screen readers**: exposes a `button` role and an optional
///    [semanticLabel] (essential for icon-only buttons that have no text).
///  • **Keyboard / switch access**: focusable and activatable with Enter/Space
///    via [FocusableActionDetector], with a visible focus ring.
///  • **Touch targets**: [minTapTarget] grows the hit area to the platform
///    minimum without changing the visual size.
///  • **Reduced motion**: the press scale/opacity animation is skipped.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.pressedOpacity = 1.0,
    this.enabled = true,
    this.behavior = HitTestBehavior.opaque,
    this.semanticLabel,
    this.isButton = true,
    this.minTapTarget,
    this.focusBorderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Scale applied while pressed (1.0 = no scale).
  final double pressedScale;

  /// Opacity applied while pressed (1.0 = no change).
  final double pressedOpacity;

  final bool enabled;
  final HitTestBehavior behavior;

  /// Accessible label announced by screen readers. Required in practice for
  /// icon-only controls (back arrows, glass icon buttons) that have no text.
  final String? semanticLabel;

  /// Whether to expose a `button` semantic role. Set false when wrapping
  /// non-button content (e.g. a whole card that also has richer inner
  /// semantics) to avoid an unhelpful "button" announcement.
  final bool isButton;

  /// Minimum hit-target size. When set, the tappable area is grown to at least
  /// this size (centered on the visual) so small icons still meet the ~48dp
  /// touch-target guideline without visually enlarging.
  final Size? minTapTarget;

  /// Corner radius of the keyboard focus ring. Defaults to a rounded rect;
  /// pass a pill radius for circular/pill controls so the ring hugs the shape.
  final BorderRadius? focusBorderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _focused = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (!_interactive) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    final active = _pressed && _interactive;

    final scale = reduceMotion || !active ? 1.0 : widget.pressedScale;
    final opacity = reduceMotion || !active ? 1.0 : widget.pressedOpacity;

    Widget content = AnimatedScale(
      scale: scale,
      duration: reduceMotion ? AppMotion.instant : AppMotion.fast,
      curve: AppMotion.standard,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: reduceMotion ? AppMotion.instant : AppMotion.fast,
        child: widget.child,
      ),
    );

    // Grow the hit area to the touch-target minimum without resizing the visual.
    if (widget.minTapTarget != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minTapTarget!.width,
          minHeight: widget.minTapTarget!.height,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      );
    }

    Widget result = GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: content,
    );

    if (_interactive) {
      // Keyboard / switch activation: Enter and Space (mapped to ActivateIntent
      // by the app's default shortcuts) fire the tap when this control is
      // focused. Also draws a focus ring so keyboard users can see where they are.
      final radius = widget.focusBorderRadius ??
          BorderRadius.circular(AppRadius.lg);
      result = FocusableActionDetector(
        enabled: _interactive,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) {
          if (_focused != value) setState(() => _focused = value);
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: _focused
                ? Border.all(color: AppColors.accent, width: 2)
                : null,
          ),
          child: result,
        ),
      );
    }

    if (!widget.isButton && widget.semanticLabel == null) return result;

    return Semantics(
      button: widget.isButton && _interactive,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      child: result,
    );
  }
}
