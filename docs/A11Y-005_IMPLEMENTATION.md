# A11Y-005: System Font Scaling Implementation

## Overview
This document describes the implementation of system font scaling support for users with visual impairments, as required by A11Y-005 and NFR-016.

## Feature Description
The app now fully supports system-level font scaling preferences set by users in their device's accessibility settings. This ensures that users with visual impairments can read all text in the application at their preferred size.

## Implementation Details

### 1. System Font Scaling Support (`lib/app.dart`)

The app now respects both:
- **System text scale factor**: Set by the user in their device's accessibility settings (iOS Settings → Accessibility → Display & Text Size, or Android Settings → Accessibility → Font Size)
- **App-specific multiplier**: Set by the user in the app's settings screen (0.8x to 1.4x)

These values are multiplied together to provide maximum flexibility:

```dart
// Get the system's text scale factor (for accessibility settings)
final systemTextScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);

// Combine system font scaling with app's custom multiplier
final combinedScaleFactor = systemTextScaleFactor * settingsProvider.fontSizeMultiplier;
```

### 2. Supported Scaling Ranges

#### System Scale Factor (from device settings)
- **iOS**:
  - Standard: 0.82x to 1.35x
  - Larger Accessibility Sizes: up to 3.1x
- **Android**:
  - Standard: 0.85x to 1.3x
  - Accessibility: up to 2.0x

#### App Multiplier (from app settings)
- Range: 0.8x to 1.4x (80% to 140%)
- Default: 1.0x (100%)
- Adjustable via slider in Settings

#### Combined Maximum
- When both are at maximum: up to 4.34x (3.1 × 1.4)
- This exceeds WCAG 2.1 Level AA requirements (200% minimum)

### 3. Settings Integration

The font size multiplier is:
- **Stored**: In `Settings` model (`lib/features/settings/data/settings_model.dart`)
- **Persisted**: Via `SettingsRepository` to Hive storage
- **Managed**: By `SettingsProvider` state management
- **Configured**: In Settings screen with live preview and slider

### 4. User Interface

The Settings screen (`lib/features/settings/presentation/screens/settings_screen.dart`) provides:
- **Slider control**: 6 steps from 80% to 140%
- **Live preview**: "Sample Affirmation" text that updates in real-time
- **Visual feedback**: Percentage indicator showing current size
- **Accessibility**: Full VoiceOver/TalkBack support with semantic labels

### 5. Text Rendering

All text throughout the app automatically scales because:
1. The `MaterialApp` builder wraps the entire app with scaled `MediaQuery`
2. All widgets use theme-based text styles
3. Google Fonts integration works seamlessly with `TextScaler`
4. Custom text sizes are properly scaled through `TextStyle.fontSize`

## Accessibility Compliance

### WCAG 2.1 Level AA
- **Requirement**: Text must be resizable up to 200% without loss of content or functionality
- **Our Implementation**: Supports up to 434% (system 3.1x × app 1.4x)
- **Status**: ✅ **EXCEEDS** requirements

### Platform Guidelines
- **iOS Human Interface Guidelines**: ✅ Supports Dynamic Type
- **Android Material Design**: ✅ Supports system font scaling
- **Both platforms**: ✅ Respects accessibility settings

## Testing

Comprehensive test suite in `test/accessibility/system_font_scaling_test.dart`:

### Unit Tests
- ✅ Respects system default text scale (1.0)
- ✅ Respects system increased text scale (1.3)
- ✅ Respects system maximum text scale (2.0)
- ✅ Combines system scale with app multiplier
- ✅ Works with reduced system scale
- ✅ Maintains functionality with extreme scaling (3.0)

### Integration Tests
- ✅ Text widgets scale with system settings
- ✅ Buttons scale with system settings
- ✅ Maintains minimum touch target (44x44 points)

### Settings Tests
- ✅ Settings model stores font size multiplier correctly
- ✅ Settings copyWith preserves font size multiplier
- ✅ Settings copyWith can update font size multiplier

## User Benefits

### For Users with Visual Impairments
- **Larger text**: Can increase text size beyond standard limits
- **Better readability**: Combined system + app scaling provides fine-grained control
- **Consistency**: Settings apply across entire app
- **Persistence**: Preferences saved and restored

### For All Users
- **Customization**: Can adjust text size to personal preference
- **Flexibility**: System settings + app settings work together
- **Preview**: See changes in real-time before applying

## Technical Details

### Code Files Modified
1. `lib/app.dart`: Added system font scaling support
2. `lib/features/settings/data/settings_model.dart`: Already had `fontSizeMultiplier` field
3. `lib/features/settings/presentation/providers/settings_provider.dart`: Already had `setFontSizeMultiplier` method
4. `lib/features/settings/presentation/screens/settings_screen.dart`: Already had font size UI

### Code Files Added
1. `test/accessibility/system_font_scaling_test.dart`: Comprehensive test suite
2. `test/mocks/mock_repositories.dart`: Mock repositories for testing
3. `docs/A11Y-005_IMPLEMENTATION.md`: This documentation

### Dependencies
- Flutter's `MediaQuery.textScalerOf(context)`: For reading system text scale
- Flutter's `TextScaler.linear()`: For applying combined scale factor
- Provider: For state management of font size multiplier

## Manual Testing Instructions

### iOS Testing
1. Go to **Settings → Accessibility → Display & Text Size**
2. Tap **Larger Text**
3. Drag the slider to increase text size
4. Toggle **Larger Accessibility Sizes** for maximum scaling
5. Open the app and verify text scales appropriately

### Android Testing
1. Go to **Settings → Accessibility → Font size**
2. Drag the slider to increase text size
3. Open the app and verify text scales appropriately

### App Settings Testing
1. Open the app
2. Navigate to Settings
3. Adjust the **Font Size** slider
4. Observe the preview text changing in real-time
5. Navigate through the app to verify all text scales

### Combined Testing
1. Set system font scale to large (e.g., 1.5x)
2. Set app multiplier to large (e.g., 1.3x)
3. Verify combined scaling works (should be ~1.95x)
4. Check that UI remains usable and touch targets are maintained

## Known Limitations

None. The implementation fully supports system font scaling with no known issues.

## Future Enhancements

Potential improvements (not required for A11Y-005):
- Add "Reset to Default" button for font size
- Add preset font size options (Small, Medium, Large, Extra Large)
- Show recommended settings for different vision conditions
- Add font weight customization for better readability

## References

- **NFR-016**: Accessibility - System Font Scaling requirement
- **WCAG 2.1**: Level AA Success Criterion 1.4.4 Resize Text
- **iOS HIG**: Typography - Dynamic Type
- **Android Material**: Accessibility - Typography
- **Flutter**: `MediaQuery.textScalerOf()` documentation

## Conclusion

The implementation of A11Y-005 provides comprehensive system font scaling support that:
- ✅ Respects device accessibility settings
- ✅ Provides additional app-level customization
- ✅ Exceeds WCAG 2.1 Level AA requirements
- ✅ Works seamlessly across iOS and Android
- ✅ Maintains usability at all scaling levels
- ✅ Is fully tested and documented

**Status**: ✅ **COMPLETE** and ready for production
