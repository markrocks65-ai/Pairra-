import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../compatibility/application/compatibility_providers.dart';
import '../../compatibility/data/compatibility_profile_mapper.dart';
import '../../messaging/presentation/conversation_screen.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/presentation/widgets/profile_view.dart';
import '../domain/match.dart';
import 'widgets/compatibility_breakdown.dart';

/// A match's full detail: the compatibility breakdown (recomputed from the
/// engine) over their public profile, with a shortcut into the conversation.
class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(compatibilityServiceProvider);
    final self = ref.watch(currentProfileProvider);
    final assessment = service.evaluate(
      CompatibilityProfileMapper.fromOnboarding(self, id: 'self'),
      CompatibilityProfileMapper.fromOnboarding(match.profile, id: match.id),
    );

    final name = match.profile.displayName ?? 'Match';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            // Trailing ProfileSections already clears the floating nav bar.
            padding: EdgeInsets.zero,
            children: [
              ProfileHeaderView(
                  profile: match.profile, mode: ProfileViewMode.publicPreview),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: LiquidGlassCard(
                  level: GlassLevel.prominent,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      CompatibilityHeadline(score: assessment.score),
                      const SizedBox(height: AppSpacing.xl),
                      CompatibilityBreakdown(
                        score: assessment.score,
                        explanation: assessment.explanation,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LiquidGlassButton(
                        label: 'Message $name',
                        icon: Icons.chat_bubble_outline,
                        variant: GlassButtonVariant.glass,
                        expand: true,
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ConversationScreen(conversationId: match.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ProfileSections(
                  profile: match.profile, mode: ProfileViewMode.publicPreview),
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
