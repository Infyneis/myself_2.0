# Integration Tests

This directory contains integration tests for the Myself 2.0 application. Integration tests verify complete user flows and interactions across multiple screens and components.

## Test Files

### `onboarding_flow_test.dart` (TEST-008)
Comprehensive integration tests for the complete onboarding user flow, including:
- Welcome screen display and navigation
- First affirmation creation with validation
- Success animation display
- Widget setup instructions (iOS and Android)
- Onboarding completion and home screen navigation
- State persistence across app restarts
- Error handling and validation scenarios

### `offline_functionality_test.dart` (SEC-002)
Tests to verify all core functionality works without internet connectivity.

## Running Integration Tests

Integration tests require a physical device or emulator to run.

### Prerequisites
1. Ensure Flutter is installed and configured
2. Connect a physical device or start an emulator
3. Verify device connection: `flutter devices`

### Running All Integration Tests
```bash
flutter test integration_test/
```

### Running a Specific Test File
```bash
# Run onboarding flow tests
flutter test integration_test/onboarding_flow_test.dart

# Run offline functionality tests
flutter test integration_test/offline_functionality_test.dart
```

### Running on a Specific Device
```bash
# List available devices
flutter devices

# Run on a specific device
flutter test integration_test/onboarding_flow_test.dart -d <device-id>
```

### Running with Driver (for more detailed output)
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/onboarding_flow_test.dart
```

## Test Structure

Each integration test follows this pattern:

1. **Setup**: Initialize Hive, create repositories, providers, and services
2. **Test Execution**: Pump widgets, simulate user interactions, verify state
3. **Assertions**: Verify UI elements, state changes, and data persistence
4. **Teardown**: Close Hive and clean up resources

## Common Test Patterns

### Navigating Through Screens
```dart
// Find and tap a button
final button = find.ancestor(
  of: find.text('Button Text'),
  matching: find.byType(ElevatedButton),
);
await tester.tap(button);
await tester.pumpAndSettle();
```

### Entering Text
```dart
await tester.enterText(find.byType(TextField), 'Test text');
await tester.pumpAndSettle();
```

### Waiting for Animations
```dart
// Wait for a specific duration
await tester.pump(const Duration(seconds: 2));
await tester.pumpAndSettle();
```

### Verifying State
```dart
// Load data and verify
await provider.loadData();
expect(provider.data.length, equals(1));
```

## Debugging Integration Tests

### Enable Verbose Logging
```bash
flutter test integration_test/onboarding_flow_test.dart -v
```

### Take Screenshots During Tests
Add this to your test:
```dart
await tester.takeScreenshot('screenshot_name');
```

### Print Debug Information
```dart
debugPrint('Current widget tree:');
debugDumpApp();
```

## Test Coverage

The integration tests cover:
- ✅ Complete onboarding flow (TEST-008)
- ✅ Affirmation CRUD operations
- ✅ Offline functionality (SEC-002)
- ✅ State persistence
- ✅ Navigation flows
- ✅ Input validation
- ✅ Error handling
- ⏳ Widget data synchronization (TEST-010) - To be implemented
- ⏳ Full CRUD user flows (TEST-009) - To be implemented

## Troubleshooting

### "No devices found"
- Connect a physical device via USB or start an emulator
- Run `flutter devices` to verify connection
- For iOS: Ensure Xcode is installed and device is trusted
- For Android: Ensure USB debugging is enabled

### "Failed to load test"
- Ensure all dependencies are installed: `flutter pub get`
- Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
- Check for compilation errors: `flutter analyze`

### "Hive box already open"
- Tests properly close Hive in tearDown
- If tests fail mid-execution, manually close Hive boxes or restart the test

### Slow Test Execution
- Integration tests are slower than unit tests by design
- They test complete user flows with real UI interactions
- Use `--concurrency=1` to run tests sequentially if needed

## Best Practices

1. **Isolation**: Each test should be independent and not rely on others
2. **Cleanup**: Always close resources in `tearDown()`
3. **Reset State**: Reset onboarding/settings state in `setUp()` for fresh tests
4. **Descriptive Names**: Use clear, descriptive test names
5. **Reason Messages**: Include reason messages in `expect()` calls
6. **Pump and Settle**: Always call `pumpAndSettle()` after interactions
7. **Find Widgets Carefully**: Use specific finders to avoid ambiguity

## Resources

- [Flutter Integration Testing Documentation](https://docs.flutter.dev/testing/integration-tests)
- [Flutter Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Test Package](https://pub.dev/packages/integration_test)
