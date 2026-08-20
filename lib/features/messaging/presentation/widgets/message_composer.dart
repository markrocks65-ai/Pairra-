import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// The message input row: an attach (media) control, a glass text field, and a
/// send button. Media types are stubbed as "coming soon" — the controls exist
/// so photo sharing / voice messages / video calling can light up later.
class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md,
          MediaQuery.of(context).padding.bottom + AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PressableScale(
            pressedScale: 0.9,
            onTap: () => showMediaControls(context),
            child: LiquidGlassSurface(
              level: GlassLevel.standard,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              child: const Icon(Icons.add, size: 22, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: LiquidGlassTextField(
              controller: controller,
              hint: 'Message',
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final enabled = value.text.trim().isNotEmpty;
              return PressableScale(
                pressedScale: 0.9,
                enabled: enabled,
                onTap: enabled ? _send : null,
                child: Opacity(
                  opacity: enabled ? 1 : 0.5,
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
                    child: const Icon(Icons.arrow_upward,
                        color: AppColors.onAccent, size: 22),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Media attachment options — all "coming soon" until the backend supports
/// photo sharing, voice messages and video calling.
Future<void> showMediaControls(BuildContext context) {
  return LiquidGlassBottomSheet.show(
    context,
    title: 'Share',
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _MediaRow(icon: Icons.photo_outlined, label: 'Photo'),
        _MediaRow(icon: Icons.mic_none, label: 'Voice message'),
        _MediaRow(icon: Icons.videocam_outlined, label: 'Video call'),
        SizedBox(height: AppSpacing.sm),
      ],
    ),
  );
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTypography.bodyLarge),
          const Spacer(),
          Text('Coming soon', style: AppTypography.caption),
        ],
      ),
    );
  }
}
