import 'package:flutter/material.dart';

import '../../../../core/models/verification.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/verification_check.dart';

/// A row for one verification check (photo / identity): title, description, a
/// status pill, and a chevron into the flow. Honest about availability — when
/// no provider is connected it reads "Coming soon".
class VerificationCheckCard extends StatelessWidget {
  const VerificationCheckCard({
    super.key,
    required this.type,
    required this.status,
    required this.connected,
    required this.onOpen,
  });

  final VerificationCheckType type;
  final VerificationStatus status;
  final bool connected;
  final VoidCallback onOpen;

  IconData get _icon => switch (type) {
        VerificationCheckType.photo => Icons.face_retouching_natural,
        VerificationCheckType.identity => Icons.badge_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      onTap: onOpen,
      child: Row(
        children: [
          Icon(_icon, color: AppColors.accent, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: AppTypography.headingSmall),
                const SizedBox(height: 2),
                Text(type.description,
                    style: AppTypography.bodySecondary, maxLines: 2),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusPill(status: status, connected: connected),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.connected});

  final VerificationStatus status;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve();
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: status.isVerified ? AppColors.successWash : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
            color: status.isVerified ? AppColors.success : AppColors.border),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(color: color)),
    );
  }

  (String, Color) _resolve() {
    if (status.isVerified) return ('Verified', AppColors.success);
    if (!connected) return ('Coming soon', AppColors.textMuted);
    return switch (status) {
      VerificationStatus.pending => ('In review', AppColors.warning),
      VerificationStatus.rejected => ('Try again', AppColors.error),
      _ => ('Start', AppColors.accent),
    };
  }
}
