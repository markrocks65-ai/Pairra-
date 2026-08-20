import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/accessibility/accessibility_scope.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';

/// Root application shell. Installs the dark-luxury theme, the go_router
/// configuration (with auth redirect guards), and the accessibility scope so
/// every descendant can resolve reduced-motion / reduced-transparency /
/// high-contrast from a single place.
class PairraApp extends ConsumerWidget {
  const PairraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'PAIRRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        // MediaQuery exists here (provided by MaterialApp), so the scope can
        // merge OS accessibility signals with the in-app overrides.
        final mq = MediaQuery.of(context);

        // Honor the OS Dynamic Type / font-scale setting, but clamp it: PAIRRA's
        // dense glass chrome (nav labels, compatibility badges) breaks at the
        // extreme accessibility sizes, so we cap the upper end while still
        // scaling text up meaningfully. The lower bound stops tiny text if a
        // user has scaled the system down hard.
        final clampedTextScaler = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.5,
        );

        return MediaQuery(
          data: mq.copyWith(textScaler: clampedTextScaler),
          child: PairraAccessibilityScope(
            child: Builder(
              builder: (context) {
                final highContrast = PairraA11y.of(context).highContrast;
                return Theme(
                  data:
                      highContrast ? AppTheme.darkHighContrast : AppTheme.dark,
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
