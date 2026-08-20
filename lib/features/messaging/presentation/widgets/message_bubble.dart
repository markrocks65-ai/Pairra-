import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/message.dart';

/// Renders a single message. Three restrained styles — mine (accent-tinted,
/// right), theirs (surface, left), and system (centered, subtle). Deliberately
/// not decorative: no tails, gradients or flourishes.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final Message message;

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) return _SystemNote(text: message.text ?? '');

    final mine = message.isMine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          // Fills alone carry the two voices — no outline, so the thread reads
          // like a premium messenger rather than bordered chat boxes.
          color: mine ? AppColors.accentMuted : AppColors.surfaceElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(mine ? AppRadius.lg : AppRadius.xs),
            bottomRight: Radius.circular(mine ? AppRadius.xs : AppRadius.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message.text ?? '', style: AppTypography.bodyLarge),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_time(message.sentAt), style: AppTypography.caption),
                if (mine) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _StatusTick(status: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTick extends StatelessWidget {
  const _StatusTick({required this.status});
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    // Read-receipt-ready: a real backend drives delivered/read.
    final (icon, color) = switch (status) {
      MessageStatus.sending => (Icons.schedule, AppColors.textMuted),
      MessageStatus.sent => (Icons.check, AppColors.textMuted),
      MessageStatus.delivered => (Icons.done_all, AppColors.textMuted),
      MessageStatus.read => (Icons.done_all, AppColors.accent),
    };
    return Icon(icon, size: 13, color: color);
  }
}

class _SystemNote extends StatelessWidget {
  const _SystemNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: LiquidGlassSurface(
          level: GlassLevel.subtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          showShadow: false,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(text,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
