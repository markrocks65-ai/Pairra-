import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../application/profile_providers.dart';

/// Edit the profile bio. Writes to the shared draft (auto-persisted) as the
/// user types, so there's nothing to "save" — Done just returns.
class BioEditorScreen extends ConsumerStatefulWidget {
  const BioEditorScreen({super.key});

  @override
  ConsumerState<BioEditorScreen> createState() => _BioEditorScreenState();
}

class _BioEditorScreenState extends ConsumerState<BioEditorScreen> {
  static const _maxLength = 300;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    _bio = TextEditingController(
        text: ref.read(currentProfileProvider).bio ?? '');
  }

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(profileEditingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('About you', style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text('Done',
                style: AppTypography.button.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Write a short, genuine intro. Keep it you.',
                  style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.xl),
              LiquidGlassTextField(
                controller: _bio,
                hint: 'What should people know about you?',
                maxLines: 6,
                minLines: 4,
                maxLength: _maxLength,
                onChanged: (v) => setState(() => controller.setBio(v)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${_bio.text.characters.length}/$_maxLength',
                    style: AppTypography.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
