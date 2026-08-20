import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../notifications/application/notification_dispatcher.dart';
import '../../notifications/domain/notification_type.dart';
import '../application/subscription_controller.dart';
import '../domain/premium_feature.dart';
import '../domain/subscription_models.dart';
import 'widgets/premium_bits.dart';

/// PAIRRA Premium — the paywall (when free) or the subscription status (when
/// premium). Dark-luxury, Liquid Glass, and deliberately non-predatory: no
/// countdown timers, no "find love if you pay", and the free tier is framed as
/// genuinely useful.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  String? _selectedId;

  Future<void> _purchase(SubscriptionPackage package) async {
    final result =
        await ref.read(subscriptionControllerProvider.notifier).purchase(package);
    if (result.isSuccess && mounted) {
      ref.read(notificationDispatcherProvider).dispatch(
            NotificationType.subscription,
            title: 'Welcome to Premium',
            body: result.message ?? 'Your premium features are unlocked.',
          );
      LiquidGlassOverlay.show(
        context,
        title: 'Welcome to Premium',
        message: result.message ?? 'Your premium features are unlocked.',
        icon: Icons.workspace_premium,
        tone: OverlayTone.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: state.isPremium ? _status(state) : _paywall(state),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassIconButton(
                  icon: Icons.arrow_back_ios_new,
                  semanticLabel: 'Back',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Paywall --------------------------------------------------------------

  Widget _paywall(SubscriptionState state) {
    final offerings = state.offerings;
    final selected = offerings.isEmpty
        ? null
        : offerings.firstWhere((p) => p.id == _selectedId,
            orElse: () => offerings.first);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.giant, AppSpacing.xl, AppSpacing.xxl),
      children: [
        const Icon(Icons.workspace_premium, color: AppColors.accent, size: 40),
        const SizedBox(height: AppSpacing.md),
        Text('PAIRRA Premium', style: AppTypography.headingLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'More ways to connect with the people you\'re most compatible with. '
          'Everything you already love stays free.',
          style: AppTypography.bodyLarge
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (!state.isConfigured) ...[
          _DevBanner(),
          const SizedBox(height: AppSpacing.lg),
        ],
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What\'s included', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              for (final f in PremiumFeature.values)
                PremiumFeatureTile(feature: f),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Choose a plan', style: AppTypography.label),
        const SizedBox(height: AppSpacing.md),
        if (state.loadingOfferings)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accent),
            ),
          )
        else
          for (final p in offerings) ...[
            PackageOption(
              package: p,
              selected: selected?.id == p.id,
              onTap: () => setState(() => _selectedId = p.id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        if (selected != null && selected.isSamplePricing)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text('Sample pricing shown — real prices load from the store.',
                style: AppTypography.caption),
          ),
        const SizedBox(height: AppSpacing.md),
        LiquidGlassButton(
          label: 'Continue',
          expand: true,
          loading: state.purchasing,
          onPressed: (selected == null || state.purchasing)
              ? null
              : () => _purchase(selected),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: GestureDetector(
            onTap: () =>
                ref.read(subscriptionControllerProvider.notifier).restore(),
            child: Text('Restore purchases',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.accent)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Cancel anytime. The free experience stays fully useful — there\'s no '
          'pressure, and premium doesn\'t promise you\'ll meet someone. Safety '
          'tools are always free.',
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  // --- Status ---------------------------------------------------------------

  Widget _status(SubscriptionState state) {
    final e = state.entitlement;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.giant, AppSpacing.xl, AppSpacing.xxl),
      children: [
        Row(
          children: [
            const Icon(Icons.workspace_premium,
                color: AppColors.accent, size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('You\'re on PAIRRA Premium',
                  style: AppTypography.headingMedium),
            ),
          ],
        ),
        if (e.isDevGrant) ...[
          const SizedBox(height: AppSpacing.md),
          _DevBanner(
              text:
                  'Development entitlement — granted for testing gated features. '
                  'No real purchase was made.'),
        ],
        const SizedBox(height: AppSpacing.xl),
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (e.expiresAt != null)
                _statusRow('Renews / expires',
                    '${e.expiresAt!.year}-${e.expiresAt!.month.toString().padLeft(2, '0')}-${e.expiresAt!.day.toString().padLeft(2, '0')}'),
              _statusRow('Auto-renew', e.willRenew ? 'On' : 'Off'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your premium features', style: AppTypography.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              for (final f in PremiumFeature.values)
                PremiumFeatureTile(feature: f),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Manage or cancel anytime in your App Store / Google Play account.',
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyLarge)),
          Text(value,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DevBanner extends StatelessWidget {
  const _DevBanner({this.text});
  final String? text;

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
              text ??
                  'Development build — purchases aren\'t live yet. Prices shown '
                      'are samples, and no real charge is made.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.3,
            colors: [Color(0xFF20264A), AppColors.background],
            stops: [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}
