import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/presentation/steps/step_privacy.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/presentation/widgets/edit_section_screen.dart';

/// Privacy overview for the Safety Center. Summarizes what's shared and who can
/// see the user, and makes the location guarantee explicit. Editing routes to
/// the same privacy controls used in onboarding/profile.
class SafetyPrivacyScreen extends ConsumerWidget {
  const SafetyPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(currentProfileProvider);
    final privacy = p.privacy;

    String vis(String field) => p.visibilityOf(field).label;

    final rows = <(String, String)>[
      ('Profile visibility', privacy.profileVisibility.label),
      ('Photo privacy', 'Visible to people who can see your profile'),
      ('Message privacy', 'Only your matches can message you'),
      ('Preference visibility',
          privacy.preferencesVisible ? 'Shown' : 'Hidden'),
      ('Orientation', vis('orientation')),
      ('Compatibility (position)', vis('roles')),
      ('Appear in discovery', privacy.appearInDiscovery ? 'On' : 'Off'),
      ('Show my distance', privacy.showDistance ? 'On' : 'Off'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Privacy', style: AppTypography.headingSmall),
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
            // The location guarantee — prominent and reassuring.
            LiquidGlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_off_outlined,
                      color: AppColors.success, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your location stays private',
                            style: AppTypography.headingSmall),
                        const SizedBox(height: 2),
                        Text(
                          'PAIRRA never shows your exact location to anyone. '
                          'Others only ever see an approximate distance.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassCard(
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _Row(label: rows[i].$1, value: rows[i].$2),
                    if (i < rows.length - 1)
                      const Divider(height: AppSpacing.lg, color: AppColors.border),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassButton(
              label: 'Edit privacy settings',
              icon: Icons.tune,
              expand: true,
              onPressed: () => EditSectionScreen.push(
                context,
                title: 'Privacy',
                child: const StepPrivacy(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyLarge)),
        const SizedBox(width: AppSpacing.md),
        Text(value,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
