import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/notifications_controllers.dart';
import '../domain/app_notification.dart';
import '../domain/notification_type.dart';
import 'notification_preferences_screen.dart';

IconData notificationIcon(NotificationType type) => switch (type) {
      NotificationType.newMatch => Icons.favorite,
      NotificationType.newMessage => Icons.chat_bubble_outline,
      NotificationType.like => Icons.favorite_border,
      NotificationType.dateReminder => Icons.event_outlined,
      NotificationType.subscription => Icons.workspace_premium,
      NotificationType.verification => Icons.verified_outlined,
      NotificationType.safetyCheckIn => Icons.shield_outlined,
      NotificationType.dateSuggestion => Icons.local_bar_outlined,
      NotificationType.profileActivity => Icons.visibility_outlined,
    };

/// The notification inbox. Safety items are visually distinguished (accent
/// shield); tapping marks read. A gear opens preferences.
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Notifications', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (items.any((n) => !n.read))
            TextButton(
              onPressed: () =>
                  ref.read(notificationsControllerProvider.notifier).markAllRead(),
              child: Text('Mark all read',
                  style: AppTypography.buttonSmall
                      .copyWith(color: AppColors.accent)),
            ),
          IconButton(
            icon: const Icon(Icons.tune, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NotificationPreferencesScreen())),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: items.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => _Tile(
                  notification: items[i],
                  onTap: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .markRead(items[i].id),
                ),
              ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  String get _time {
    final d = DateTime.now().difference(notification.createdAt);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final isSafety = notification.type.category.isSafety;
    return PressableScale(
      behavior: HitTestBehavior.opaque,
      pressedScale: 0.99,
      onTap: onTap,
      child: LiquidGlassCard(
        level: notification.read ? GlassLevel.subtle : GlassLevel.standard,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(notificationIcon(notification.type),
                size: 22,
                color: isSafety ? AppColors.success : AppColors.accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(notification.title,
                              style: AppTypography.bodyLarge)),
                      Text(_time, style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(notification.body,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (!notification.read) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text('You\'re all caught up',
                style: AppTypography.headingMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Matches, messages, and reminders will show up here.',
                textAlign: TextAlign.center, style: AppTypography.bodySecondary),
          ],
        ),
      ),
    );
  }
}
