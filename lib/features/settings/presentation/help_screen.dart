import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../safety/presentation/safety_home_screen.dart';

/// Help & support — a calm entry point to guidance and contact.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text('Help', style: AppTypography.headingSmall),
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
            Text('How can we help?', style: AppTypography.headingMedium),
            const SizedBox(height: AppSpacing.lg),
            _Card(
              icon: Icons.shield_outlined,
              title: 'Safety Center',
              body: 'Tips for meeting safely, plus report and block tools.',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SafetyHomeScreen())),
            ),
            const SizedBox(height: AppSpacing.md),
            const _Card(
              icon: Icons.mail_outline,
              title: 'Contact support',
              body: 'Email support@pairra.example and we\'ll get back to you.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _Card(
              icon: Icons.help_outline,
              title: 'FAQs',
              body: 'Answers to common questions (coming soon).',
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card(
      {required this.icon, required this.title, required this.body, this.onTap});
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge),
                Text(body, style: AppTypography.caption),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
