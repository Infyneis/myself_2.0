/// Success animation widget.
///
/// Displayed after creating the first affirmation.
/// Based on REQUIREMENTS.md Section 8.1.
library;

import 'package:flutter/material.dart';

/// Success animation widget.
///
/// Shows a celebratory animation when the user
/// successfully creates their first affirmation.
///
/// Note: Full implementation will be completed in UI-015.
class SuccessAnimation extends StatelessWidget {
  /// Creates a SuccessAnimation widget.
  const SuccessAnimation({
    super.key,
    this.onComplete,
  });

  /// Callback when the animation completes.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    // Placeholder implementation - will be completed in UI-015
    return const Center(
      child: Icon(
        Icons.check_circle_outline,
        size: 100,
        color: Colors.green,
      ),
    );
  }
}
