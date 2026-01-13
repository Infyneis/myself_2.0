/// Affirmations feature module exports.
///
/// Provides easy access to all affirmation-related functionality.
library;

// Data
export 'data/models/affirmation.dart';
export 'data/repositories/affirmation_repository.dart';

// Domain
export 'domain/usecases/get_random_affirmation.dart';

// Presentation
export 'presentation/providers/affirmation_provider.dart';
export 'presentation/screens/home_screen.dart';
export 'presentation/screens/affirmation_list_screen.dart';
export 'presentation/screens/affirmation_edit_screen.dart';
export 'presentation/widgets/affirmation_card.dart';
export 'presentation/widgets/affirmation_input.dart';
