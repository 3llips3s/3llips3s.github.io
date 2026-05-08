import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Provides the centralized [ThemeData] for Studio 10200.
///
/// Supports dark (default) and light modes, utilizing JetBrains Mono for 
/// headings and titles, and Inter for primary body content.
abstract final class AppTheme {
  /// The default dark theme configuration.
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkScaffold,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.darkSurface,
        ),
        cardColor: AppColors.darkCard,
        dividerColor: AppColors.darkDivider,
        textTheme: _buildTextTheme(Brightness.dark),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        scrollbarTheme: _scrollbarTheme(Brightness.dark),
        useMaterial3: true,
      );

  /// The light theme configuration.
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightScaffold,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryDark,
          surface: AppColors.lightSurface,
        ),
        cardColor: AppColors.lightCard,
        dividerColor: AppColors.lightDivider,
        textTheme: _buildTextTheme(Brightness.light),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        scrollbarTheme: _scrollbarTheme(Brightness.light),
        useMaterial3: true,
      );

  /// Builds a [TextTheme] based on the provided [brightness].
  ///
  /// Maps typography styles to JetBrains Mono (headlines/titles) and 
  /// Inter (body/labels).
  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final TextStyle mono = TextStyle(fontFamily: 'JetBrainsMono', color: textColor);
    final TextStyle body = TextStyle(fontFamily: 'Inter', color: textColor);
    final TextStyle bodySecondary = TextStyle(fontFamily: 'Inter', color: secondaryColor);

    return TextTheme(
      displayLarge: mono.copyWith(fontSize: 48, fontWeight: FontWeight.w700),
      displayMedium: mono.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
      displaySmall: mono.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineLarge: mono.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      headlineMedium: mono.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: mono.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: mono.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: mono.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: mono.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: body.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: bodySecondary.copyWith(
          fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: bodySecondary.copyWith(
          fontSize: 11, fontWeight: FontWeight.w400),
    );
  }

  /// Configures the global [ScrollbarThemeData] based on [brightness].
  static ScrollbarThemeData _scrollbarTheme(Brightness brightness) {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged)) {
          return AppColors.primary;
        }
        return AppColors.primary.withValues(alpha: 0.8);
      }),
      thickness: WidgetStateProperty.all(3.0),
      radius: const Radius.circular(8),
      thumbVisibility: WidgetStateProperty.all(false),
      interactive: true,
    );
  }
}
