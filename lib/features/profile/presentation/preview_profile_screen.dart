import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/profile_providers.dart';
import 'widgets/privacy_indicator.dart';
import 'widgets/profile_view.dart';

/// Preview — shows the profile exactly as a non-matched viewer sees it (public
/// fields only), so users can trust what they're sharing. A privacy indicator
/// (what's public vs hidden) is one tap away.
class PreviewProfileScreen extends ConsumerWidget {
  const PreviewProfileScreen({super.key});

  void _showPrivacy(BuildContext context, WidgetRef ref) {
    final profile = ref.read(currentProfileProvider);
    LiquidGlassBottomSheet.show(
      context,
      title: 'Your public info',
      builder: (context) => SingleChildScrollView(
        child: PrivacyIndicator(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  PressableScale(
                    pressedScale: 0.9,
                    onTap: () => Navigator.of(context).maybePop(),
                    semanticLabel: 'Back',
                    minTapTarget: const Size.square(48),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 18, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text('How others see you',
                        style: AppTypography.headingSmall),
                  ),
                  PressableScale(
                    pressedScale: 0.92,
                    onTap: () => _showPrivacy(context, ref),
                    child: LiquidGlassSurface(
                      level: GlassLevel.subtle,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      showShadow: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 15, color: AppColors.accent),
                          const SizedBox(width: AppSpacing.xs),
                          Text('What\'s public',
                              style: AppTypography.buttonSmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ProfileView(
              profile: profile,
              mode: ProfileViewMode.publicPreview,
            ),
          ),
        ],
      ),
    );
  }
}
