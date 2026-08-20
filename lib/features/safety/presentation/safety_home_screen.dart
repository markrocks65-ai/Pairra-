import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/safety_plan_controller.dart';
import '../domain/safety_content.dart';
import '../domain/safety_plan.dart';
import 'blocked_list_screen.dart';
import 'emergency_screen.dart';
import 'report_screen.dart';
import 'safety_article_screen.dart';
import 'safety_plan_screen.dart';
import 'safety_privacy_screen.dart';

/// The Safety Center home — a calm, supportive hub. Surfaces any pending
/// check-in first, then the safety-plan CTA, then the sections.
class SafetyHomeScreen extends ConsumerWidget {
  const SafetyHomeScreen({super.key});

  void _push(BuildContext context, Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(safetyPlansProvider);
    final pending = plans.where((p) => p.hasPendingCheckIn).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Safety Center', style: AppTypography.headingSmall),
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
            Text(
              'We\'ve got your back. A few simple habits keep dating fun and '
              'comfortable.',
              style: AppTypography.bodyLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final p in pending) ...[
              _CheckInCard(
                plan: p,
                onSafe: () =>
                    ref.read(safetyPlansProvider.notifier).markSafe(p.id),
                onHelp: () => _push(context, const EmergencyScreen()),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            LiquidGlassButton(
              label: 'Create a safety plan',
              icon: Icons.add_location_alt_outlined,
              expand: true,
              onPressed: () => _push(context, const SafetyPlanScreen()),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Group(children: [
              for (final a in SafetyContent.all)
                _Row(
                  icon: _articleIcon(a.id),
                  title: a.title,
                  subtitle: a.intro,
                  onTap: () =>
                      _push(context, SafetyArticleScreen(article: a)),
                ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _Group(children: [
              _Row(
                icon: Icons.flag_outlined,
                title: 'Report someone',
                subtitle: 'Tell us about harassment, scams, and more.',
                onTap: () => _push(context, const ReportScreen()),
              ),
              _Row(
                icon: Icons.block,
                title: 'Block someone',
                subtitle: 'Manage who can\'t reach you.',
                onTap: () => _push(context, const BlockedListScreen()),
              ),
              _Row(
                icon: Icons.lock_outline,
                title: 'Privacy',
                subtitle: 'Control what you share and who sees you.',
                onTap: () => _push(context, const SafetyPrivacyScreen()),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _Group(children: [
              _Row(
                icon: Icons.emergency_outlined,
                title: 'Emergency help',
                subtitle: 'What to do if you ever feel unsafe.',
                danger: true,
                onTap: () => _push(context, const EmergencyScreen()),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  IconData _articleIcon(String id) => switch (id) {
        'before' => Icons.checklist_rtl,
        'during' => Icons.favorite_outline,
        _ => Icons.done_all,
      };
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard(
      {required this.plan, required this.onSafe, required this.onHelp});

  final SafetyPlan plan;
  final VoidCallback onSafe;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.prominent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Checking in', style: AppTypography.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'How\'s your date with ${plan.meetingName}? Let us know you\'re '
            'okay — no rush.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: LiquidGlassButton(
                  label: 'I\'m safe',
                  icon: Icons.check,
                  onPressed: onSafe,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LiquidGlassButton(
                  label: 'Get help',
                  variant: GlassButtonVariant.glass,
                  danger: true,
                  onPressed: onHelp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.accent;
    return PressableScale(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyLarge),
                  Text(subtitle,
                      style: AppTypography.caption, maxLines: 2),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
