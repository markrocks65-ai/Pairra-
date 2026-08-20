import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../../onboarding/presentation/widgets/onboarding_controls.dart';
import '../../profile/application/profile_providers.dart';

/// Privacy controls — the full set from Settings. Writes to the shared profile
/// draft (persisted). Includes the explicit location guarantee.
class PrivacyControlsScreen extends ConsumerWidget {
  const PrivacyControlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacy = ref.watch(currentProfileProvider).privacy;
    final onboarding = ref.read(onboardingControllerProvider.notifier);

    void update(PrivacySettings Function(PrivacySettings) mutate) =>
        onboarding.update((p) => p.copyWith(privacy: mutate(p.privacy)));

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
            LiquidGlassCard(
              level: GlassLevel.subtle,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_off_outlined,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'PAIRRA never shows your exact location. Others only ever '
                      'see an approximate distance.',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Who can see your profile',
                      style: AppTypography.headingSmall),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final v in FieldVisibility.values)
                        LiquidGlassChip(
                          label: v.label,
                          selected: v == privacy.profileVisibility,
                          onTap: () =>
                              update((p) => p.copyWith(profileVisibility: v)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LiquidGlassCard(
              child: Column(
                children: [
                  SettingToggleRow(
                    title: 'Distance visibility',
                    subtitle: 'Show approximate distance on your profile.',
                    value: privacy.showDistance,
                    onChanged: (v) => update((p) => p.copyWith(showDistance: v)),
                  ),
                  SettingToggleRow(
                    title: 'Preference visibility',
                    subtitle: 'Let others see what you\'re looking for.',
                    value: privacy.preferencesVisible,
                    onChanged: (v) =>
                        update((p) => p.copyWith(preferencesVisible: v)),
                  ),
                  SettingToggleRow(
                    title: 'Online status',
                    subtitle: 'Show an "active recently" indicator.',
                    value: privacy.showOnlineStatus,
                    onChanged: (v) =>
                        update((p) => p.copyWith(showOnlineStatus: v)),
                  ),
                  SettingToggleRow(
                    title: 'Discovery participation',
                    subtitle: 'Appear in discovery. Off = browse privately.',
                    value: privacy.appearInDiscovery,
                    onChanged: (v) =>
                        update((p) => p.copyWith(appearInDiscovery: v)),
                  ),
                  SettingToggleRow(
                    title: 'Message requests',
                    subtitle:
                        'Allow messages from people you haven\'t matched with.',
                    value: privacy.allowMessageRequests,
                    onChanged: (v) =>
                        update((p) => p.copyWith(allowMessageRequests: v)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
