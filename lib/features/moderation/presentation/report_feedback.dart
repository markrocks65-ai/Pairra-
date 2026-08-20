import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../safety/presentation/emergency_screen.dart';
import '../application/moderation_service.dart';

/// Shows the right feedback after a report. Normal reports get a quiet,
/// confidential confirmation. Escalated (severe) reports show a supportive
/// prompt with a direct path to safety resources — without ever implying blame
/// or revealing anything about the report queue.
void showReportFeedback(
  BuildContext context, {
  required String name,
  required ReportOutcome outcome,
}) {
  if (!outcome.escalated) {
    LiquidGlassOverlay.show(
      context,
      title: 'Thanks for letting us know',
      message: 'Your report is confidential and our team will review it.',
      icon: Icons.shield_outlined,
    );
    return;
  }

  LiquidGlassModal.show(
    context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield_outlined, color: AppColors.accent, size: 28),
        const SizedBox(height: AppSpacing.md),
        Text('Thank you — we\'re prioritizing this',
            style: AppTypography.headingMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your report is confidential and goes to our team right away. If you '
          'feel unsafe or in danger, please get help now.',
          style: AppTypography.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xl),
        LiquidGlassButton(
          label: 'Get help',
          icon: Icons.emergency_outlined,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        LiquidGlassButton(
          label: 'Close',
          variant: GlassButtonVariant.ghost,
          expand: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
