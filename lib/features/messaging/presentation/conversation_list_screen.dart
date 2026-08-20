import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../profile/presentation/widgets/profile_photo_view.dart';
import '../application/messaging_providers.dart';
import '../domain/conversation.dart';
import 'conversation_screen.dart';

/// The Messages tab: a clean list of conversations (one per match), most recent
/// first. Not decorative — avatar, name, a one-line preview, and an unread dot.
class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(messagingControllerProvider).ordered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Messages', style: AppTypography.headingMedium),
      ),
      body: SafeArea(
        top: false,
        child: conversations.isEmpty
            ? _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg,
                    AppSpacing.lg, AppSpacing.navBarClearance),
                itemCount: conversations.length,
                itemBuilder: (context, i) =>
                    _ConversationTile(conversation: conversations[i]),
              ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});
  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final seed = c.otherProfile.photos.isNotEmpty
        ? c.otherProfile.photos.first.placeholderSeed
        : 'p1';
    final last = c.lastMessage;
    final preview = last == null
        ? 'Say hello'
        : (last.isSystem
            ? 'You matched — start the conversation'
            : (last.isMine ? 'You: ${last.text}' : (last.text ?? '')));

    return PressableScale(
      behavior: HitTestBehavior.opaque,
      pressedScale: 0.98,
      // A chat is immersive (its own header + composer), so it goes full-screen
      // over the shell rather than being framed by the tab nav.
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ConversationScreen(conversationId: c.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: SizedBox(
                width: 56,
                height: 56,
                child: ProfilePhotoView(seed: seed, showMonogram: false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.otherName, style: AppTypography.headingSmall),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (c.unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
              ),
            ],
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
            const Icon(Icons.chat_bubble_outline,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text('No conversations yet',
                style: AppTypography.headingMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Match with someone in Discover to start chatting.',
                textAlign: TextAlign.center, style: AppTypography.bodySecondary),
          ],
        ),
      ),
    );
  }
}
