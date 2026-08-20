import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../auth/application/auth_controller.dart';

/// Account details — the user's own info (read-only for now). Editing email /
/// password routes to the auth provider later.
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    String date(DateTime? d) => d == null
        ? '—'
        : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Account', style: AppTypography.headingSmall),
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
              child: Column(
                children: [
                  _Row(label: 'Email', value: user?.email ?? '—'),
                  const Divider(color: AppColors.border, height: AppSpacing.lg),
                  _Row(
                    label: 'Email verified',
                    value: (user?.emailVerified ?? false) ? 'Yes' : 'No',
                  ),
                  const Divider(color: AppColors.border, height: AppSpacing.lg),
                  _Row(
                    label: 'Phone verified',
                    value: (user?.phoneVerified ?? false) ? 'Yes' : 'No',
                  ),
                  const Divider(color: AppColors.border, height: AppSpacing.lg),
                  _Row(label: 'Member since', value: date(user?.createdAt)),
                ],
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
        Text(value,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
