import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/presentation/widgets/onboarding_controls.dart';
import '../application/notifications_controllers.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_type.dart';

/// Notification preferences: per-category Push / Email / In-app switches, quiet
/// hours, and a clearly-separated Safety section (always delivered).
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  static const _categories = [
    NotificationCategory.activity,
    NotificationCategory.marketing,
    NotificationCategory.account,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final controller = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Notification settings', style: AppTypography.headingSmall),
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
            _QuietHoursCard(
              quietHours: prefs.quietHours,
              onChanged: controller.setQuietHours,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SafetyCard(
              prefs: prefs,
              onChannel: controller.setChannel,
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final category in _categories) ...[
              _CategoryCard(
                category: category,
                prefs: prefs,
                onChannel: controller.setChannel,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.prefs,
    required this.onChannel,
  });

  final NotificationCategory category;
  final NotificationPreferences prefs;
  final void Function(NotificationCategory, NotificationChannel, bool) onChannel;

  @override
  Widget build(BuildContext context) {
    final c = prefs.channels(category);
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category.label, style: AppTypography.headingSmall),
          SettingToggleRow(
            title: 'Push',
            value: c.push,
            onChanged: (v) => onChannel(category, NotificationChannel.push, v),
          ),
          SettingToggleRow(
            title: 'Email',
            value: c.email,
            onChanged: (v) => onChannel(category, NotificationChannel.email, v),
          ),
          SettingToggleRow(
            title: 'In-app',
            value: c.inApp,
            onChanged: (v) => onChannel(category, NotificationChannel.inApp, v),
          ),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.prefs, required this.onChannel});

  final NotificationPreferences prefs;
  final void Function(NotificationCategory, NotificationChannel, bool) onChannel;

  @override
  Widget build(BuildContext context) {
    final c = prefs.channels(NotificationCategory.safety);
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 18, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text('Safety', style: AppTypography.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Safety alerts are always delivered in-app and ignore quiet hours. '
            'You can choose extra channels.',
            style: AppTypography.caption,
          ),
          SettingToggleRow(
            title: 'Push',
            value: c.push,
            onChanged: (v) =>
                onChannel(NotificationCategory.safety, NotificationChannel.push, v),
          ),
          SettingToggleRow(
            title: 'Email',
            value: c.email,
            onChanged: (v) => onChannel(
                NotificationCategory.safety, NotificationChannel.email, v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text('In-app', style: AppTypography.bodyLarge),
                ),
                Text('Always on',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietHoursCard extends StatelessWidget {
  const _QuietHoursCard({required this.quietHours, required this.onChanged});

  final QuietHours quietHours;
  final ValueChanged<QuietHours> onChanged;

  String _fmt(int minutes) {
    final h24 = minutes ~/ 60;
    final m = (minutes % 60).toString().padLeft(2, '0');
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h:$m ${h24 < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _pick(BuildContext context, bool start) async {
    final initialMin = start ? quietHours.startMinute : quietHours.endMinute;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialMin ~/ 60, minute: initialMin % 60),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            surface: AppColors.surfaceElevated,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    onChanged(start
        ? quietHours.copyWith(startMinute: minutes)
        : quietHours.copyWith(endMinute: minutes));
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingToggleRow(
            title: 'Quiet hours',
            subtitle: 'Pause non-safety push & email overnight.',
            value: quietHours.enabled,
            onChanged: (v) => onChanged(quietHours.copyWith(enabled: v)),
          ),
          if (quietHours.enabled)
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: 'From',
                    value: _fmt(quietHours.startMinute),
                    onTap: () => _pick(context, true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TimeButton(
                    label: 'To',
                    value: _fmt(quietHours.endMinute),
                    onTap: () => _pick(context, false),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: LiquidGlassSurface(
        level: GlassLevel.subtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        showShadow: false,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption),
            Text(value, style: AppTypography.bodyLarge),
          ],
        ),
      ),
    );
  }
}
