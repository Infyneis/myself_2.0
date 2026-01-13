/// Affirmation input widget.
///
/// Reusable text input component for creating/editing affirmations.
/// Based on REQUIREMENTS.md FR-001, FR-005, FR-006.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// A text input widget for entering affirmations.
///
/// Features:
/// - Multi-line text input with natural line break support
/// - Expands automatically as text grows
/// - Character counter showing progress toward 280 char limit
/// - Visual feedback when approaching/exceeding limit
/// - Keyboard type optimized for multi-line text entry
/// - Accessibility support with proper semantics
///
/// The input uses [TextInputType.multiline] which enables the Enter key
/// to create new lines instead of submitting the form.
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
    this.minLines = 3,
    this.maxLines,
    this.textInputAction,
  });

  /// Controller for the text input.
  final TextEditingController controller;

  /// Focus node for the input.
  final FocusNode? focusNode;

  /// Hint text to display when input is empty.
  /// Supports multi-line hint text for showing examples.
  final String? hintText;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Maximum character length (default: 280).
  final int maxLength;

  /// Whether to autofocus on mount.
  final bool autofocus;

  /// Minimum number of lines to display (default: 3).
  final int minLines;

  /// Maximum number of lines before scrolling.
  /// If null, the input expands indefinitely.
  final int? maxLines;

  /// The action button to use for the on-screen keyboard.
  /// Defaults to [TextInputAction.newline] for multi-line support.
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.affirmationPlaceholder,
          hint: l10n.affirmationPlaceholder,
          textField: true,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            // Multi-line support configuration
            keyboardType: TextInputType.multiline,
            textInputAction: textInputAction ?? TextInputAction.newline,
            maxLines: maxLines, // null allows unlimited expansion
            minLines: minLines,
            maxLength: maxLength,
            // Allow new lines via enter key
            inputFormatters: [
              // No formatter to restrict newlines - we want them!
              LengthLimitingTextInputFormatter(maxLength),
            ],
            decoration: InputDecoration(
              hintText: hintText ?? l10n.affirmationPlaceholder,
              hintMaxLines: 5, // Allow multi-line hints
              counterText: '', // Hide default counter, we show our own
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
              ),
              contentPadding: const EdgeInsets.all(AppDimensions.spacingM),
              // Visual feedback for text area
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLowest,
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5, // Better line spacing for readability
            ),
            onChanged: onChanged,
            // Enable text selection toolbar
            enableInteractiveSelection: true,
            // Allow smart quotes and dashes
            smartQuotesType: SmartQuotesType.enabled,
            smartDashesType: SmartDashesType.enabled,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        // Character counter with visual feedback
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final length = value.text.length;
            final lineCount = '\n'.allMatches(value.text).length + 1;
            final isNearLimit = length > maxLength * 0.9;
            final isAtLimit = length >= maxLength;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Line count indicator
                Text(
                  lineCount == 1 ? '1 line' : '$lineCount lines',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // Character counter
                Text(
                  '$length / $maxLength',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isAtLimit
                        ? theme.colorScheme.error
                        : isNearLimit
                            ? Colors.orange
                            : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isAtLimit ? FontWeight.bold : null,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
