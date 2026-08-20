import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../compatibility/application/compatibility_reasons.dart';
import '../../moderation/application/moderation_service.dart';
import '../../moderation/presentation/report_feedback.dart';
import '../../profile/presentation/widgets/profile_view.dart';
import '../application/discovery_controller.dart';
import '../application/discovery_providers.dart';
import 'widgets/compatibility_breakdown.dart' show CompatibilityHeadline, CompatibilityBreakdown;
import 'widgets/discovery_actions.dart';
import 'widgets/why_card.dart';

/// Full candidate view opened from the Discover card. Shows the "why you're
/// seeing him" reasons, the full compatibility breakdown, and their public
/// profile, plus the same actions (like/pass/maybe/report/block). Acting here
/// pops back to the feed, which then advances.
class CandidateDetailScreen extends ConsumerWidget {
  const CandidateDetailScreen({super.key, required this.scored});

  final ScoredCandidate scored;

  DiscoveryController _c(WidgetRef ref) =>
      ref.read(discoveryControllerProvider.notifier);

  void _like(BuildContext context, WidgetRef ref, String name) {
    final match = _c(ref).like();
    Navigator.of(context).maybePop();
    if (match != null) {
      LiquidGlassOverlay.show(
        context,
        title: 'It\'s a match!',
        message: 'You and $name are ${match.compatibilityPercent}% compatible.',
        icon: Icons.favorite,
        tone: OverlayTone.success,
      );
    }
  }

  Future<void> _block(BuildContext context, WidgetRef ref, String name) async {
    final ok = await LiquidGlassModal.confirm(
      context,
      title: 'Block $name?',
      message: 'They won\'t see your profile or be shown to you again.',
      confirmLabel: 'Block',
      destructive: true,
    );
    if (ok == true) {
      _c(ref).block(scored.candidate.id, name: name);
      if (context.mounted) Navigator.of(context).maybePop();
    }
  }

  void _report(BuildContext context, WidgetRef ref, String name) {
    showReportSheet(
      context,
      name: name,
      onReport: (reason) async {
        final outcome = await ref.read(moderationServiceProvider).reportUser(
            targetId: scored.candidate.id, targetName: name, reason: reason);
        _c(ref).block(scored.candidate.id, name: name);
        if (context.mounted) {
          Navigator.of(context).maybePop();
          showReportFeedback(context, name: name, outcome: outcome);
        }
      },
    );
  }

  void _reportPhoto(BuildContext context, WidgetRef ref, String name) {
    final p = scored.candidate.profile;
    final photoId = p.photos.isNotEmpty ? p.photos.first.id : 'primary';
    showReportSheet(
      context,
      name: '$name\'s photo',
      onReport: (reason) async {
        final outcome = await ref.read(moderationServiceProvider).reportPhoto(
              targetId: scored.candidate.id,
              targetName: name,
              photoId: photoId,
              reason: reason,
            );
        if (context.mounted) {
          showReportFeedback(context, name: name, outcome: outcome);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = scored.candidate.profile;
    final name = (p.displayName ?? 'Someone').trim();
    final reasons = CompatibilityReasons.from(scored.score);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            // Trailing ProfileSections already clears the floating nav bar.
            padding: EdgeInsets.zero,
            children: [
              ProfileHeaderView(
                profile: p,
                mode: ProfileViewMode.publicPreview,
                distanceLabel: scored.distanceKm != null
                    ? '~${scored.distanceKm!.round()} km away'
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WhyCard(reasons: reasons),
                    const SizedBox(height: AppSpacing.lg),
                    LiquidGlassCard(
                      level: GlassLevel.prominent,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          CompatibilityHeadline(score: scored.score),
                          const SizedBox(height: AppSpacing.xl),
                          CompatibilityBreakdown(
                            score: scored.score,
                            explanation: scored.assessment.explanation,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: LiquidGlassButton(
                            label: 'Pass',
                            icon: Icons.close,
                            variant: GlassButtonVariant.glass,
                            onPressed: () {
                              _c(ref).pass();
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: LiquidGlassButton(
                            label: 'Maybe',
                            icon: Icons.bookmark_border,
                            variant: GlassButtonVariant.glass,
                            onPressed: () {
                              _c(ref).maybe();
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: LiquidGlassButton(
                            label: 'Like',
                            icon: Icons.favorite,
                            onPressed: () => _like(context, ref, name),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _report(context, ref, name),
                          icon: const Icon(Icons.flag_outlined,
                              size: 16, color: AppColors.textMuted),
                          label: Text('Report',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        TextButton.icon(
                          onPressed: () => _reportPhoto(context, ref, name),
                          icon: const Icon(Icons.image_outlined,
                              size: 16, color: AppColors.textMuted),
                          label: Text('Report photo',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        TextButton.icon(
                          onPressed: () => _block(context, ref, name),
                          icon: const Icon(Icons.block,
                              size: 16, color: AppColors.textMuted),
                          label: Text('Block',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ProfileSections(profile: p, mode: ProfileViewMode.publicPreview),
            ],
          ),
          SafeArea(
            bottom: false,
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
}
