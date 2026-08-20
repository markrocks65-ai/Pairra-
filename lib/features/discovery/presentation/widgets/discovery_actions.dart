import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../safety/domain/report.dart';

/// Opens the "more actions" sheet (View profile / Report / Block). Safety
/// actions are always available and never gated.
Future<void> showMoreActionsSheet(
  BuildContext context, {
  required String name,
  required VoidCallback onViewProfile,
  required VoidCallback onReport,
  required VoidCallback onBlock,
}) {
  return LiquidGlassBottomSheet.show(
    context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionRow(
          icon: Icons.person_outline,
          label: 'View profile',
          onTap: () {
            Navigator.of(context).pop();
            onViewProfile();
          },
        ),
        _ActionRow(
          icon: Icons.flag_outlined,
          label: 'Report $name',
          onTap: () {
            Navigator.of(context).pop();
            onReport();
          },
        ),
        _ActionRow(
          icon: Icons.block,
          label: 'Block $name',
          danger: true,
          onTap: () {
            Navigator.of(context).pop();
            onBlock();
          },
        ),
      ],
    ),
  );
}

/// Opens the report-reason sheet; calls [onReport] with the chosen reason.
Future<void> showReportSheet(
  BuildContext context, {
  required String name,
  required ValueChanged<ReportReason> onReport,
}) {
  return LiquidGlassBottomSheet.show(
    context,
    title: 'Report $name',
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reports are confidential. We\'ll also block them so you won\'t '
            'see each other again.',
            style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.lg),
        for (final reason in ReportReason.values)
          _ActionRow(
            icon: Icons.chevron_right,
            label: reason.label,
            reverse: true,
            onTap: () {
              Navigator.of(context).pop();
              onReport(reason);
            },
          ),
      ],
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.reverse = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    final iconWidget = Icon(icon, size: 20, color: color);
    final labelWidget = Expanded(
      child: Text(label,
          style: AppTypography.bodyLarge.copyWith(color: color)),
    );

    return PressableScale(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: reverse
              ? [labelWidget, iconWidget]
              : [
                  iconWidget,
                  const SizedBox(width: AppSpacing.md),
                  labelWidget,
                ],
        ),
      ),
    );
  }
}
