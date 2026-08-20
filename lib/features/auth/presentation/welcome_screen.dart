import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../navigation/app_routes.dart';
import 'widgets/auth_scaffold.dart';

/// First-run entry point. Communicates the brand and its promise, then offers
/// the two clear paths: create an account or log in. Copy is deliberately
/// warm and relationship-oriented — never a hookup framing.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  // Brand lockup.
                  Appear(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PAIRRA',
                            style: AppTypography.displayLarge
                                .copyWith(letterSpacing: 6)),
                        const SizedBox(height: AppSpacing.md),
                        Text('Dating without the guesswork.',
                            style: AppTypography.headingSmall
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Meet people you\'re genuinely compatible with — '
                          'matched on what actually matters to you, before the '
                          'first hello.',
                          style: AppTypography.bodyLarge
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 4),
                  // Actions.
                  Appear(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LiquidGlassButton(
                          label: 'Create account',
                          icon: Icons.favorite_border,
                          expand: true,
                          onPressed: () => context.push(AppRoutes.signUp),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LiquidGlassButton(
                          label: 'Log in',
                          variant: GlassButtonVariant.glass,
                          expand: true,
                          onPressed: () => context.push(AppRoutes.login),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'By continuing you\'ll be asked to review and accept '
                          'our Terms and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
