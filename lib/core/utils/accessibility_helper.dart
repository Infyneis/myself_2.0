/// Accessibility helper utilities.
///
/// Provides widgets and utilities to ensure accessibility compliance,
/// particularly for touch target sizes (NFR-014).
library;

import 'package:flutter/material.dart';
import '../constants/dimensions.dart';

/// Ensures a widget meets the minimum touch target size requirement.
///
/// Wraps the child in a Container with minimum constraints of 44x44 points
/// to ensure it's accessible to all users, including those with motor
/// impairments.
///
/// Usage:
/// ```dart
/// AccessibleTouchTarget(
///   child: IconButton(
///     icon: Icon(Icons.settings),
///     onPressed: () {},
///   ),
/// )
/// ```
class AccessibleTouchTarget extends StatelessWidget {
  /// Creates an AccessibleTouchTarget widget.
  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  /// The widget to ensure meets minimum touch target size.
  final Widget child;

  /// Alignment of the child within the minimum touch target area.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppDimensions.minTouchTarget,
        minHeight: AppDimensions.minTouchTarget,
      ),
      alignment: alignment,
      child: child,
    );
  }
}

/// Extension methods for making widgets accessible.
extension AccessibilityWidgetExtensions on Widget {
  /// Wraps this widget to ensure it meets minimum touch target size.
  ///
  /// Example:
  /// ```dart
  /// IconButton(
  ///   icon: Icon(Icons.edit),
  ///   onPressed: () {},
  /// ).withMinTouchTarget()
  /// ```
  Widget withMinTouchTarget({AlignmentGeometry alignment = Alignment.center}) {
    return AccessibleTouchTarget(
      alignment: alignment,
      child: this,
    );
  }
}

/// Creates a ButtonStyle with minimum touch target size for various button types.
class AccessibleButtonStyles {
  AccessibleButtonStyles._();

  /// Creates a TextButton style with minimum touch target size.
  static ButtonStyle textButton(BuildContext context) {
    return TextButton.styleFrom(
      minimumSize: const Size(
        AppDimensions.minTouchTarget,
        AppDimensions.minTouchTarget,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
    );
  }

  /// Creates an ElevatedButton style with minimum touch target size.
  static ButtonStyle elevatedButton(BuildContext context) {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(
        AppDimensions.minTouchTarget,
        AppDimensions.minTouchTarget,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
    );
  }

  /// Creates an OutlinedButton style with minimum touch target size.
  static ButtonStyle outlinedButton(BuildContext context) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(
        AppDimensions.minTouchTarget,
        AppDimensions.minTouchTarget,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
    );
  }

  /// Creates an IconButton style with minimum touch target size.
  static ButtonStyle iconButton(BuildContext context) {
    return IconButton.styleFrom(
      minimumSize: const Size(
        AppDimensions.minTouchTarget,
        AppDimensions.minTouchTarget,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingS),
    );
  }

  /// Creates a FilledButton style with minimum touch target size.
  static ButtonStyle filledButton(BuildContext context) {
    return FilledButton.styleFrom(
      minimumSize: const Size(
        AppDimensions.minTouchTarget,
        AppDimensions.minTouchTarget,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
    );
  }
}
