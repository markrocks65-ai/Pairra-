import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../navigation/app_routes.dart';
import '../../notifications/application/notifications_controllers.dart';
import '../application/profile_providers.dart';
import 'edit_profile_screen.dart';
import 'preview_profile_screen.dart';
import 'widgets/profile_view.dart';

/// My Profile — the Profile tab. The owner's editorial view, with Settings and
/// Notifications in the top bar and Preview / Edit pinned above the nav.
class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  /// Preview stays in-branch so the nav bar remains; [rootLevel] pushes over the
  /// shell for immersive, full-screen flows (the editor).
  void _push(BuildContext context, Widget screen, {bool rootLevel = false}) {
    Navigator.of(context, rootNavigator: rootLevel)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: ProfileView(profile: profile, mode: ProfileViewMode.owner),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  _GlassIcon(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  const Spacer(),
                  _GlassIcon(
                    icon: Icons.notifications_none,
                    label: unread > 0
                        ? 'Notifications, $unread unread'
                        : 'Notifications',
                    badge: unread > 0,
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg,
                  AppSpacing.xl, AppSpacing.navBarClearance),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0005070D), Color(0xF205070D)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LiquidGlassButton(
                      label: 'Preview',
                      icon: Icons.visibility_outlined,
                      variant: GlassButtonVariant.glass,
                      onPressed: () =>
                          _push(context, const PreviewProfileScreen()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: LiquidGlassButton(
                      label: 'Edit profile',
                      icon: Icons.edit_outlined,
                      onPressed: () => _push(context, const EditProfileScreen(),
                          rootLevel: true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({
    required this.icon,
    required this.onTap,
    required this.label,
    this.badge = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.9,
      onTap: onTap,
      semanticLabel: label,
      minTapTarget: const Size.square(48),
      focusBorderRadius: BorderRadius.circular(AppRadius.pill),
      child: LiquidGlassSurface(
        level: GlassLevel.standard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            if (badge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
