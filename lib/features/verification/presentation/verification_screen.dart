import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/verification_providers.dart';
import '../domain/verification_check.dart';
import 'verification_flow_screen.dart';
import 'widgets/verification_check_card.dart';
import 'widgets/verified_badge.dart';

/// The verification hub. Explains why verification exists (without overclaiming
/// safety), gates the checks honestly on whether a provider is connected, and
/// makes the privacy guarantee explicit. Owner-only — a user's verification
/// details are never shown to anyone else; only the resulting status is.
class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  void _open(BuildContext context, VerificationCheckType type) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationFlowScreen(type: type)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(verificationProviderProvider).isConnected;
    final state = ref.watch(verificationStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Verification', style: AppTypography.headingSmall),
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
            // Why verification exists — honest framing.
            LiquidGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Why verify', style: AppTypography.headingSmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Verification helps reduce impersonation and fraudulent '
                    'profiles.',
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'It doesn\'t guarantee anyone is safe — always follow the '
                    'safety basics when you meet someone.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!connected) ...[
              _NotConnectedBanner(),
              const SizedBox(height: AppSpacing.xl),
            ],
            VerificationCheckCard(
              type: VerificationCheckType.photo,
              status: state.photo,
              connected: connected,
              onOpen: () => _open(context, VerificationCheckType.photo),
            ),
            const SizedBox(height: AppSpacing.md),
            VerificationCheckCard(
              type: VerificationCheckType.identity,
              status: state.identity,
              connected: connected,
              onOpen: () => _open(context, VerificationCheckType.identity),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Badge explanation — subtle by design.
            LiquidGlassCard(
              level: GlassLevel.subtle,
              child: Row(
                children: [
                  const VerifiedBadge(size: 26, tooltip: false),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.hasBadge
                              ? 'Your profile is verified'
                              : 'The verified badge',
                          style: AppTypography.bodyLarge,
                        ),
                        Text(
                          state.hasBadge
                              ? 'A subtle badge shows on your profile.'
                              : 'Once verified, a subtle badge appears on your '
                                  'profile — nothing more.',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Privacy guarantee.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Your verification photos and documents are never shown to '
                    'anyone. Only your verification status is ever displayed.',
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotConnectedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      child: Row(
        children: [
          const Icon(Icons.construction_outlined,
              size: 18, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Verification is coming soon. Until a provider is connected, no '
              'one is marked verified.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}
