import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../../profile/presentation/widgets/profile_view.dart';

/// Read-only public profile of the person you're chatting with, opened from the
/// conversation header. Reuses the shared profile renderer in public-preview
/// mode, so it shows exactly what they've chosen to make public.
class ConversationProfilePreview extends StatelessWidget {
  const ConversationProfilePreview({super.key, required this.profile});

  final OnboardingProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              ProfileHeaderView(
                  profile: profile, mode: ProfileViewMode.publicPreview),
              ProfileSections(
                  profile: profile, mode: ProfileViewMode.publicPreview),
            ],
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: PressableScale(
                  pressedScale: 0.9,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: LiquidGlassSurface(
                    level: GlassLevel.standard,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 18, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
