import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// A generic full-screen editor wrapper. The [child] is typically an existing
/// onboarding step widget (StepInterests, StepPrivacy, …) — those already read
/// and write the shared draft and auto-persist, so this wrapper only supplies
/// the title, backdrop and a Done affordance.
class EditSectionScreen extends StatelessWidget {
  const EditSectionScreen({
    super.key,
    required this.title,
    required this.child,
    this.intro,
  });

  final String title;
  final Widget child;
  final String? intro;

  /// Convenience to push this editor.
  static Future<void> push(BuildContext context,
      {required String title, required Widget child, String? intro}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            EditSectionScreen(title: title, intro: intro, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(title, style: AppTypography.headingSmall),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.giant),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (intro != null) ...[
                Text(intro!, style: AppTypography.bodySecondary),
                const SizedBox(height: AppSpacing.xl),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
