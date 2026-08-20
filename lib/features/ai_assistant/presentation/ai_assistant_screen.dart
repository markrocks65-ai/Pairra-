import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../subscription/application/subscription_controller.dart';
import '../../subscription/presentation/premium_screen.dart';
import '../application/ai_assistant_controller.dart';
import '../domain/ai_guardrails.dart';
import '../domain/ai_models.dart';
import '../domain/ai_task.dart';

/// The AI Dating Assistant. A premium feature: free users see a tasteful
/// upsell. Task-oriented (not a human-imitating chatbot) with an always-visible
/// honesty disclaimer. Message help produces suggestions the user copies and
/// sends themselves.
class AiAssistantScreen extends ConsumerWidget {
  const AiAssistantScreen({super.key});

  static const _chips = [
    AiTask.conversationStarters,
    AiTask.profileImprovement,
    AiTask.dateIdeas,
    AiTask.relationshipCommunication,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(isPremiumProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('AI Assistant', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: premium ? const _AssistantView() : const _LockedView(),
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  const _LockedView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const Icon(Icons.auto_awesome, color: AppColors.accent, size: 40),
        const SizedBox(height: AppSpacing.md),
        Text('AI Dating Assistant', style: AppTypography.headingLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'A little help when you want it — conversation starters, profile tips, '
          'date ideas, and reply suggestions. It offers ideas; you\'re always '
          'in control.',
          style: AppTypography.bodyLarge
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        LiquidGlassButton(
          label: 'Unlock with Premium',
          icon: Icons.workspace_premium,
          expand: true,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PremiumScreen()),
          ),
        ),
      ],
    );
  }
}

class _AssistantView extends ConsumerStatefulWidget {
  const _AssistantView();

  @override
  ConsumerState<_AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends ConsumerState<_AssistantView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _run(AiTask task, {String? userText}) {
    ref.read(aiAssistantControllerProvider.notifier).run(task, userText: userText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: AppMotion.base, curve: AppMotion.standard);
      }
    });
  }

  void _submitReply() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _run(AiTask.messageDrafting, userText: text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAssistantControllerProvider);

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _Disclaimer(),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final task in AiAssistantScreen._chips)
                    LiquidGlassChip(label: task.label, onTap: () => _run(task)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final turn in state.turns) ...[
                _UserBubble(text: turn.prompt),
                const SizedBox(height: AppSpacing.sm),
                if (turn.loading)
                  _Thinking()
                else
                  _AssistantBubble(response: turn.response!),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
        _Composer(controller: _input, onSubmit: _submitReply),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(AiGuardrails.disclaimer, style: AppTypography.caption),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.accentMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.accent),
        ),
        child: Text(text, style: AppTypography.bodyLarge),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.response});
  final AiResponse response;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(response.intro, style: AppTypography.bodyLarge),
          if (response.suggestions.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          for (final s in response.suggestions) ...[
            _SuggestionRow(suggestion: s),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestion});
  final AiSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(suggestion.text, style: AppTypography.bodyMedium)),
          if (suggestion.copyable) ...[
            const SizedBox(width: AppSpacing.sm),
            PressableScale(
              pressedScale: 0.9,
              onTap: () {
                Clipboard.setData(ClipboardData(text: suggestion.text));
                LiquidGlassOverlay.show(
                  context,
                  title: 'Copied',
                  message: 'Paste it into your chat and send when you\'re ready.',
                  icon: Icons.check,
                  tone: OverlayTone.success,
                );
              },
              child: const Icon(Icons.copy_outlined,
                  size: 18, color: AppColors.accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const LiquidGlassCard(
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.accent),
          ),
          SizedBox(width: AppSpacing.md),
          Text('Thinking…'),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md,
          MediaQuery.of(context).padding.bottom + AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: LiquidGlassTextField(
              controller: controller,
              hint: 'Paste a message for reply ideas, or ask for help',
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PressableScale(
            pressedScale: 0.9,
            onTap: onSubmit,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accent, AppColors.accentPressed],
                ),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.onAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
