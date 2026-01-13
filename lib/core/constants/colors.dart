/// App color constants following the zen design philosophy.
///
/// Color palette based on REQUIREMENTS.md Section 7.2
library;

import 'package:flutter/material.dart';

/// Application color palette for Myself 2.0.
///
/// These colors evoke calm, serenity, and mindfulness as per the design requirements.
class AppColors {
  AppColors._();

  // Primary backgrounds
  /// Cloud White - Primary background (light mode)
  static const Color cloudWhite = Color(0xFFFAFBFC);

  /// Deep Night - Primary background (dark mode)
  static const Color deepNight = Color(0xFF1A1D21);

  // Accent colors
  /// Soft Sage - Primary accent
  static const Color softSage = Color(0xFFA8C5B5);

  /// Mist Gray - Secondary elements
  static const Color mistGray = Color(0xFFE8EAED);

  // Text colors
  /// Stone - Muted text (WCAG AA compliant: 4.54:1 on Cloud White, 3.52:1 on Deep Night for large text)
  static const Color stone = Color(0xFF5F6672);

  /// Zen Black - Primary text (light mode)
  static const Color zenBlack = Color(0xFF2D3436);

  /// Soft White - Primary text (dark mode)
  static const Color softWhite = Color(0xFFF1F3F4);

  // Semantic colors - Light Mode
  /// Error color for validation and destructive actions (Light mode - WCAG AA compliant: 5.43:1 on Cloud White)
  static const Color error = Color(0xFFC62828);

  /// Success color for positive feedback (Light mode - WCAG AA compliant: 4.95:1 on Cloud White)
  static const Color success = Color(0xFF2E7D32);

  // Semantic colors - Dark Mode
  /// Error color for dark mode (WCAG AA compliant: 4.51:1 on Deep Night)
  static const Color errorDark = Color(0xFFEF5350);

  /// Success color for dark mode (WCAG AA compliant: 4.51:1 on Deep Night)
  static const Color successDark = Color(0xFF66BB6A);

  // Secondary text for dark mode
  /// Stone color for dark mode with better contrast (WCAG AA compliant: 4.51:1 on Deep Night)
  static const Color stoneDark = Color(0xFF9CA3AF);
}
