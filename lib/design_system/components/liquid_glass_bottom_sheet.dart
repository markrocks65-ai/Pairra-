import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/glass_style.dart';
import '../foundations/liquid_glass_surface.dart';

/// A Liquid Glass bottom sheet — the standard PAIRRA surface for filters,
/// quick actions and contextual choices. Presents from the bottom over a dark
/// scrim, with a grabber handle and rounded top corners.
///
/// Use [LiquidGlassBottomSheet.show] to present; the content you pass is laid
/// out inside the glass panel. Set [isScrollControlled] for tall content.
abstract final class LiquidGlassBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      elevation: 0,
      builder: (context) => _Panel(title: title, child: builder(context)),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final radius = const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: LiquidGlassSurface(
        level: GlassLevel.prominent,
        borderRadius: radius,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grabber handle.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              if (title != null) ...[
                Text(title!, style: AppTypography.headingMedium),
                const SizedBox(height: AppSpacing.lg),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
