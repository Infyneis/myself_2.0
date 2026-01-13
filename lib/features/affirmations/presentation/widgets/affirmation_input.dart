/// Affirmation input widget.
///
/// Reusable text input component for creating/editing affirmations.
/// Based on REQUIREMENTS.md FR-001, FR-005, FR-006.
library;

import 'package:flutter/material.dart';
import '../../../../core/constants/dimensions.dart';

/// A text input widget for entering affirmations.
///
/// Features:
/// - Multi-line text input
/// - Character counter showing progress toward 280 char limit
/// - Visual feedback when approaching/exceeding limit
///
/// Note: Full implementation will be completed in UI-010.
class AffirmationInput extends StatelessWidget {
  /// Creates an AffirmationInput widget.
  const AffirmationInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.maxLength = AppDimensions.maxAffirmationLength,
    this.autofocus = false,
  });

  /// Controller for the text input.
  final TextEditingController controller;

  /// Focus node for the input.
  final FocusNode? focusNode;

  /// Hint text to display when input is empty.
  final String? hintText;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Maximum character length (default: 280).
  final int maxLength;

  /// Whether to autofocus on mount.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          maxLines: null,
          minLines: 3,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter your affirmation...',
            counterText: '', // Hide default counter, we show our own
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final length = value.text.length;
            final isNearLimit = length > maxLength * 0.9;
            final isAtLimit = length >= maxLength;

            return Text(
              '$length / $maxLength',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAtLimit
                        ? Theme.of(context).colorScheme.error
                        : isNearLimit
                            ? Colors.orange
                            : null,
                  ),
            );
          },
        ),
      ],
    );
  }
}
