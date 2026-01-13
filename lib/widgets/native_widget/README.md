# Native Widget Data Sharing

This directory contains the implementation for sharing data between the Flutter app and native widgets on iOS and Android.

## Overview

**Feature ID:** WIDGET-002
**Implementation:** Data sharing between Flutter app and native widgets using SharedDefaults (iOS) and SharedPreferences (Android)

## Architecture

### Platform-Specific Storage

#### iOS - SharedDefaults (UserDefaults with App Groups)
- **Storage Location:** UserDefaults within App Group container
- **App Group ID:** `group.com.infyneis.myself_2_0`
- **Access:** Shared between main app and WidgetKit extension
- **Data Format:** Property list (plist) format
- **Configuration Required:**
  - Add App Group capability to main app target
  - Add App Group capability to widget extension target
  - Use same App Group ID in both targets

#### Android - SharedPreferences
- **Storage Location:** App's private storage (`/data/data/com.infyneis.myself_2_0/shared_prefs/`)
- **Access:** Shared between main app and AppWidgetProvider
- **Data Format:** XML format
- **Configuration Required:**
  - Use MODE_PRIVATE for SharedPreferences
  - Ensure consistent preference file naming

## Data Types Shared

### 1. Current Affirmation
- `affirmation_text` (String): The text of the current affirmation
- `affirmation_id` (String): UUID of the current affirmation
- `last_update` (String): ISO 8601 timestamp of last update

### 2. Settings
- `theme_mode` (String): Theme mode - "light", "dark", or "system"
- `widget_rotation_enabled` (Boolean): Whether widget rotation is enabled
- `font_size_multiplier` (Double): Font size multiplier for accessibility (0.8 - 1.4)

### 3. Affirmations List
- `affirmations_list` (String): JSON-encoded list of affirmations
- `affirmations_count` (Integer): Number of affirmations in the list
- `has_affirmations` (Boolean): Whether any affirmations exist

### Example JSON Structure for Affirmations List
```json
[
  {
    "id": "abc-123-def-456",
    "text": "I am confident and capable",
    "displayCount": 5,
    "isActive": true
  },
  {
    "id": "xyz-789-uvw-012",
    "text": "I embrace challenges and grow from them",
    "displayCount": 3,
    "isActive": true
  }
]
```

## Usage

### Basic Usage

```dart
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';

final widgetService = WidgetService();

// Initialize (call once during app startup)
await widgetService.initialize();

// Update current affirmation
await widgetService.updateWidget(
  affirmationText: 'I am confident and capable',
  affirmationId: 'abc-123',
);

// Share settings
await widgetService.shareSettings(
  themeMode: 'dark',
  widgetRotationEnabled: true,
  fontSizeMultiplier: 1.2,
);

// Share list of affirmations
await widgetService.shareAffirmationsList([
  {'id': '1', 'text': 'Affirmation 1'},
  {'id': '2', 'text': 'Affirmation 2'},
]);
```

### Using WidgetDataSync Helper

```dart
import 'package:myself_2_0/widgets/native_widget/widget_data_sync.dart';
import 'package:myself_2_0/widgets/native_widget/widget_service.dart';

final sync = WidgetDataSync(widgetService: WidgetService());

// Sync current affirmation
await sync.syncCurrentAffirmation(affirmation);

// Sync settings
await sync.syncSettings(settings);

// Sync all data
await sync.syncAllData(
  currentAffirmation: affirmation,
  allAffirmations: allAffirmations,
  settings: settings,
);

// Handle affirmation lifecycle events
await sync.onAffirmationCreated(
  newAffirmation: affirmation,
  allAffirmations: allAffirmations,
  setAsCurrent: true,
);

await sync.onAffirmationUpdated(
  updatedAffirmation: affirmation,
  allAffirmations: allAffirmations,
  currentAffirmationId: currentId,
);

await sync.onAffirmationDeleted(
  deletedId: id,
  allAffirmations: allAffirmations,
  currentAffirmationId: currentId,
);
```

## Integration with Providers

### AffirmationProvider Integration

```dart
class AffirmationProvider extends ChangeNotifier {
  final WidgetDataSync _widgetSync;

  Future<void> createAffirmation(Affirmation affirmation) async {
    // ... create affirmation logic

    // Sync with widget
    await _widgetSync.onAffirmationCreated(
      newAffirmation: affirmation,
      allAffirmations: _affirmations,
      setAsCurrent: true,
    );
  }

  Future<void> updateAffirmation(Affirmation affirmation) async {
    // ... update affirmation logic

    // Sync with widget
    await _widgetSync.onAffirmationUpdated(
      updatedAffirmation: affirmation,
      allAffirmations: _affirmations,
      currentAffirmationId: _currentAffirmation?.id,
    );
  }
}
```

### SettingsProvider Integration

```dart
class SettingsProvider extends ChangeNotifier {
  final WidgetDataSync _widgetSync;

  Future<void> updateSettings(Settings settings) async {
    // ... update settings logic

    // Sync with widget
    await _widgetSync.onSettingsUpdated(settings);
  }
}
```

## Native Widget Implementation

### iOS (WidgetKit - Swift)

```swift
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.infyneis.myself_2_0")

        // Read shared data
        let affirmationText = userDefaults?.string(forKey: "affirmation_text") ?? "No affirmation"
        let themeMode = userDefaults?.string(forKey: "theme_mode") ?? "system"
        let fontSizeMultiplier = userDefaults?.double(forKey: "font_size_multiplier") ?? 1.0

        // Create timeline entry
        let entry = SimpleEntry(
            date: Date(),
            affirmation: affirmationText,
            themeMode: themeMode,
            fontSizeMultiplier: fontSizeMultiplier
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
```

### Android (AppWidget - Kotlin)

```kotlin
class MyselfWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Read shared data
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val affirmationText = prefs.getString("flutter.affirmation_text", "No affirmation")
        val themeMode = prefs.getString("flutter.theme_mode", "system")
        val fontSizeMultiplier = prefs.getFloat("flutter.font_size_multiplier", 1.0f)

        // Update widgets
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId, affirmationText, themeMode)
        }
    }
}
```

## Testing

Run the widget service tests:

```bash
flutter test test/unit/widget_service_test.dart
```

The tests verify:
- Data sharing methods don't crash
- Settings can be shared and retrieved
- Affirmations list can be serialized/deserialized
- Complex data structures are handled correctly
- Error handling is graceful

## Troubleshooting

### iOS Widget Not Updating
1. Verify App Group ID matches in both targets
2. Check that App Group capability is enabled
3. Ensure widget extension has proper entitlements
4. Check Xcode console for errors

### Android Widget Not Updating
1. Verify SharedPreferences file name matches
2. Check that widget provider is registered in AndroidManifest.xml
3. Ensure proper permissions in manifest
4. Check logcat for errors

### Data Not Persisting
1. Verify `initialize()` is called before any data operations
2. Check that data types match expected types
3. Ensure JSON serialization is correct for complex data
4. Verify platform-specific storage is accessible

## Performance Considerations

1. **Data Size**: Keep affirmations list reasonable (< 100 items) for JSON serialization performance
2. **Update Frequency**: Batch updates when possible using `shareAllWidgetData()`
3. **Background Updates**: Widget updates are async and won't block UI
4. **Memory**: JSON strings are stored in memory temporarily during serialization

## Security

- All data is stored locally on the device
- No network transmission of widget data
- iOS App Groups are sandboxed per app
- Android SharedPreferences are private to the app
- No sensitive data should be stored in widget data

## Future Enhancements

- WIDGET-003: iOS WidgetKit extension implementation
- WIDGET-004: iOS widget timeline provider
- WIDGET-005: Android widget provider implementation
- WIDGET-006: Android unlock broadcast receiver
- WIDGET-009: Real-time widget updates on data changes
