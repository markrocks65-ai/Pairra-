import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/widgets/legal_documents.dart';
import '../../discovery/presentation/widgets/discovery_filter_sheet.dart';
import '../../notifications/presentation/notification_preferences_screen.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import '../../ai_assistant/presentation/ai_assistant_screen.dart';
import '../../safety/presentation/blocked_list_screen.dart';
import '../../safety/presentation/safety_home_screen.dart';
import '../../subscription/presentation/premium_screen.dart';
import '../../verification/presentation/verification_screen.dart';
import 'accessibility_settings_screen.dart';
import 'account_settings_screen.dart';
import 'delete_account_screen.dart';
import 'help_screen.dart';
import 'privacy_controls_screen.dart';

/// The Settings hub — a single, calm index into every setting and feature.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await LiquidGlassModal.confirm(
      context,
      title: 'Log out?',
      message: 'You can log back in anytime.',
      confirmLabel: 'Log out',
    );
    if (ok == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Settings', style: AppTypography.headingSmall),
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
            _Group(title: 'Account', children: [
              _Row(
                  icon: Icons.person_outline,
                  title: 'Account',
                  onTap: () => _push(context, const AccountSettingsScreen())),
              _Row(
                  icon: Icons.badge_outlined,
                  title: 'Profile',
                  onTap: () => _push(context, const EditProfileScreen())),
              _Row(
                  icon: Icons.explore_outlined,
                  title: 'Discovery',
                  onTap: () => showDiscoveryFilters(context)),
              _Row(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  onTap: () => _push(context, const PrivacyControlsScreen())),
              _Row(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () =>
                      _push(context, const NotificationPreferencesScreen())),
              _Row(
                  icon: Icons.accessibility_new,
                  title: 'Accessibility',
                  onTap: () =>
                      _push(context, const AccessibilitySettingsScreen())),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _Group(title: 'Safety & trust', children: [
              _Row(
                  icon: Icons.shield_outlined,
                  title: 'Safety',
                  onTap: () => _push(context, const SafetyHomeScreen())),
              _Row(
                  icon: Icons.verified_outlined,
                  title: 'Verification',
                  onTap: () => _push(context, const VerificationScreen())),
              _Row(
                  icon: Icons.block,
                  title: 'Blocked users',
                  onTap: () => _push(context, const BlockedListScreen())),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _Group(title: 'Membership', children: [
              _Row(
                  icon: Icons.workspace_premium,
                  title: 'Subscription',
                  onTap: () => _push(context, const PremiumScreen())),
              _Row(
                  icon: Icons.auto_awesome,
                  title: 'AI Assistant',
                  onTap: () => _push(context, const AiAssistantScreen())),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _Group(title: 'About', children: [
              _Row(
                  icon: Icons.help_outline,
                  title: 'Help',
                  onTap: () => _push(context, const HelpScreen())),
              _Row(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => showLegalDocument(context, LegalDoc.terms)),
              _Row(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => showLegalDocument(context, LegalDoc.privacy)),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _Group(children: [
              _Row(
                  icon: Icons.logout,
                  title: 'Log out',
                  onTap: () => _logout(context, ref)),
              _Row(
                  icon: Icons.delete_forever,
                  title: 'Delete account',
                  danger: true,
                  onTap: () => _push(context, const DeleteAccountScreen())),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children, this.title});
  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.xs, bottom: AppSpacing.md),
            child: Text(title!.toUpperCase(), style: AppTypography.label),
          ),
        LiquidGlassCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return PressableScale(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon,
                color: danger ? AppColors.error : AppColors.textSecondary,
                size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Text(title,
                    style: AppTypography.bodyLarge.copyWith(color: color))),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
