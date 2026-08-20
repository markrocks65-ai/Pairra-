import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';

/// A labeled question grouping used within onboarding steps: a title, an
/// optional hint, and the answer control beneath. Keeps every step visually
/// consistent and calm.
class QuestionBlock extends StatelessWidget {
  const QuestionBlock({
    super.key,
    required this.title,
    required this.child,
    this.hint,
    this.trailing,
  });

  final String title;
  final String? hint;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTypography.headingSmall)),
            ?trailing,
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(hint!, style: AppTypography.bodySecondary),
        ],
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}
