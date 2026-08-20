import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';

/// Accessibility & display settings — surfaces the controls that the whole
/// design system already honors: reduced motion, reduced transparency, high
/// contrast, and a performance-minded "reduce visual effects" for lower-end
/// devices. Each is tri-state (Auto follows the OS) so nothing here fights the
/// system settings unless the user explicitly overrides.
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityControllerProvider);
    final controller = ref.read(accessibilityControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Accessibility', style: AppTypography.headingSmall),
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
              child: Text(
                'These follow your device settings by default. Override any of '
                'them here if you prefer.',
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PreferenceRow(
              title: 'Reduce motion',
              subtitle: 'Minimize animations and transitions.',
              value: settings.reduceMotion,
              onChanged: controller.setReduceMotion,
            ),
            _PreferenceRow(
              title: 'Reduce transparency',
              subtitle: 'Render glass surfaces as solid for legibility.',
              value: settings.reduceTransparency,
              onChanged: controller.setReduceTransparency,
            ),
            _PreferenceRow(
              title: 'High contrast',
              subtitle: 'Strengthen borders and separators.',
              value: settings.highContrast,
              onChanged: controller.setHighContrast,
            ),
            _PreferenceRow(
              title: 'Reduce visual effects',
              subtitle:
                  'Drop backdrop blur for smoother performance and battery '
                  'on lower-end devices.',
              value: settings.reduceEffects,
              onChanged: controller.setReduceEffects,
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled tri-state (Auto / On / Off) selector for one accessibility
/// preference.
class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final A11yPreference value;
  final ValueChanged<A11yPreference> onChanged;

  static const _labels = {
    A11yPreference.system: 'Auto',
    A11yPreference.on: 'On',
    A11yPreference.off: 'Off',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: LiquidGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headingSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final p in A11yPreference.values)
                  LiquidGlassChip(
                    label: _labels[p]!,
                    selected: p == value,
                    onTap: () => onChanged(p),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
