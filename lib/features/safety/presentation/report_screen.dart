import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/design_system.dart';
import '../../moderation/application/moderation_service.dart';
import '../../moderation/presentation/report_feedback.dart';
import '../domain/report.dart';

/// Report someone. Reasons cover the full range (harassment, threats, spam,
/// scam, impersonation, underage, non-consensual content, hate speech, other).
/// Confidential and supportive.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, this.targetId, this.targetName});

  final String? targetId;
  final String? targetName;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late final TextEditingController _who =
      TextEditingController(text: widget.targetName ?? '');
  final _details = TextEditingController();
  ReportReason? _reason;

  @override
  void dispose() {
    _who.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;
    final name = _who.text.trim();
    final outcome = await ref.read(moderationServiceProvider).reportUser(
          targetId: widget.targetId ??
              'report_${DateTime.now().microsecondsSinceEpoch}',
          targetName: name.isEmpty ? null : name,
          reason: reason,
          note: _details.text.trim().isEmpty ? null : _details.text.trim(),
        );
    if (!mounted) return;
    Navigator.of(context).maybePop();
    showReportFeedback(context, name: name.isEmpty ? 'them' : name,
        outcome: outcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Report someone', style: AppTypography.headingSmall),
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
            Text('Reports are confidential. Thank you for helping keep PAIRRA '
                'safe.',
                style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.xl),
            if (widget.targetId == null) ...[
              LiquidGlassTextField(
                controller: _who,
                label: 'Who are you reporting? (optional)',
                hint: 'Name or username',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            Text('What happened?', style: AppTypography.label),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final r in ReportReason.values)
                  LiquidGlassChip(
                    label: r.label,
                    selected: _reason == r,
                    onTap: () => setState(() => _reason = r),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            LiquidGlassTextField(
              controller: _details,
              label: 'Details (optional)',
              hint: 'Anything you\'d like our team to know',
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: AppSpacing.xxl),
            LiquidGlassButton(
              label: 'Submit report',
              expand: true,
              onPressed: _reason == null ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
