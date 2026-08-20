import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_photo.dart';
import '../../../design_system/design_system.dart';
import '../application/profile_providers.dart';
import 'widgets/profile_photo_view.dart';

/// Manage profile photos: add, remove, and reorder (drag). Each photo shows a
/// moderation status placeholder — the hook for a future automated image-safety
/// pipeline. Real image upload replaces the gradient placeholders later.
class PhotoManagerScreen extends ConsumerWidget {
  const PhotoManagerScreen({super.key});

  static const _maxPhotos = 6;

  Future<void> _addPhoto(BuildContext context, ProfileEditingController c) {
    return LiquidGlassBottomSheet.show(
      context,
      title: 'Add a photo',
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Real photo upload is coming soon. For now, pick a look for this '
            'slot — you can reorder and replace it later.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              for (final seed in ProfileGradients.seeds)
                PressableScale(
                  pressedScale: 0.92,
                  onTap: () {
                    c.addPhoto(seed);
                    Navigator.of(context).pop();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: ProfilePhotoView(seed: seed, showMonogram: false),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(currentProfileProvider).photos;
    final controller = ref.watch(profileEditingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Photos', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
              child: _ModerationNote(),
            ),
            Expanded(
              child: photos.isEmpty
                  ? _EmptyState()
                  : ReorderableListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                      // ignore: deprecated_member_use
                      onReorder: controller.reorderPhotos,
                      children: [
                        for (var i = 0; i < photos.length; i++)
                          _PhotoTile(
                            key: ValueKey(photos[i].id),
                            photo: photos[i],
                            isPrimary: i == 0,
                            onRemove: () => controller.removePhoto(photos[i].id),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: LiquidGlassButton(
                label: photos.length >= _maxPhotos
                    ? 'Maximum $_maxPhotos photos'
                    : 'Add photo',
                icon: Icons.add_a_photo_outlined,
                expand: true,
                onPressed: photos.length >= _maxPhotos
                    ? null
                    : () => _addPhoto(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModerationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      level: GlassLevel.subtle,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Photos will be automatically reviewed for safety before they\'re '
              'shown to others. Drag to reorder — your first photo is your main.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.photo,
    required this.isPrimary,
    required this.onRemove,
  });

  final ProfilePhoto photo;
  final bool isPrimary;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: LiquidGlassSurface(
        level: GlassLevel.subtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        showShadow: false,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 60,
                height: 72,
                child:
                    ProfilePhotoView(photo: photo, showMonogram: false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPrimary ? 'Main photo' : 'Photo',
                      style: AppTypography.bodyLarge),
                  const SizedBox(height: 4),
                  _ModerationChip(status: photo.moderation),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.textMuted,
              onPressed: onRemove,
            ),
            const Icon(Icons.drag_handle, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _ModerationChip extends StatelessWidget {
  const _ModerationChip({required this.status});
  final PhotoModerationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PhotoModerationStatus.approved => AppColors.success,
      PhotoModerationStatus.rejected => AppColors.error,
      PhotoModerationStatus.pending => AppColors.warning,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(status.label,
            style: AppTypography.caption.copyWith(color: color)),
      ],
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
            const Icon(Icons.add_photo_alternate_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text('Add your first photo',
                style: AppTypography.headingSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Profiles with photos get far better matches.',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
