import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../moderation/application/moderation_service.dart';
import '../../moderation/presentation/report_feedback.dart';
import '../../notifications/application/notification_dispatcher.dart';
import '../../notifications/domain/notification_type.dart';
import '../../subscription/presentation/premium_screen.dart';
import '../application/discovery_controller.dart';
import '../application/discovery_providers.dart';
import 'candidate_detail_screen.dart';
import 'widgets/discover_card.dart';
import 'widgets/discovery_actions.dart';
import 'widgets/discovery_filter_sheet.dart';

/// The Discover section: a premium, one-at-a-time card experience (never a
/// dense grid, never a swipe-stack slot machine). Every recommendation is
/// engine-scored and ranked; actions are deliberate buttons.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  void _openDetail(BuildContext context, ScoredCandidate scored) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CandidateDetailScreen(scored: scored)),
    );
  }

  void _like(BuildContext context, WidgetRef ref, String name) {
    final controller = ref.read(discoveryControllerProvider.notifier);
    // Free like limit reached → show the paywall instead of consuming a like.
    if (!controller.canLike) {
      LiquidGlassOverlay.show(
        context,
        title: 'You\'re out of likes for now',
        message: 'Free likes refresh over time — or go Premium for unlimited.',
        icon: Icons.favorite_border,
      );
      // The paywall is an immersive, full-screen sell — push it over the shell
      // (root navigator) so it isn't framed by the tab nav.
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return;
    }
    final match = controller.like();
    if (match != null) {
      ref.read(notificationDispatcherProvider).dispatch(
            NotificationType.newMatch,
            title: 'New match',
            body: 'You and $name are ${match.compatibilityPercent}% compatible.',
          );
      LiquidGlassOverlay.show(
        context,
        title: 'It\'s a match!',
        message: 'You and $name are ${match.compatibilityPercent}% compatible.',
        icon: Icons.favorite,
        tone: OverlayTone.success,
      );
    }
  }

  void _more(BuildContext context, WidgetRef ref, ScoredCandidate scored) {
    final controller = ref.read(discoveryControllerProvider.notifier);
    final name = (scored.candidate.profile.displayName ?? 'Someone').trim();
    showMoreActionsSheet(
      context,
      name: name,
      onViewProfile: () => _openDetail(context, scored),
      onReport: () => showReportSheet(
        context,
        name: name,
        onReport: (reason) async {
          final outcome = await ref.read(moderationServiceProvider).reportUser(
                targetId: scored.candidate.id,
                targetName: name,
                reason: reason,
              );
          controller.block(scored.candidate.id, name: name);
          if (context.mounted) {
            showReportFeedback(context, name: name, outcome: outcome);
          }
        },
      ),
      onBlock: () async {
        final ok = await LiquidGlassModal.confirm(
          context,
          title: 'Block $name?',
          message: 'They won\'t see your profile or be shown to you again.',
          confirmLabel: 'Block',
          destructive: true,
        );
        if (ok == true) controller.block(scored.candidate.id, name: name);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              filterCount: state.filters.activeCount,
              onFilters: () => showDiscoveryFilters(context),
            ),
            Expanded(child: _content(context, ref, state)),
            if (state.current != null)
              _ActionBar(
                onPass: () =>
                    ref.read(discoveryControllerProvider.notifier).pass(),
                onMaybe: () =>
                    ref.read(discoveryControllerProvider.notifier).maybe(),
                onLike: () => _like(
                    context,
                    ref,
                    (state.current!.candidate.profile.displayName ?? 'Someone')
                        .trim()),
                onMore: () => _more(context, ref, state.current!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, DiscoveryState state) {
    if (state.loading) {
      return const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.accent),
      );
    }
    if (state.current == null) {
      return _EmptyState(filtersActive: !state.filters.isDefault);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: DiscoverCard(
        scored: state.current!,
        onViewProfile: () => _openDetail(context, state.current!),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.filterCount, required this.onFilters});

  final int filterCount;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Text('Discover', style: AppTypography.headingMedium),
          const Spacer(),
          PressableScale(
            pressedScale: 0.94,
            onTap: onFilters,
            child: LiquidGlassSurface(
              level: GlassLevel.standard,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune, size: 16, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Filters', style: AppTypography.buttonSmall),
                  if (filterCount > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text('$filterCount',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.onAccent)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onPass,
    required this.onMaybe,
    required this.onLike,
    required this.onMore,
  });

  final VoidCallback onPass;
  final VoidCallback onMaybe;
  final VoidCallback onLike;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Extra bottom space so the actions sit above the floating nav bar.
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.navBarClearance),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircleAction(
              icon: Icons.close, onTap: onPass, tooltip: 'Pass'),
          _CircleAction(
              icon: Icons.bookmark_border, onTap: onMaybe, tooltip: 'Maybe'),
          _CircleAction(
              icon: Icons.favorite,
              onTap: onLike,
              primary: true,
              size: 68,
              tooltip: 'Like'),
          _CircleAction(
              icon: Icons.more_horiz, onTap: onMore, tooltip: 'More'),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.primary = false,
    this.size = 56,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool primary;
  final double size;

  @override
  Widget build(BuildContext context) {
    final child = primary
        ? Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accent, AppColors.accentPressed],
              ),
              boxShadow: [
                BoxShadow(
                    color: Color(0x556E8BFF),
                    blurRadius: 24,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Icon(icon, color: AppColors.onAccent, size: 28),
          )
        : LiquidGlassSurface(
            level: GlassLevel.standard,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: AppColors.textPrimary, size: 24),
            ),
          );

    return Tooltip(
      message: tooltip,
      child: PressableScale(pressedScale: 0.9, onTap: onTap, child: child),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtersActive});
  final bool filtersActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filtersActive ? Icons.filter_alt_off_outlined : Icons.done_all,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              filtersActive ? 'No one matches your filters' : 'You\'re all caught up',
              style: AppTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              filtersActive
                  ? 'Try widening your filters to see more people.'
                  : 'We\'ll line up more compatible people as they join.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
