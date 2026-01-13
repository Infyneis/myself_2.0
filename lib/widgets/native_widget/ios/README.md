# iOS Widget Implementation

This directory contains iOS-specific configuration and documentation for the native widget implementation.

## Feature: WIDGET-003

**Description:** Create iOS WidgetKit extension with SwiftUI for small (2x2), medium (4x2), and large (4x4) widget sizes

**Status:** ✅ Implemented

## Implementation Location

The actual iOS widget code is located in:
```
ios/MyselfWidget/
├── MyselfWidget.swift          # Main widget implementation
├── Info.plist                  # Widget configuration
├── MyselfWidget.entitlements   # App Group entitlements
├── Assets.xcassets/            # Widget assets
└── README.md                   # Detailed setup instructions
```

## Flutter Integration

The Flutter app communicates with the iOS widget through:

1. **WidgetService** (`../widget_service.dart`)
   - Handles data sharing via App Groups
   - Updates widget timeline via home_widget package

2. **IosWidgetConfig** (`ios_widget_config.dart`)
   - Defines App Group ID and keys
   - Widget kind identifier
   - Size constants

## App Group Configuration

**App Group ID:** `group.com.infyneis.myself_2_0`

This App Group must be configured in both:
- Main app target (Runner)
- Widget extension target (MyselfWidget)

## Data Flow

```
Flutter App
    ↓
WidgetService.updateWidget()
    ↓
HomeWidget.saveWidgetData() → UserDefaults (App Group)
    ↓
HomeWidget.updateWidget() → Triggers WidgetKit timeline reload
    ↓
MyselfWidgetProvider.getTimeline()
    ↓
Reads from UserDefaults (App Group)
    ↓
Widget Display on Home Screen
```

## Widget Sizes

### Small (2x2)
- Compact affirmation display
- Centered text
- Minimal UI
- SF Symbols icon for empty state

### Medium (4x2)
- Affirmation with icon
- Horizontal layout
- More breathing room
- Better for longer text

### Large (4x4)
- Full affirmation display
- Centered vertical layout
- Large icon
- Branding footer
- Best for longer affirmations

## Theme Support

The widget adapts to three theme modes:
- **Light:** Bright, clean appearance
- **Dark:** Deep, comfortable night mode
- **System:** Follows iOS system setting

Theme is controlled via shared data:
```dart
await widgetService.shareSettings(
  themeMode: 'dark', // or 'light' or 'system'
  widgetRotationEnabled: true,
  fontSizeMultiplier: 1.2,
);
```

## Accessibility

- Font size multiplier support (0.8 - 1.4x)
- VoiceOver labels (coming in A11Y-001)
- Minimum font sizes with scale factors
- High contrast color ratios

## Setup Instructions

**Important:** The widget extension must be manually added in Xcode. See detailed instructions in:
`ios/MyselfWidget/README.md`

### Quick Setup Checklist

- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Add Widget Extension target named `MyselfWidget`
- [ ] Replace generated files with custom implementation
- [ ] Add App Groups capability to both targets
- [ ] Configure App Group ID: `group.com.infyneis.myself_2_0`
- [ ] Set entitlements files in build settings
- [ ] Build and test

## Testing

### In Xcode
1. Open `MyselfWidget.swift`
2. Use SwiftUI previews to view all sizes
3. Test light/dark themes
4. Verify empty states

### On Device/Simulator
1. Build and run the Flutter app
2. Add widget to home screen
3. Create an affirmation in the app
4. Verify widget updates

## Troubleshooting

### Widget shows "Unable to Load"
- Check App Group ID matches in both targets
- Verify entitlements are configured
- Clean build folder and rebuild

### Widget not updating
- Ensure `WidgetService.initialize()` was called
- Check that `updateWidget()` is being called after data changes
- Verify App Group ID in widget code matches configuration

### Build errors
- Ensure iOS deployment target is 14.0+
- Check that Swift version is set
- Verify all files are added to correct target

## Code Structure

### MyselfWidget.swift

```swift
// Timeline Entry - Data model
struct MyselfWidgetEntry: TimelineEntry { ... }

// Timeline Provider - Data source
struct MyselfWidgetProvider: TimelineProvider { ... }

// Widget Views
struct MyselfWidgetSmallView: View { ... }
struct MyselfWidgetMediumView: View { ... }
struct MyselfWidgetLargeView: View { ... }

// Main Entry View - Routes to size-specific views
struct MyselfWidgetEntryView: View { ... }

// Widget Definition
@main
struct MyselfWidget: Widget { ... }
```

## Dependencies

- **WidgetKit** - Apple's widget framework
- **SwiftUI** - UI framework for widget views
- **home_widget** package - Flutter integration

## Related Features

- **WIDGET-001:** ✅ Home widget package integration
- **WIDGET-002:** ✅ Data sharing implementation
- **WIDGET-003:** ✅ iOS widget extension (this feature)
- **WIDGET-004:** ⏳ Timeline provider with unlock events
- **WIDGET-007:** ⏳ Tap to open app
- **WIDGET-008:** ⏳ Placeholder state enhancements
- **WIDGET-010:** ⏳ Advanced theme support

## Performance Considerations

- Widgets are updated via timeline, not continuous polling
- Data is read from UserDefaults (fast)
- No network calls or heavy processing
- SwiftUI views are efficient and lightweight
- Timeline policy set to `.atEnd` to minimize background activity

## Security & Privacy

- All data stored locally in App Group
- No network transmission
- Sandboxed between app and widget
- No sensitive data stored
- Compliant with iOS privacy guidelines

## Resources

- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [home_widget Package](https://pub.dev/packages/home_widget)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [App Groups Documentation](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

---

**Last Updated:** 2026-01-13
**Feature Status:** Complete (requires manual Xcode setup)
