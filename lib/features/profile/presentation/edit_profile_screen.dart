import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/presentation/steps/step_date_prefs.dart';
import '../../onboarding/presentation/steps/step_identity.dart';
import '../../onboarding/presentation/steps/step_interests.dart';
import '../../onboarding/presentation/steps/step_intentions.dart';
import '../../onboarding/presentation/steps/step_looking_for.dart';
import '../../onboarding/presentation/steps/step_privacy.dart';
import '../../onboarding/presentation/steps/step_roles.dart';
import '../../verification/presentation/verification_screen.dart';
import 'bio_editor_screen.dart';
import 'photo_manager_screen.dart';
import 'widgets/edit_section_screen.dart';

/// Edit Profile — a calm menu of sections. Media and bio have dedicated
/// editors; the rest reuse the exact onboarding step widgets (which read/write
/// the same shared draft and auto-persist), so editing and onboarding can never
/// disagree.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Edit profile', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.giant),
          children: [
            _group(context, 'Profile', [
              _Row(
                icon: Icons.photo_library_outlined,
                title: 'Photos',
                subtitle: 'Add, remove and reorder',
                onTap: () => _push(context, const PhotoManagerScreen()),
              ),
              _Row(
                icon: Icons.edit_note,
                title: 'Bio',
                subtitle: 'Your short intro',
                onTap: () => _push(context, const BioEditorScreen()),
              ),
              _Row(
                icon: Icons.interests_outlined,
                title: 'Interests',
                subtitle: 'What you love',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Interests', child: const StepInterests()),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _group(context, 'Dating', [
              _Row(
                icon: Icons.favorite_border,
                title: 'Dating intent',
                subtitle: 'What you\'re here for',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Dating intent', child: const StepIntentions()),
              ),
              _Row(
                icon: Icons.tune,
                title: 'Compatibility',
                subtitle: 'Sensitive — private by default',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Compatibility', child: const StepRoles()),
              ),
              _Row(
                icon: Icons.search,
                title: 'Preferences',
                subtitle: 'What you\'re looking for',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Preferences', child: const StepLookingFor()),
              ),
              _Row(
                icon: Icons.local_bar_outlined,
                title: 'Date preferences',
                subtitle: 'First dates & budget',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Date preferences', child: const StepDatePrefs()),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _group(context, 'Identity & privacy', [
              _Row(
                icon: Icons.person_outline,
                title: 'Identity',
                subtitle: 'Gender, orientation & visibility',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Identity', child: const StepIdentity()),
              ),
              _Row(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'Who sees what',
                onTap: () => EditSectionScreen.push(context,
                    title: 'Privacy', child: const StepPrivacy()),
              ),
              _Row(
                icon: Icons.verified_outlined,
                title: 'Verification',
                subtitle: 'Photo & identity (coming soon)',
                onTap: () => _push(context, const VerificationScreen()),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _group(BuildContext context, String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.md),
          child: Text(title.toUpperCase(), style: AppTypography.label),
        ),
        LiquidGlassCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyLarge),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
