import 'package:flutter/material.dart';

/// Defines the centralized color system for Studio 10200.
///
/// Uses Deep Purple (#673AB7) as the brand primary color and provides 
/// curated palettes for both light and dark theme modes.
abstract final class AppColors {
  /// Brand primary colors.
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryLight = Color(0xFF9575CD);
  static const Color primaryDark = Color(0xFF512DA8);

  /// Deep Purple shades used for gradients and loading animations.
  static const Color shade300 = Color(0xFF9575CD);
  static const Color shade400 = Color(0xFF7E57C2);
  static const Color shade500 = Color(0xFF673AB7);
  static const Color shade600 = Color(0xFF5E35B1);
  static const Color shade700 = Color(0xFF512DA8);

  /// Dark theme palette constants.
  static const Color darkScaffold = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF130F1C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xB3FFFFFF);
  static const Color darkDivider = Color(0x0DFFFFFF);
  static const Color darkDividerStrong = Color(0x33FFFFFF);

  /// Light theme palette constants.
  static const Color lightScaffold = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xB3000000);
  static const Color lightDivider = Color(0x1A000000);
  static const Color lightDividerStrong = Color(0x33000000);

  /// Functional and state-specific colors.
  static const Color glowBorder = primary;
}
