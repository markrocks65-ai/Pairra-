import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/safety_controllers.dart';

/// Manage blocked users. Blocking takes effect immediately — a blocked person
/// can't see the user's profile or message them.
class BlockedListScreen extends ConsumerWidget {
  const BlockedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Blocked', style: AppTypography.headingSmall),
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
            LiquidGlassCard(
              level: GlassLevel.subtle,
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Blocking takes effect immediately. A blocked person '
                      'can\'t see your profile or message you.',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (blocked.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.giant),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.block,
                          size: 44, color: AppColors.textMuted),
                      const SizedBox(height: AppSpacing.md),
                      Text('No one blocked',
                          style: AppTypography.headingSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text('People you block will appear here.',
                          style: AppTypography.bodySecondary),
                    ],
                  ),
                ),
              )
            else
              for (final b in blocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: LiquidGlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.person_off_outlined,
                            color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(b.displayName,
                              style: AppTypography.bodyLarge),
                        ),
                        LiquidGlassButton(
                          label: 'Unblock',
                          variant: GlassButtonVariant.glass,
                          height: 40,
                          onPressed: () => ref
                              .read(blockedProfilesProvider.notifier)
                              .unblock(b.id),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
