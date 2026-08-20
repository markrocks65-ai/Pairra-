import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../safety/domain/report.dart';

/// The conversation safety menu: Report, Block, Unmatch, and Safety tips. All
/// are always available and never gated.
Future<void> showConversationSafetySheet(
  BuildContext context, {
  required String name,
  required VoidCallback onReport,
  required VoidCallback onBlock,
  required VoidCallback onUnmatch,
  required VoidCallback onSafetyTips,
}) {
  return LiquidGlassBottomSheet.show(
    context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Row(
          icon: Icons.tips_and_updates_outlined,
          label: 'Safety tips',
          onTap: () {
            Navigator.of(context).pop();
            onSafetyTips();
          },
        ),
        _Row(
          icon: Icons.link_off,
          label: 'Unmatch $name',
          onTap: () {
            Navigator.of(context).pop();
            onUnmatch();
          },
        ),
        _Row(
          icon: Icons.flag_outlined,
          label: 'Report $name',
          onTap: () {
            Navigator.of(context).pop();
            onReport();
          },
        ),
        _Row(
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

Future<void> showReportReasonsSheet(
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
          _Row(
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

Future<void> showSafetyTips(BuildContext context) {
  const tips = [
    ('Meet in public', 'Choose a busy public place for a first meet-up.'),
    ('Tell a friend', 'Share where you\'re going and who you\'re meeting.'),
    ('Keep your address private', 'Don\'t share your home until you trust them.'),
    ('Arrange your own transport', 'So you can leave whenever you want to.'),
    ('Trust your gut', 'If something feels off, it\'s okay to leave.'),
  ];
  return LiquidGlassBottomSheet.show(
    context,
    title: 'Dating safety',
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (title, body) in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 18, color: AppColors.success),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyLarge),
                      Text(body, style: AppTypography.bodySecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
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
      child: Text(label, style: AppTypography.bodyLarge.copyWith(color: color)),
    );
    return PressableScale(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: reverse
              ? [labelWidget, iconWidget]
              : [iconWidget, const SizedBox(width: AppSpacing.md), labelWidget],
        ),
      ),
    );
  }
}
