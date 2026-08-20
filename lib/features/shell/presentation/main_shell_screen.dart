import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';

/// The primary app shell: an indexed stack of the five tab branches with the
/// PAIRRA floating Liquid Glass navigation over it. This is what makes the app
/// feel like one product — the tabs share a persistent, premium nav rather than
/// being separately-pushed screens.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    GlassNavItem(
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore,
        label: 'Discover'),
    GlassNavItem(
        icon: Icons.favorite_outline,
        selectedIcon: Icons.favorite,
        label: 'Matches'),
    GlassNavItem(
        icon: Icons.local_bar_outlined,
        selectedIcon: Icons.local_bar,
        label: 'Dates'),
    GlassNavItem(
        icon: Icons.chat_bubble_outline,
        selectedIcon: Icons.chat_bubble,
        label: 'Messages'),
    GlassNavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          navigationShell,
          Align(
            alignment: Alignment.bottomCenter,
            child: LiquidGlassNavigation(
              items: _items,
              currentIndex: navigationShell.currentIndex,
              onChanged: (index) => navigationShell.goBranch(
                index,
                // Tapping the current tab pops it back to its root.
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
