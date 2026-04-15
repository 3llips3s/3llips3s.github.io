import 'package:flutter/material.dart';

/// Studio 10200 color system.
///
/// Primary: Deep Purple (#673AB7)
/// Dark scaffold: Pure Black (#000000)
/// Light scaffold: Pure White (#FFFFFF)
abstract final class AppColors {
  // ── Brand Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryLight = Color(0xFF9575CD);
  static const Color primaryDark = Color(0xFF512DA8);

  // Deep Purple shades (used in loading animation & accents)
  static const Color shade300 = Color(0xFF9575CD);
  static const Color shade400 = Color(0xFF7E57C2);
  static const Color shade500 = Color(0xFF673AB7);
  static const Color shade600 = Color(0xFF5E35B1);
  static const Color shade700 = Color(0xFF512DA8);

  // ── Dark Theme ─────────────────────────────────────────────────
  static const Color darkScaffold = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color darkDivider = Color(0x33FFFFFF); // 20% white

  // ── Light Theme ────────────────────────────────────────────────
  static const Color lightScaffold = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xB3000000); // 70% black
  static const Color lightDivider = Color(0x33000000); // 20% black

  // ── Functional ─────────────────────────────────────────────────
  static const Color glowBorder = primary; // Used on engine room hover
}
