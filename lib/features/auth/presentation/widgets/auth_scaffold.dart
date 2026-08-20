import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';

/// A calm, premium radial backdrop that gives the glass surfaces something to
/// sit over. Deep navy glow, top-left, fading to the near-black background.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.7, -0.9),
            radius: 1.5,
            colors: [Color(0xFF16264C), AppColors.background],
            stops: [0.0, 0.72],
          ),
        ),
      ),
    );
  }
}

/// Shared layout for every auth screen: dark backdrop, optional glass back
/// button, a title/subtitle header, and a scrollable, keyboard-aware content
/// column. Keeps all eight screens visually consistent and DRY.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.onBack,
    this.showBack = true,
    this.footer,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;

  /// Called when the glass back button is tapped. If null and [showBack] is
  /// true, defaults to `Navigator.maybePop`.
  final VoidCallback? onBack;
  final bool showBack;

  /// Pinned to the bottom (e.g. "Already have an account? Log in").
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Column(
              children: [
                if (showBack)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.sm, 0, 0),
                      child: _GlassBackButton(
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null) ...[
                          Text(title!, style: AppTypography.headingLarge),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (subtitle != null) ...[
                          Text(subtitle!, style: AppTypography.bodySecondary),
                          const SizedBox(height: AppSpacing.xxl),
                        ] else if (title != null)
                          const SizedBox(height: AppSpacing.xl),
                        ...children,
                      ],
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: footer!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.9,
      child: LiquidGlassSurface(
        level: GlassLevel.subtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        showShadow: false,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: const Icon(Icons.arrow_back_ios_new,
            size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
