/// Onboarding flow screen.
///
/// Manages the complete first-launch experience.
/// Based on REQUIREMENTS.md Section 8.1.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../affirmations/presentation/providers/affirmation_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../widgets/success_animation.dart';
import '../widgets/widget_setup_instructions.dart';
import 'welcome_screen.dart';

/// Onboarding flow controller widget.
///
/// Flow steps:
/// 1. Welcome screen with illustration
/// 2. Create first affirmation prompt (embedded edit screen)
/// 3. Success animation
/// 4. Widget setup instructions
/// 5. Complete onboarding and navigate to home
///
/// This widget manages the navigation through all onboarding
/// steps and marks onboarding as complete when finished.
class OnboardingFlow extends StatefulWidget {
  /// Creates an OnboardingFlow widget.
  const OnboardingFlow({super.key, this.onComplete});

  /// Callback when onboarding is completed.
  final VoidCallback? onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back button during onboarding
      canPop: false,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(),
      ),
    );
  }

  /// Builds the widget for the current step.
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: _goToCreateAffirmation,
        );
      case 1:
        return _buildCreateFirstAffirmationScreen(
          key: const ValueKey('create'),
        );
      case 2:
        return SuccessAnimation(
          key: const ValueKey('success'),
          onComplete: _goToWidgetInstructions,
          duration: const Duration(seconds: 2),
        );
      case 3:
        return WidgetSetupInstructions(
          key: const ValueKey('widget-setup'),
          onDone: _completeOnboarding,
          onSkip: _completeOnboarding,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Builds the create first affirmation screen.
  ///
  /// This wraps the affirmation edit screen with custom
  /// instructions and UI for the onboarding flow.
  Widget _buildCreateFirstAffirmationScreen({required Key key}) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(l10n.createFirstAffirmation),
        leading: Container(
          constraints: const BoxConstraints(
            minWidth: 44.0,
            minHeight: 44.0,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goToWelcome,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instruction banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              child: Column(
                children: [
                  Icon(
                    Icons.create_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createFirstAffirmationMessage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.widgetSetupDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Custom edit screen with save override
            Expanded(
              child: _OnboardingAffirmationEdit(
                onSave: _onFirstAffirmationCreated,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to welcome screen.
  void _goToWelcome() {
    setState(() {
      _currentStep = 0;
    });
  }

  /// Navigate to create affirmation screen.
  void _goToCreateAffirmation() {
    setState(() {
      _currentStep = 1;
    });
  }

  /// Handle first affirmation creation.
  void _onFirstAffirmationCreated() {
    setState(() {
      _currentStep = 2;
    });
  }

  /// Navigate to widget setup instructions.
  void _goToWidgetInstructions() {
    setState(() {
      _currentStep = 3;
    });
  }

  /// Complete onboarding and navigate to home.
  Future<void> _completeOnboarding() async {
    // Mark onboarding as complete in settings
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.completeOnboarding();

    // Navigate to home (callback to parent)
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }
}

/// Custom affirmation edit widget for onboarding.
///
/// This is a simplified version of the AffirmationEditScreen
/// that integrates with the onboarding flow.
class _OnboardingAffirmationEdit extends StatefulWidget {
  const _OnboardingAffirmationEdit({
    required this.onSave,
  });

  final VoidCallback onSave;

  @override
  State<_OnboardingAffirmationEdit> createState() =>
      _OnboardingAffirmationEditState();
}

class _OnboardingAffirmationEditState
    extends State<_OnboardingAffirmationEdit> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    // Auto-focus for better UX
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Multi-line text input
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: 8,
            maxLength: 280,
            decoration: InputDecoration(
              hintText: l10n.affirmationPlaceholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAffirmation,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.createFirstAffirmation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAffirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _showErrorSnackBar(l10n.affirmationCannotBeEmpty);
      return;
    }

    if (text.length > 280) {
      _showErrorSnackBar(l10n.affirmationTooLong);
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<AffirmationProvider>();
    final success = await provider.createAffirmationFromText(text: text);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      widget.onSave();
    } else {
      _showErrorSnackBar(
        provider.error ?? l10n.errorSavingAffirmation,
      );
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
