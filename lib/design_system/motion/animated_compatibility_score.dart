import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_typography.dart';
import '../accessibility/accessibility_scope.dart';

/// The compatibility-score readout — a number (0–100) that counts up when it
/// first appears, using tabular figures so digits don't jitter. This is a
/// signature PAIRRA moment, so it lives in the design system rather than being
/// re-built per screen.
///
/// The color subtly reflects strength (restrained: muted → accent → success),
/// never neon. Respects reduced-motion by showing the final value instantly.
class AnimatedCompatibilityScore extends StatefulWidget {
  const AnimatedCompatibilityScore({
    super.key,
    required this.score,
    this.duration = AppMotion.expressive,
    this.textStyle,
    this.showPercentSign = false,
    this.colorize = true,
  });

  /// Target score, 0–100.
  final int score;
  final Duration duration;
  final TextStyle? textStyle;
  final bool showPercentSign;

  /// When true, tints the number by strength using restrained brand colors.
  final bool colorize;

  @override
  State<AnimatedCompatibilityScore> createState() =>
      _AnimatedCompatibilityScoreState();
}

class _AnimatedCompatibilityScoreState
    extends State<AnimatedCompatibilityScore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCompatibilityScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorFor(int value) {
    if (!widget.colorize) return AppColors.textPrimary;
    if (value >= 80) return AppColors.success;
    if (value >= 55) return AppColors.accent;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.textStyle ?? AppTypography.compatibilityScore;
    final int target = widget.score.clamp(0, 100).toInt();

    if (PairraA11y.of(context).reduceMotion) {
      return Text('$target${widget.showPercentSign ? '%' : ''}',
          style: base.copyWith(color: _colorFor(target)));
    }

    final curved =
        CurvedAnimation(parent: _controller, curve: AppMotion.standard);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final value = (curved.value * target).round();
        return Text(
          '$value${widget.showPercentSign ? '%' : ''}',
          style: base.copyWith(color: _colorFor(value)),
        );
      },
    );
  }
}
