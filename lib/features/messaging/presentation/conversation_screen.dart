import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../discovery/application/matches_controller.dart';
import '../../moderation/application/moderation_service.dart';
import '../../moderation/presentation/report_feedback.dart';
import '../../onboarding/domain/onboarding_profile.dart';
import '../../profile/application/profile_providers.dart';
import '../../profile/presentation/widgets/profile_photo_view.dart';
import '../../safety/application/safety_controllers.dart';
import '../application/icebreakers.dart';
import '../application/messaging_providers.dart';
import '../domain/message.dart';
import 'conversation_profile_preview.dart';
import 'widgets/conversation_safety.dart';
import 'widgets/icebreaker_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_composer.dart';

/// A single conversation: the thread, a header that opens the person's profile,
/// optional icebreakers on a fresh chat, the composer, and the safety menu
/// (report / block / unmatch / tips). Premium and calm — not decorative.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _composer = TextEditingController();
  final _scroll = ScrollController();

  String get _id => widget.conversationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagingControllerProvider.notifier)
        ..openConversation(_id)
        ..markRead(_id);
      _jumpToBottom();
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  void _send(String text) {
    ref.read(messagingControllerProvider.notifier).sendText(_id, text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  void _leaveAfter(void Function() action) {
    action();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _openSafety(String name, String otherId) {
    showConversationSafetySheet(
      context,
      name: name,
      onSafetyTips: () => showSafetyTips(context),
      onUnmatch: () => _leaveAfter(() {
        ref.read(messagingControllerProvider.notifier).removeConversation(_id);
        ref.read(matchesControllerProvider.notifier).remove(_id);
      }),
      onBlock: () async {
        final ok = await LiquidGlassModal.confirm(
          context,
          title: 'Block $name?',
          message: 'They won\'t be able to message you or see your profile.',
          confirmLabel: 'Block',
          destructive: true,
        );
        if (ok == true) {
          _leaveAfter(() {
            ref.read(blockedProfilesProvider.notifier).block(otherId, name: name);
            ref.read(matchesControllerProvider.notifier).remove(_id);
            ref
                .read(messagingControllerProvider.notifier)
                .removeConversation(_id);
          });
        }
      },
      onReport: () => showReportReasonsSheet(
        context,
        name: name,
        onReport: (reason) async {
          final outcome = await ref
              .read(moderationServiceProvider)
              .reportUser(targetId: otherId, targetName: name, reason: reason);
          ref.read(blockedProfilesProvider.notifier).block(otherId, name: name);
          ref.read(matchesControllerProvider.notifier).remove(_id);
          ref.read(messagingControllerProvider.notifier).removeConversation(_id);
          if (mounted) {
            Navigator.of(context).maybePop();
            showReportFeedback(context, name: name, outcome: outcome);
          }
        },
      ),
    );
  }

  void _reportMessage(String name, String otherId, Message message) {
    showReportReasonsSheet(
      context,
      name: 'this message',
      onReport: (reason) async {
        final outcome = await ref.read(moderationServiceProvider).reportMessage(
              targetId: otherId,
              targetName: name,
              messageId: message.id,
              contentSnapshot: message.text ?? '',
              reason: reason,
            );
        if (mounted) showReportFeedback(context, name: name, outcome: outcome);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagingControllerProvider);
    final conversation = state.conversation(_id);

    if (conversation == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('This conversation has ended.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final messages = state.messagesFor(_id);
    final name = conversation.otherName;
    final selfInterests = ref.watch(currentProfileProvider).interests;
    final icebreakers = state.isFresh(_id)
        ? Icebreakers.suggest(
            selfInterests, conversation.otherProfile.interests)
        : const <Icebreaker>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              profile: conversation.otherProfile,
              name: name,
              onBack: () => Navigator.of(context).maybePop(),
              onOpenProfile: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ConversationProfilePreview(
                      profile: conversation.otherProfile),
                ),
              ),
              onSafety: () => _openSafety(name, conversation.otherId),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final reportable = !m.isMine && !m.isSystem;
                  return GestureDetector(
                    onLongPress: reportable
                        ? () => _reportMessage(name, conversation.otherId, m)
                        : null,
                    child: MessageBubble(message: m),
                  );
                },
              ),
            ),
            IcebreakerBar(
              icebreakers: icebreakers,
              onPick: (suggestion) => setState(() {
                _composer.text = suggestion;
                _composer.selection = TextSelection.collapsed(
                    offset: _composer.text.length);
              }),
            ),
            MessageComposer(controller: _composer, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.profile,
    required this.name,
    required this.onBack,
    required this.onOpenProfile,
    required this.onSafety,
  });

  final OnboardingProfile profile;
  final String name;
  final VoidCallback onBack;
  final VoidCallback onOpenProfile;
  final VoidCallback onSafety;

  @override
  Widget build(BuildContext context) {
    final seed = profile.photos.isNotEmpty
        ? profile.photos.first.placeholderSeed
        : 'p1';
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          PressableScale(
            pressedScale: 0.9,
            onTap: onBack,
            semanticLabel: 'Back',
            minTapTarget: const Size.square(48),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: PressableScale(
              behavior: HitTestBehavior.opaque,
              pressedScale: 0.98,
              onTap: onOpenProfile,
              semanticLabel: 'View $name\'s profile',
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child:
                          ProfilePhotoView(seed: seed, showMonogram: false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(name,
                        style: AppTypography.headingSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
          PressableScale(
            pressedScale: 0.9,
            onTap: onSafety,
            semanticLabel: 'Safety and conversation options',
            minTapTarget: const Size.square(48),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(Icons.more_vert, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
