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
  /// Stone - Muted text
  static const Color stone = Color(0xFF6B7280);

  /// Zen Black - Primary text (light mode)
  static const Color zenBlack = Color(0xFF2D3436);

  /// Soft White - Primary text (dark mode)
  static const Color softWhite = Color(0xFFF1F3F4);

  // Semantic colors
  /// Error color for validation and destructive actions
  static const Color error = Color(0xFFE57373);

  /// Success color for positive feedback
  static const Color success = Color(0xFF81C784);
}
