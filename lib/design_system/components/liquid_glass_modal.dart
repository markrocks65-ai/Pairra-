import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../accessibility/accessibility_scope.dart';
import '../foundations/liquid_glass_surface.dart';
import 'liquid_glass_button.dart';

/// A centered Liquid Glass modal / confirmation dialog. Fades and scales in
/// gently over a dark scrim. Use [LiquidGlassModal.show] for arbitrary content
/// or [LiquidGlassModal.confirm] for a standard title/message/confirm-cancel
/// dialog (e.g. block, report, delete confirmations).
abstract final class LiquidGlassModal {
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: AppColors.scrim,
      transitionDuration: AppMotion.base,
      pageBuilder: (context, _, _) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, child) {
        final reduceMotion = PairraA11y.of(context).reduceMotion;
        final curved =
            CurvedAnimation(parent: animation, curve: AppMotion.standard);
        final content = Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: LiquidGlassSurface(
                level: GlassLevel.prominent,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: builder(context),
              ),
            ),
          ),
        );
        if (reduceMotion) return content;
        return FadeTransition(
          opacity: curved,
          child: Transform.scale(
            scale: 0.96 + 0.04 * curved.value,
            child: content,
          ),
        );
      },
    );
  }

  /// A ready-made confirmation dialog. Returns `true` if confirmed, `false`/
  /// `null` if dismissed. [destructive] tints the confirm action with the
  /// error color (for block / report / delete).
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) {
    return show<bool>(
      context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.headingMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.xxl),
          LiquidGlassButton(
            label: confirmLabel,
            expand: true,
            variant: GlassButtonVariant.primary,
            danger: destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.sm),
          LiquidGlassButton(
            label: cancelLabel,
            expand: true,
            variant: GlassButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
