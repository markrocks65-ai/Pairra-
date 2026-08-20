import 'package:flutter/widgets.dart';

import '../../theme/app_spacing.dart';
import '../../theme/glass_style.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';

/// The workhorse glass container: profile cards, compatibility cards, premium
/// feature cards, date-recommendation cards. Optionally tappable (adds press
/// feedback). Built entirely on [LiquidGlassSurface] so it inherits the
/// reduced-transparency fallback for free.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.level = GlassLevel.standard,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.showShadow = true,
  });

  final Widget child;
  final GlassLevel level;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.lg);

    final surface = LiquidGlassSurface(
      level: level,
      borderRadius: radius,
      padding: padding,
      showShadow: showShadow,
      child: child,
    );

    if (onTap == null && onLongPress == null) return surface;

    return PressableScale(
      onTap: onTap,
      onLongPress: onLongPress,
      child: surface,
    );
  }
}
