import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Spacing scale — an 8pt-based rhythm with a 4pt half-step. Every margin,
/// padding and gap in PAIRRA should reference one of these; do not hand-tune
/// pixel values in feature code.
@immutable
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 56;

  /// Bottom space a tab-root or in-branch screen leaves so its content clears
  /// the floating Liquid Glass navigation bar.
  static const double navBarClearance = 96;
}

/// Corner-radius scale. PAIRRA leans on generous, soft rounding to feel
/// premium; glass surfaces use [lg]–[xl], pills/chips use [pill].
@immutable
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 26;
  static const double xxl = 32;

  /// Fully-rounded (chips, FABs, avatars).
  static const double pill = 999;
}

/// Reusable shadow presets. Kept soft and low-spread so depth reads as
/// premium hardware, not drop-shadow clutter.
@immutable
abstract final class AppShadows {
  /// Subtle lift for cards resting on the background.
  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Stronger shadow for floating glass (nav bar, FAB, sheets).
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 16)),
  ];

  /// Tight shadow for small interactive elements (chips, buttons).
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
