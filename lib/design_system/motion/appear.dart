import 'package:flutter/widgets.dart';

import '../../theme/app_motion.dart';
import '../accessibility/accessibility_scope.dart';

/// A subtle entrance: content fades in while easing up a few pixels (and,
/// optionally, scaling up slightly). This is PAIRRA's standard way to bring
/// cards, sections and list items onto the screen.
///
/// Pass an increasing [delay] to stagger a list (see [AppearGroup]). Respects
/// reduced-motion by presenting the final state instantly.
class Appear extends StatefulWidget {
  const Appear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.base,
    this.offset = const Offset(0, 12),
    this.beginScale = 1.0,
    this.curve = AppMotion.entrance,
  });

  final Widget child;

  /// Delay before this element begins animating (used for stagger).
  final Duration delay;
  final Duration duration;

  /// Starting translation, animated to [Offset.zero].
  final Offset offset;

  /// Starting scale, animated to 1.0. Keep close to 1.0 for subtlety.
  final double beginScale;

  final Curve curve;

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
      if (!mounted) return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion: skip the animation, show final content immediately.
    if (PairraA11y.of(context).reduceMotion) return widget.child;

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset.lerp(widget.offset, Offset.zero, t)!,
            child: Transform.scale(
              scale: widget.beginScale + (1.0 - widget.beginScale) * t,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Staggers [Appear] over a list of children by applying an increasing delay.
/// Handy for lists of cards/chips appearing in sequence.
class AppearGroup extends StatelessWidget {
  const AppearGroup({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 60),
    this.initialDelay = Duration.zero,
  });

  final List<Widget> children;
  final Duration interval;
  final Duration initialDelay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          Appear(
            delay: initialDelay + interval * i,
            child: children[i],
          ),
      ],
    );
  }
}
