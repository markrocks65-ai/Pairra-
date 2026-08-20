import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles PAIRRA's [ThemeData]. The app is dark-first; [dark] is the
/// canonical theme. A [highContrast] variant strengthens borders and text for
/// the accessibility toggle. There is intentionally no light theme yet — the
/// brand is dark-luxury — but the token structure leaves room to add one.
@immutable
abstract final class AppTheme {
  static ThemeData get dark => _build(highContrast: false);

  static ThemeData get darkHighContrast => _build(highContrast: true);

  static ThemeData _build({required bool highContrast}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: highContrast ? const Color(0xFFFFFFFF) : AppColors.textPrimary,
      error: AppColors.error,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, highContrast: highContrast),
      dividerTheme: DividerThemeData(
        color: highContrast ? AppColors.borderHighContrast : AppColors.border,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      // Components below are handled by our own Liquid Glass widgets; the
      // Material defaults are aligned here only as sensible fallbacks.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, {required bool highContrast}) {
    final theme = base.copyWith(
      displayLarge: AppTypography.displayLarge,
      headlineLarge: AppTypography.headingLarge,
      headlineMedium: AppTypography.headingMedium,
      titleLarge: AppTypography.headingSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      bodySmall: AppTypography.caption,
    );
    if (!highContrast) return theme;
    // High contrast: push primary text to pure white for maximum legibility.
    return theme.apply(
      bodyColor: const Color(0xFFFFFFFF),
      displayColor: const Color(0xFFFFFFFF),
    );
  }
}
