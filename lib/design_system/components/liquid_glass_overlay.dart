import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../accessibility/accessibility_scope.dart';
import '../foundations/liquid_glass_surface.dart';

/// Severity of a [LiquidGlassOverlay] notification — drives the accent stripe
/// / icon tint. Kept restrained; `info` is the calm default.
enum OverlayTone { info, success, warning, error }

/// A lightweight glass notification overlay (toast) that slides in from the
/// top, rests over content, and auto-dismisses. Use for transient feedback
/// ("Message sent", "You matched", "Profile updated"). Presented through the
/// app's [Overlay], so it floats above any screen.
abstract final class LiquidGlassOverlay {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    OverlayTone tone = OverlayTone.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _OverlayHost(
        message: message,
        title: title,
        icon: icon,
        tone: tone,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  static Color toneColor(OverlayTone tone) => switch (tone) {
        OverlayTone.info => AppColors.accent,
        OverlayTone.success => AppColors.success,
        OverlayTone.warning => AppColors.warning,
        OverlayTone.error => AppColors.error,
      };
}

class _OverlayHost extends StatefulWidget {
  const _OverlayHost({
    required this.message,
    required this.title,
    required this.icon,
    required this.tone,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final OverlayTone tone;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _controller.forward();
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = PairraA11y.of(context).reduceMotion;
    final accent = LiquidGlassOverlay.toneColor(widget.tone);

    final panel = LiquidGlassSurface(
      level: GlassLevel.prominent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 34,
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20, color: accent),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null) ...[
                  Text(widget.title!, style: AppTypography.headingSmall),
                  const SizedBox(height: 2),
                ],
                Text(widget.message, style: AppTypography.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: reduceMotion
              ? panel
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = CurvedAnimation(
                      parent: _controller,
                      curve: AppMotion.standard,
                    ).value;
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - t)),
                        child: child,
                      ),
                    );
                  },
                  child: panel,
                ),
        ),
      ),
    );
  }
}
