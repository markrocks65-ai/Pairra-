import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../foundations/liquid_glass_surface.dart';
import '../motion/pressable_scale.dart';

/// Button emphasis. PAIRRA CTAs are confident but never aggressive:
///  • [primary]   — a restrained accent fill for the single main action.
///  • [glass]     — a Liquid Glass surface for secondary actions.
///  • [ghost]     — text-only / borderless for tertiary actions.
enum GlassButtonVariant { primary, glass, ghost }

/// The standard PAIRRA button. One component, three emphasis levels, with
/// press feedback, optional leading icon, loading and disabled states, and the
/// same reduced-transparency fallback as the rest of the glass system.
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.loading = false,
    this.danger = false,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final IconData? icon;

  /// Stretch to the full available width.
  final bool expand;

  final bool loading;

  /// Recolors the action with the error token for destructive intents
  /// (block / report / delete).
  final bool danger;

  final double height;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg);

    final content = _Content(
      label: label,
      icon: icon,
      loading: loading,
      color: _foregroundColor,
    );

    Widget body;
    switch (variant) {
      case GlassButtonVariant.primary:
        body = _PrimaryFill(
          radius: radius,
          height: height,
          enabled: _enabled,
          danger: danger,
          child: content,
        );
      case GlassButtonVariant.glass:
        body = LiquidGlassSurface(
          level: GlassLevel.standard,
          borderRadius: radius,
          child: SizedBox(
            height: height,
            child: Center(child: content),
          ),
        );
      case GlassButtonVariant.ghost:
        body = SizedBox(
          height: height,
          child: Center(child: content),
        );
    }

    body = Opacity(opacity: _enabled ? 1.0 : 0.45, child: body);
    if (expand) body = SizedBox(width: double.infinity, child: body);

    return PressableScale(
      onTap: _enabled ? onPressed : null,
      enabled: _enabled,
      pressedOpacity: 0.9,
      child: body,
    );
  }

  Color get _foregroundColor => switch (variant) {
        GlassButtonVariant.primary => AppColors.onAccent,
        GlassButtonVariant.glass => AppColors.textPrimary,
        GlassButtonVariant.ghost =>
          danger ? AppColors.error : AppColors.accent,
      };
}

class _PrimaryFill extends StatelessWidget {
  const _PrimaryFill({
    required this.radius,
    required this.height,
    required this.enabled,
    required this.danger,
    required this.child,
  });

  final BorderRadius radius;
  final double height;
  final bool enabled;
  final bool danger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = danger
        ? const [Color(0xFFE5565B), Color(0xFFCB4045)]
        : const [AppColors.accent, AppColors.accentPressed];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        // A soft neutral shadow for depth — deliberately NOT a colored glow,
        // which reads as a consumer/gaming button rather than a premium one.
        boxShadow: enabled
            ? const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        height: height,
        child: Center(child: child),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.icon,
    required this.loading,
    required this.color,
  });

  final String label;
  final IconData? icon;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: _Spinner(color: color),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTypography.button.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A minimal, dependency-free spinner (avoids pulling Material here).
class _Spinner extends StatefulWidget {
  const _Spinner({required this.color});
  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _c,
      child: CustomPaint(painter: _ArcPainter(widget.color)),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    // ~300° arc so the gap communicates spin.
    canvas.drawArc(rect.deflate(1.5), 0, 5.2, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.color != color;
}
