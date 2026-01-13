/// Affirmation edit screen.
///
/// Screen for creating and editing affirmations.
/// Based on REQUIREMENTS.md FR-001, FR-002, FR-006.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../data/models/affirmation.dart';
import '../providers/affirmation_provider.dart';
import '../widgets/affirmation_input.dart';

/// Screen for creating or editing an affirmation.
///
/// Features:
/// - Multi-line text input with natural line breaks
/// - Character counter (max 280)
/// - Save and cancel actions
/// - Validation feedback
/// - Unsaved changes warning
class AffirmationEditScreen extends StatefulWidget {
  /// Creates an AffirmationEditScreen widget.
  ///
  /// [affirmationId] - Optional ID of existing affirmation to edit.
  /// If null, creates a new affirmation.
  const AffirmationEditScreen({
    super.key,
    this.affirmationId,
  });

  /// ID of the affirmation to edit, or null for new affirmation.
  final String? affirmationId;

  @override
  State<AffirmationEditScreen> createState() => _AffirmationEditScreenState();
}

class _AffirmationEditScreenState extends State<AffirmationEditScreen> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  String? _originalText;
  bool _isSaving = false;

  /// Whether this screen is for editing an existing affirmation.
  bool get isEditing => widget.affirmationId != null;

  /// Whether the text has been modified from the original.
  bool get hasChanges => _textController.text != (_originalText ?? '');

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // Load existing affirmation if editing
    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingAffirmation();
      });
    }
  }

  void _loadExistingAffirmation() {
    final provider = context.read<AffirmationProvider>();
    final affirmation = provider.getAffirmationById(widget.affirmationId!);
    if (affirmation != null) {
      setState(() {
        _textController.text = affirmation.text;
        _originalText = affirmation.text;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showUnsavedChangesDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            label: isEditing ? 'Edit Affirmation' : 'New Affirmation',
            header: true,
            child: Text(isEditing ? 'Edit Affirmation' : 'New Affirmation'),
          ),
          actions: [
            Semantics(
              button: true,
              enabled: !_isSaving,
              label: 'Save',
              hint: 'Save affirmation and return to previous screen',
              child: TextButton(
                onPressed: _isSaving ? null : _saveAffirmation,
                child: _isSaving
                    ? Semantics(
                        label: 'Saving affirmation',
                        liveRegion: true,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Help text for multi-line input
                Semantics(
                  hint: 'Instructions for text input',
                  child: Text(
                    'Write your affirmation below. Press Enter for new lines.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingM),

                // Multi-line text input
                Semantics(
                  textField: true,
                  label: 'Affirmation text',
                  hint: 'Enter your affirmation text. Maximum 280 characters',
                  child: AffirmationInput(
                    controller: _textController,
                    focusNode: _focusNode,
                    hintText: isEditing
                        ? 'Edit your affirmation...'
                        : 'I am worthy of love and respect.\n\nEvery day I grow stronger.',
                    autofocus: !isEditing, // Autofocus only for new affirmations
                    onChanged: (_) {
                      // Trigger rebuild to update save button state
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Preview section for multi-line display
                if (_textController.text.isNotEmpty) ...[
                  Semantics(
                    header: true,
                    child: Text(
                      'Preview',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Semantics(
                    label: 'Preview: ${_textController.text}',
                    readOnly: true,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingM),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadiusDefault),
                      ),
                      child: ExcludeSemantics(
                        child: Text(
                          _textController.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveAffirmation() async {
    final text = _textController.text.trim();

    // Validate text
    final validationError = Affirmation.validateText(text);
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<AffirmationProvider>();
    bool success;

    if (isEditing) {
      success = await provider.editAffirmationFromText(
        id: widget.affirmationId!,
        text: text,
      );
    } else {
      success = await provider.createAffirmationFromText(text: text);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      _showErrorSnackBar(provider.error ?? 'Failed to save affirmation');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
