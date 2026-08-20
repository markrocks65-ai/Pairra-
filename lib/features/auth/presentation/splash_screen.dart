import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import 'widgets/auth_scaffold.dart';

/// Branded launch screen shown while the persisted session resolves. The
/// router's redirect guard moves the user on (to Welcome or Home) as soon as
/// the auth lifecycle leaves `unknown`, so this screen owns no navigation.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthBackground(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PAIRRA',
                    style: AppTypography.displayLarge.copyWith(letterSpacing: 6)),
                const SizedBox(height: AppSpacing.sm),
                Text('Dating without the guesswork.',
                    style: AppTypography.bodySecondary),
                const SizedBox(height: AppSpacing.huge),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
