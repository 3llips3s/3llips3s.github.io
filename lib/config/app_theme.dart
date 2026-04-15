import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Provides [ThemeData] for dark (default) and light modes.
abstract final class AppTheme {
  // ── Dark Theme (Default) ───────────────────────────────────────
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

  // ── Light Theme ────────────────────────────────────────────────
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

  // ── Typography ─────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Monospace / terminal: JetBrains Mono (headings, titles, code)
    final TextStyle mono = GoogleFonts.jetBrainsMono(color: textColor);
    // Professional / body: Inter
    final TextStyle body = GoogleFonts.inter(color: textColor);
    final TextStyle bodySecondary = GoogleFonts.inter(color: secondaryColor);

    return TextTheme(
      // ── Display / Headline (JetBrains Mono) ──
      displayLarge: mono.copyWith(fontSize: 48, fontWeight: FontWeight.w700),
      displayMedium: mono.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
      displaySmall: mono.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineLarge: mono.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      headlineMedium: mono.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: mono.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      // ── Title (JetBrains Mono) ──
      titleLarge: mono.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: mono.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: mono.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      // ── Body (Inter) ──
      bodyLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: body.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: bodySecondary.copyWith(
          fontSize: 12, fontWeight: FontWeight.w400),
      // ── Label (Inter) ──
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: bodySecondary.copyWith(
          fontSize: 11, fontWeight: FontWeight.w400),
    );
  }

  // ── Scrollbar ──────────────────────────────────────────────────

  static ScrollbarThemeData _scrollbarTheme(Brightness brightness) {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(
        AppColors.primary.withValues(alpha: 0.6),
      ),
      thickness: WidgetStateProperty.all(4.0),
      radius: const Radius.circular(2),
      thumbVisibility: WidgetStateProperty.all(false),
    );
  }
}
