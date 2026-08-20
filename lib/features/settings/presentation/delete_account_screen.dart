import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../onboarding/presentation/widgets/onboarding_controls.dart';
import '../application/account_deletion_service.dart';

/// Permanent account deletion — clear, serious, and honest that it can't be
/// undone. Filing it hands off to the server-side deletion workflow (not a
/// deactivation).
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _reason = TextEditingController();
  bool _understood = false;
  bool _deleting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final confirmed = await LiquidGlassModal.confirm(
      context,
      title: 'Delete account permanently?',
      message:
          'This can\'t be undone. Your profile, matches, and messages will be '
          'permanently removed.',
      confirmLabel: 'Delete forever',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    await ref.read(accountDeletionServiceProvider).deleteAccount(
        reason: _reason.text.trim().isEmpty ? null : _reason.text.trim());
    // Auth is now signed out → the router redirects to Welcome. Remove any
    // imperatively-pushed screens so we don't sit on top of it.
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Delete account', style: AppTypography.headingSmall),
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
            Text('We\'re sorry to see you go.',
                style: AppTypography.headingMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Deleting your account permanently removes your profile, photos, '
              'matches, and messages. This is not a pause or deactivation — it '
              'can\'t be undone.',
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            LiquidGlassCard(
              level: GlassLevel.subtle,
              child: Text(
                'A small amount of information may be retained or anonymized '
                'where required (for example, safety and moderation records, or '
                'to meet legal obligations), in line with our data-retention '
                'policy.',
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassTextField(
              controller: _reason,
              label: 'Anything we could have done better? (optional)',
              hint: 'Your feedback helps us improve',
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            LiquidGlassCard(
              child: SettingToggleRow(
                title: 'I understand this is permanent',
                subtitle: 'My account and data will be deleted and can\'t be '
                    'recovered.',
                value: _understood,
                onChanged: (v) => setState(() => _understood = v),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            LiquidGlassButton(
              label: 'Delete my account',
              icon: Icons.delete_forever,
              danger: true,
              expand: true,
              loading: _deleting,
              onPressed: (_understood && !_deleting) ? _delete : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            LiquidGlassButton(
              label: 'Keep my account',
              variant: GlassButtonVariant.ghost,
              expand: true,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
