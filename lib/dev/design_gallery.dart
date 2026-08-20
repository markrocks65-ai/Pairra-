import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/design_system.dart';

/// A developer showcase that exercises every design-system token and component
/// and lets you flip the accessibility switches live to see the glass → opaque
/// fallback and reduced motion in action.
///
/// This is a DEV TOOL, not a product screen. It exists so the foundational
/// system can be reviewed and regression-checked before feature screens are
/// built on top of it.
class DesignGallery extends ConsumerStatefulWidget {
  const DesignGallery({super.key});

  @override
  ConsumerState<DesignGallery> createState() => _DesignGalleryState();
}

class _DesignGalleryState extends ConsumerState<DesignGallery> {
  int _navIndex = 0;
  int _tabIndex = 0;
  final Set<String> _selectedChips = {'Vers'};

  static const _navItems = [
    GlassNavItem(icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Discover'),
    GlassNavItem(icon: Icons.favorite_outline, selectedIcon: Icons.favorite, label: 'Matches'),
    GlassNavItem(icon: Icons.local_bar_outlined, selectedIcon: Icons.local_bar, label: 'Dates'),
    GlassNavItem(icon: Icons.chat_bubble_outline, selectedIcon: Icons.chat_bubble, label: 'Messages'),
    GlassNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // A subtle radial glow to give the glass something to blur over.
          const _BackdropGlow(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 140),
              children: [
                _header(),
                const SizedBox(height: AppSpacing.xxl),
                _accessibilityPanel(),
                const SizedBox(height: AppSpacing.xxl),
                _typographySection(),
                const SizedBox(height: AppSpacing.xxl),
                _compatibilitySection(),
                const SizedBox(height: AppSpacing.xxl),
                _buttonsSection(),
                const SizedBox(height: AppSpacing.xxl),
                _chipsSection(),
                const SizedBox(height: AppSpacing.xxl),
                _tabsAndSurfacesSection(),
                const SizedBox(height: AppSpacing.xxl),
                _overlaysSection(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: LiquidGlassNavigation(
              items: _navItems,
              currentIndex: _navIndex,
              onChanged: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAIRRA', style: AppTypography.headingLarge.copyWith(letterSpacing: 4)),
        const SizedBox(height: AppSpacing.xs),
        Text('Dating without the guesswork.',
            style: AppTypography.bodySecondary),
      ],
    );
  }

  Widget _accessibilityPanel() {
    final settings = ref.watch(accessibilityControllerProvider);
    final controller = ref.read(accessibilityControllerProvider.notifier);
    final resolved = PairraA11y.of(context);

    bool on(A11yPreference p) => p == A11yPreference.on;

    return LiquidGlassSection(
      eyebrow: 'Accessibility',
      title: 'Live fallbacks',
      child: Column(
        children: [
          _toggleRow(
            'Reduce transparency',
            'Glass → opaque dark (now: ${resolved.reduceTransparency ? "opaque" : "glass"})',
            on(settings.reduceTransparency),
            (v) => controller.setReduceTransparency(
                v ? A11yPreference.on : A11yPreference.off),
          ),
          _toggleRow(
            'Reduce motion',
            'Animations present final state instantly',
            on(settings.reduceMotion),
            (v) => controller.setReduceMotion(
                v ? A11yPreference.on : A11yPreference.off),
          ),
          _toggleRow(
            'High contrast',
            'Stronger borders and text',
            on(settings.highContrast),
            (v) => controller.setHighContrast(
                v ? A11yPreference.on : A11yPreference.off),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLarge),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _typographySection() {
    return LiquidGlassSection(
      eyebrow: 'Foundations',
      title: 'Typography',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display large', style: AppTypography.displayLarge),
          const SizedBox(height: AppSpacing.sm),
          Text('Heading medium', style: AppTypography.headingMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Body large — highly readable supporting copy that stays calm '
              'and legible over the dark surface.',
              style: AppTypography.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Text('LABEL · SECTION EYEBROW', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Text('Caption / timestamp', style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _compatibilitySection() {
    return LiquidGlassCard(
      level: GlassLevel.prominent,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          const AnimatedCompatibilityScore(score: 92),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Strong match', style: AppTypography.headingSmall),
                const SizedBox(height: 2),
                Text('Reciprocal compatibility across roles, intentions and '
                    'lifestyle.',
                    style: AppTypography.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonsSection() {
    return LiquidGlassSection(
      eyebrow: 'Components',
      title: 'Buttons',
      child: Column(
        children: [
          LiquidGlassButton(
            label: 'Primary action',
            icon: Icons.bolt,
            expand: true,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          LiquidGlassButton(
            label: 'Glass action',
            variant: GlassButtonVariant.glass,
            expand: true,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          LiquidGlassButton(
            label: 'Ghost action',
            variant: GlassButtonVariant.ghost,
            expand: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _chipsSection() {
    const options = ['Top', 'Bottom', 'Vers', 'Vers Top', 'Side', 'Long-term'];
    return LiquidGlassSection(
      eyebrow: 'Components',
      title: 'Chips & filters',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final o in options)
            LiquidGlassChip(
              label: o,
              selected: _selectedChips.contains(o),
              onTap: () => setState(() {
                if (_selectedChips.contains(o)) {
                  _selectedChips.remove(o);
                } else {
                  _selectedChips.add(o);
                }
              }),
            ),
        ],
      ),
    );
  }

  Widget _tabsAndSurfacesSection() {
    return LiquidGlassSection(
      eyebrow: 'Components',
      title: 'Tabs & surfaces',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiquidGlassTabBar(
            labels: const ['Overview', 'Compatibility', 'Photos'],
            selectedIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: AppSpacing.lg),
          LiquidGlassCard(
            onTap: () {},
            child: Row(
              children: [
                Icon(Icons.workspace_premium_outlined,
                    color: AppColors.accent, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Tappable glass card with press feedback',
                      style: AppTypography.bodyLarge),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlaysSection() {
    return LiquidGlassSection(
      eyebrow: 'Components',
      title: 'Sheets, modals & overlays',
      child: Column(
        children: [
          LiquidGlassButton(
            label: 'Show bottom sheet',
            variant: GlassButtonVariant.glass,
            expand: true,
            onPressed: () => LiquidGlassBottomSheet.show(
              context,
              title: 'Filters',
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Distance, intentions and role preferences would live '
                      'here.',
                      style: AppTypography.bodySecondary),
                  const SizedBox(height: AppSpacing.xl),
                  LiquidGlassButton(
                    label: 'Apply',
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LiquidGlassButton(
            label: 'Show confirmation modal',
            variant: GlassButtonVariant.glass,
            expand: true,
            onPressed: () => LiquidGlassModal.confirm(
              context,
              title: 'Block this user?',
              message:
                  'They won\'t be able to see your profile or message you. '
                  'You can undo this from Settings.',
              confirmLabel: 'Block',
              destructive: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LiquidGlassButton(
            label: 'Show notification overlay',
            variant: GlassButtonVariant.glass,
            expand: true,
            onPressed: () => LiquidGlassOverlay.show(
              context,
              title: 'It\'s a match',
              message: 'You and Alex are highly compatible.',
              icon: Icons.favorite,
              tone: OverlayTone.success,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative background so the glass has depth/photography-like content to
/// blur over in the showcase.
class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.8),
            radius: 1.4,
            colors: [Color(0xFF1B2E5A), AppColors.background],
            stops: [0.0, 0.7],
          ),
        ),
      ),
    );
  }
}
