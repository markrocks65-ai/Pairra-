import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';

/// Emergency help — calm, clear guidance for if a situation ever feels unsafe.
/// (Dialing the local emergency number is wired to the OS dialer in production;
/// here it's presented as clear guidance.)
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Emergency help', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.errorWash,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency, color: AppColors.error, size: 26),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('In an immediate emergency',
                            style: AppTypography.headingSmall),
                        const SizedBox(height: 2),
                        Text(
                          'Call your local emergency number (911 in the US) '
                          'right away.',
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('If you ever feel unsafe', style: AppTypography.headingMedium),
            const SizedBox(height: AppSpacing.md),
            for (final step in const [
              ('Get to a public place', 'Move somewhere busy with people around.'),
              ('Reach your trusted contact',
                  'Let the person you told know where you are.'),
              ('Leave whenever you need to',
                  'You never owe anyone an explanation for leaving.'),
              ('Report it when you\'re safe',
                  'You can report the person from their profile or a chat.'),
            ]) ...[
              LiquidGlassCard(
                level: GlassLevel.subtle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.chevron_right,
                        size: 20, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.$1, style: AppTypography.bodyLarge),
                          Text(step.$2,
                              style: AppTypography.bodySecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
