import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../compatibility/domain/compatibility_explanation.dart';
import '../../../compatibility/domain/compatibility_score.dart';

/// The big compatibility readout: animated percentage + band + estimate
/// disclaimer. Reused on the discovery card and match detail.
class CompatibilityHeadline extends StatelessWidget {
  const CompatibilityHeadline({super.key, required this.score});

  final CompatibilityScore score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedCompatibilityScore(score: score.percent, showPercentSign: true),
        const SizedBox(height: AppSpacing.xs),
        Text('${score.band.label} match', style: AppTypography.headingSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          CompatibilityExplanation.disclaimer,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

/// Sub-score bars (privacy-safe: sensitive categories show a band/percentage,
/// never the underlying preference) plus the generated explanation.
class CompatibilityBreakdown extends StatelessWidget {
  const CompatibilityBreakdown({
    super.key,
    required this.score,
    required this.explanation,
    this.maxCategories,
    this.showExplanation = true,
  });

  final CompatibilityScore score;
  final CompatibilityExplanation explanation;
  final int? maxCategories;
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    var rows = score.rankedWithData;
    if (maxCategories != null && rows.length > maxCategories!) {
      rows = rows.sublist(0, maxCategories!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in rows) ...[
          _CategoryBar(categoryScore: c),
          const SizedBox(height: AppSpacing.md),
        ],
        if (showExplanation) ...[
          if (explanation.highlights.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final h in explanation.highlights)
              _ExplanationLine(icon: Icons.check_circle, color: AppColors.success, text: h),
          ],
          if (explanation.considerations.isNotEmpty)
            for (final c in explanation.considerations)
              _ExplanationLine(
                  icon: Icons.info_outline, color: AppColors.textMuted, text: c),
        ],
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.categoryScore});
  final CompatibilityCategoryScore categoryScore;

  Color get _color {
    switch (categoryScore.band) {
      case CompatibilityBand.exceptional:
      case CompatibilityBand.strong:
        return AppColors.success;
      case CompatibilityBand.moderate:
        return AppColors.accent;
      case CompatibilityBand.limited:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(categoryScore.category.label,
                  style: AppTypography.bodyMedium),
            ),
            Text('${categoryScore.percent}%',
                style: AppTypography.number.copyWith(fontSize: 14)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Stack(
            children: [
              Container(height: 6, color: AppColors.border),
              FractionallySizedBox(
                widthFactor: categoryScore.value.clamp(0.0, 1.0),
                child: Container(height: 6, color: _color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExplanationLine extends StatelessWidget {
  const _ExplanationLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
