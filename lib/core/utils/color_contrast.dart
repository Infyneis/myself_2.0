/// Color contrast calculation utilities for WCAG compliance.
///
/// Implements WCAG 2.1 contrast ratio calculations to ensure accessibility.
/// Reference: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utilities for calculating and verifying color contrast ratios.
///
/// WCAG 2.1 Level AA Requirements:
/// - Normal text (< 18pt or < 14pt bold): minimum 4.5:1 contrast ratio
/// - Large text (≥ 18pt or ≥ 14pt bold): minimum 3:1 contrast ratio
class ColorContrast {
  ColorContrast._();

  /// Calculate the relative luminance of a color.
  ///
  /// Formula from WCAG 2.1: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  /// Returns a value between 0 (darkest) and 1 (lightest).
  static double _relativeLuminance(Color color) {
    // Convert color to RGB values between 0 and 1
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    // Apply gamma correction
    final rsRGB = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4);
    final gsRGB = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4);
    final bsRGB = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4);

    // Calculate luminance
    return 0.2126 * rsRGB + 0.7152 * gsRGB + 0.0722 * bsRGB;
  }

  /// Calculate the contrast ratio between two colors.
  ///
  /// Formula from WCAG 2.1: https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio
  /// Returns a ratio between 1:1 (no contrast) and 21:1 (maximum contrast).
  static double contrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);

    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if the contrast ratio meets WCAG AA standard for normal text.
  ///
  /// Normal text requires a minimum contrast ratio of 4.5:1.
  static bool meetsWCAG_AA_Normal(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if the contrast ratio meets WCAG AA standard for large text.
  ///
  /// Large text (≥18pt or ≥14pt bold) requires a minimum contrast ratio of 3:1.
  static bool meetsWCAG_AA_Large(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }

  /// Check if the contrast ratio meets WCAG AAA standard for normal text.
  ///
  /// WCAG AAA requires a minimum contrast ratio of 7:1 for normal text.
  static bool meetsWCAG_AAA_Normal(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Check if the contrast ratio meets WCAG AAA standard for large text.
  ///
  /// WCAG AAA requires a minimum contrast ratio of 4.5:1 for large text.
  static bool meetsWCAG_AAA_Large(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Get a human-readable grade for a contrast ratio.
  ///
  /// Returns one of: 'AAA', 'AA', 'AA Large', 'Fail'.
  static String getContrastGrade(Color foreground, Color background) {
    final ratio = contrastRatio(foreground, background);

    if (ratio >= 7.0) {
      return 'AAA (${ratio.toStringAsFixed(2)}:1)';
    } else if (ratio >= 4.5) {
      return 'AA (${ratio.toStringAsFixed(2)}:1)';
    } else if (ratio >= 3.0) {
      return 'AA Large only (${ratio.toStringAsFixed(2)}:1)';
    } else {
      return 'Fail (${ratio.toStringAsFixed(2)}:1)';
    }
  }

  /// Format a color as a hex string for display.
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
