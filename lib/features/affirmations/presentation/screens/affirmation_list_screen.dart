/// Affirmation list screen.
///
/// Displays all affirmations in a scrollable list.
/// Based on REQUIREMENTS.md FR-004.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../helpers/delete_affirmation_helper.dart';
import '../providers/affirmation_provider.dart';
import '../widgets/affirmation_card.dart';
import '../widgets/empty_affirmations_state.dart';
import 'affirmation_edit_screen.dart';

/// Screen displaying all saved affirmations.
///
/// Features:
/// - Scrollable list of affirmation cards
/// - Edit/delete actions for each affirmation
/// - Empty state when no affirmations exist
/// - Add button to create new affirmations
class AffirmationListScreen extends StatefulWidget {
  /// Creates an AffirmationListScreen widget.
  const AffirmationListScreen({super.key});

  @override
  State<AffirmationListScreen> createState() => _AffirmationListScreenState();
}

class _AffirmationListScreenState extends State<AffirmationListScreen> {
  @override
  void initState() {
    super.initState();
    // Load affirmations when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffirmationProvider>().loadAffirmations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Affirmations'),
        centerTitle: true,
      ),
      body: Consumer<AffirmationProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching data
          if (provider.isLoading && provider.affirmations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error state if there's an error
          if (provider.error != null && provider.affirmations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    ElevatedButton(
                      onPressed: () => provider.loadAffirmations(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show empty state if no affirmations exist
          if (!provider.hasAffirmations) {
            return EmptyAffirmationsState(
              onAddAffirmation: () => _navigateToAddAffirmation(context),
            );
          }

          // Show the scrollable list of affirmations
          return _buildAffirmationList(context, provider);
        },
      ),
      floatingActionButton: Consumer<AffirmationProvider>(
        builder: (context, provider, child) {
          // Only show FAB if there are affirmations (empty state has its own button)
          if (!provider.hasAffirmations) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _navigateToAddAffirmation(context),
            tooltip: 'Add Affirmation',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  /// Builds the scrollable list of affirmation cards.
  Widget _buildAffirmationList(
    BuildContext context,
    AffirmationProvider provider,
  ) {
    final affirmations = provider.affirmations;

    return RefreshIndicator(
      onRefresh: () => provider.loadAffirmations(),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppDimensions.spacingM,
          bottom: AppDimensions.spacingXxl + AppDimensions.minTouchTarget,
        ),
        itemCount: affirmations.length,
        itemBuilder: (context, index) {
          final affirmation = affirmations[index];
          return AffirmationCard(
            affirmation: affirmation,
            onTap: () => _navigateToEditAffirmation(context, affirmation.id),
            onEdit: () => _navigateToEditAffirmation(context, affirmation.id),
            onDelete: () => _deleteAffirmation(context, affirmation),
          );
        },
      ),
    );
  }

  /// Navigates to the affirmation edit screen to add a new affirmation.
  void _navigateToAddAffirmation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AffirmationEditScreen(),
      ),
    );
  }

  /// Navigates to the affirmation edit screen to edit an existing affirmation.
  void _navigateToEditAffirmation(BuildContext context, String affirmationId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AffirmationEditScreen(
          affirmationId: affirmationId,
        ),
      ),
    );
  }

  /// Deletes an affirmation with confirmation dialog.
  Future<void> _deleteAffirmation(
    BuildContext context,
    affirmation,
  ) async {
    await DeleteAffirmationHelper.deleteWithConfirmation(
      context: context,
      affirmation: affirmation,
      onSuccess: () => DeleteAffirmationHelper.showSuccessSnackBar(context),
      onError: (error) => DeleteAffirmationHelper.showErrorSnackBar(context, error),
    );
  }
}
