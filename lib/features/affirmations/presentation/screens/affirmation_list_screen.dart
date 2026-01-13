/// Affirmation list screen.
///
/// Displays all affirmations in a scrollable list with drag-and-drop reordering.
/// Based on REQUIREMENTS.md FR-004 and FUNC-007.
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../data/models/affirmation.dart';
import '../helpers/delete_affirmation_helper.dart';
import '../providers/affirmation_provider.dart';
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
        title: Semantics(
          label: 'My Affirmations',
          header: true,
          child: const Text('My Affirmations'),
        ),
        centerTitle: true,
      ),
      body: Consumer<AffirmationProvider>(
        builder: (context, provider, child) {
          // Show loading indicator while fetching data
          if (provider.isLoading && provider.affirmations.isEmpty) {
            return Center(
              child: Semantics(
                label: 'Loading affirmations',
                liveRegion: true,
                child: const CircularProgressIndicator(),
              ),
            );
          }

          // Show error state if there's an error
          if (provider.error != null && provider.affirmations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: 'Error',
                        image: true,
                        child: Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingM),
                      Semantics(
                        header: true,
                        child: Text(
                          'Something went wrong',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      Text(
                        provider.error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      Semantics(
                        button: true,
                        enabled: true,
                        label: 'Retry',
                        hint: 'Tap to retry loading affirmations',
                        child: ElevatedButton(
                          onPressed: () => provider.loadAffirmations(),
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
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

          return Semantics(
            button: true,
            enabled: true,
            label: 'Add new affirmation',
            hint: 'Create a new affirmation',
            child: FloatingActionButton(
              onPressed: () => _navigateToAddAffirmation(context),
              tooltip: 'Add Affirmation',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  /// Builds the scrollable list of affirmation cards with drag-and-drop reordering.
  ///
  /// Memory optimization (PERF-003):
  /// - Uses ListView.builder for lazy loading (only builds visible items)
  /// - Items are recycled as user scrolls
  /// - No pagination needed for typical use (< 1000 affirmations)
  Widget _buildAffirmationList(
    BuildContext context,
    AffirmationProvider provider,
  ) {
    final affirmations = provider.affirmations;

    return RefreshIndicator(
      onRefresh: () => provider.loadAffirmations(),
      child: ReorderableListView.builder(
        padding: const EdgeInsets.only(
          top: AppDimensions.spacingM,
          bottom: AppDimensions.spacingXxl + AppDimensions.minTouchTarget,
        ),
        itemCount: affirmations.length,
        onReorder: (oldIndex, newIndex) {
          provider.reorderAffirmations(oldIndex, newIndex);
        },
        // PERF-003: Optimize for memory by disabling automatic keep-alives
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final elevation = lerpDouble(0, 8, animation.value);
              return Material(
                elevation: elevation ?? 0,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
                child: child,
              );
            },
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final affirmation = affirmations[index];
          return _ReorderableAffirmationCard(
            key: ValueKey(affirmation.id),
            index: index,
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

/// A reorderable wrapper for AffirmationCard with drag handle.
///
/// This widget wraps the AffirmationCard and adds a drag handle for
/// drag-and-drop reordering functionality.
class _ReorderableAffirmationCard extends StatelessWidget {
  const _ReorderableAffirmationCard({
    super.key,
    required this.index,
    required this.affirmation,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final int index;
  final Affirmation affirmation;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    // Build semantic label for VoiceOver
    String semanticLabel = 'Affirmation ${index + 1}: ${affirmation.text}';

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      enabled: true,
      hint: 'Double tap to edit. Swipe up or down for more actions',
      customSemanticsActions: {
        if (onEdit != null)
          const CustomSemanticsAction(label: 'Edit'): () => onEdit!(),
        if (onDelete != null)
          const CustomSemanticsAction(label: 'Delete'): () => onDelete!(),
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        child: ExcludeSemantics(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusDefault),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Drag handle on the left
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingS),
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // Affirmation content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      affirmation.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                      softWrap: true,
                    ),
                    if (onEdit != null || onDelete != null) ...[
                      const SizedBox(height: AppDimensions.spacingS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: onEdit,
                              tooltip: 'Edit',
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: onDelete,
                              tooltip: 'Delete',
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
