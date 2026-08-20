import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../profile/presentation/widgets/profile_photo_view.dart';
import '../application/matches_controller.dart';
import '../domain/match.dart';
import 'match_detail_screen.dart';

/// The Matches list — people you've mutually liked, most recent first. Tapping
/// one opens the full compatibility breakdown and their public profile.
class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Matches', style: AppTypography.headingMedium),
      ),
      body: SafeArea(
        top: false,
        child: matches.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl,
                    AppSpacing.xl, AppSpacing.navBarClearance),
                itemCount: matches.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => _MatchTile(match: matches[i]),
              ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final name = match.profile.displayName ?? 'Match';
    final age = match.profile.age;
    final seed = match.profile.photos.isNotEmpty
        ? match.profile.photos.first.placeholderSeed
        : 'p1';

    return PressableScale(
      pressedScale: 0.98,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MatchDetailScreen(match: match)),
      ),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 64,
                height: 64,
                child: ProfilePhotoView(seed: seed, showMonogram: false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(age != null ? '$name, $age' : name,
                      style: AppTypography.headingSmall),
                  const SizedBox(height: 2),
                  Text('${match.compatibilityPercent}% compatible',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.accent)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xs),
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
            const Icon(Icons.favorite_border,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text('No matches yet',
                style: AppTypography.headingMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Like people in Discover — when it\'s mutual, they\'ll show '
                'up here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary),
          ],
        ),
      ),
    );
  }
}
