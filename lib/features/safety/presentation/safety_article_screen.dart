import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../domain/safety_content.dart';

/// Displays a [SafetyArticle] (Before / During / After) as a calm, readable
/// list of supportive tips.
class SafetyArticleScreen extends StatelessWidget {
  const SafetyArticleScreen({super.key, required this.article});

  final SafetyArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(article.title, style: AppTypography.headingSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(article.intro,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xl),
            for (final tip in article.tips) ...[
              LiquidGlassCard(
                level: GlassLevel.subtle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 20, color: AppColors.success),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.title, style: AppTypography.headingSmall),
                          const SizedBox(height: 2),
                          Text(tip.body,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
