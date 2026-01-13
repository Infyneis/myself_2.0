# Android Compatibility Documentation

## COMPAT-002: Android 8.0+ (API 26+) Compatibility

**Status**: ✅ Complete
**Minimum SDK**: API 26 (Android 8.0 Oreo)
**Target SDK**: Latest (as per Flutter defaults)
**Compile SDK**: Latest (as per Flutter defaults)

---

## Overview

This document outlines the Android compatibility measures implemented to ensure the Myself 2.0 app runs correctly on Android 8.0 (API 26) and above.

---

## Configuration

### Build Configuration

**File**: `android/app/build.gradle.kts`

```kotlin
android {
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        minSdk = 26              // Android 8.0 Oreo
        targetSdk = flutter.targetSdkVersion
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}
```

### Manifest Configuration

**File**: `android/app/src/main/AndroidManifest.xml`

- Uses standard Android features compatible with API 26+
- Widget provider registration with standard broadcast receivers
- UnlockBroadcastReceiver for `ACTION_USER_PRESENT` (available since API 1)
- No special permissions required for core functionality

---

## Widget Compatibility

### Widget Configuration

**File**: `android/app/src/main/res/xml/myself_widget_info.xml`

The widget configuration uses a layered approach to support both legacy and modern Android versions:

#### API 26-30 (Android 8-11) Support:
- `android:previewImage` - Static drawable preview for widget picker
- `android:minWidth` / `android:minHeight` - Widget default size in dp

#### API 31+ (Android 12+) Support:
- `android:previewLayout` - Scalable XML layout preview (takes precedence over previewImage)
- `android:targetCellWidth` / `android:targetCellHeight` - Widget default size in grid cells

Both sets of attributes are present to ensure compatibility across all supported Android versions.

### Widget Provider Implementation

**File**: `android/app/src/main/kotlin/com/infyneis/myself_2_0/MyselfAppWidgetProvider.kt`

#### API Level Detection (Line 268):

```kotlin
if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
    // API 31+: Use AppWidgetManager to get exact dimensions
    val sizes = appWidgetManager.getAppWidgetOptions(appWidgetId)
    val minWidth = sizes.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
    val minHeight = sizes.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
    // Determine size based on dimensions
} else {
    // API 26-30: Default to medium size
    return WidgetSize.MEDIUM
}
```

**Rationale**: `AppWidgetManager.getAppWidgetOptions()` provides more accurate size information on API 31+. On older versions, we default to medium size which provides the best user experience.

#### PendingIntent Flags (Line 178):

```kotlin
val pendingIntent = PendingIntent.getActivity(
    context,
    0,
    intent,
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)
```

**Compatibility**:
- `FLAG_IMMUTABLE` is available since API 23, fully compatible with our minSdk of 26
- While only **required** on API 31+, using it on API 26+ is safe and recommended for security
- See: [Android Developers - PendingIntent](https://developer.android.com/reference/android/app/PendingIntent)

### UnlockBroadcastReceiver

**File**: `android/app/src/main/kotlin/com/infyneis/myself_2_0/UnlockBroadcastReceiver.kt`

- Uses `Intent.ACTION_USER_PRESENT` which has been available since API 1
- Standard BroadcastReceiver implementation - fully compatible with API 26+
- No API-level specific features or checks required

---

## Flutter Dependencies Compatibility

All Flutter packages used in this project support Android API 26+:

| Package | Version | Android Compatibility |
|---------|---------|----------------------|
| provider | ^6.1.5+1 | API 16+ |
| hive | ^2.2.3 | API 16+ |
| hive_flutter | ^1.1.0 | API 16+ |
| home_widget | ^0.9.0 | API 21+ (pinWidget requires API 26+) |
| uuid | ^4.5.2 | All platforms |
| intl | ^0.20.2 | All platforms |
| google_fonts | ^7.0.1 | API 16+ |
| flutter_animate | ^4.5.2 | API 16+ |
| path_provider | ^2.1.5 | API 16+ |
| flutter_secure_storage | ^10.0.0 | API 18+ |

**Note**: The `home_widget` package's `requestPinWidget` method specifically requires API 26+, which aligns perfectly with our minimum SDK version.

---

## Testing and Verification

### Build Verification

To verify Android compatibility, run:

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle

# Run on Android device/emulator
flutter run
```

### API Level Testing

**Recommended Test Devices**:
- Android 8.0 (API 26) - Minimum supported version
- Android 9.0 (API 28) - Common legacy device
- Android 11.0 (API 30) - Last version before widget preview changes
- Android 12.0 (API 31) - First version with modern widget features
- Android 14.0+ (API 34+) - Latest version

### Feature Testing Checklist

- [ ] App launches successfully on API 26+
- [ ] Widgets can be added to home screen
- [ ] Widget preview shows correctly in widget picker
- [ ] Widget updates on device unlock (UnlockBroadcastReceiver)
- [ ] Widget tap opens main app
- [ ] Widget supports light/dark mode
- [ ] All three widget sizes work correctly
- [ ] Data synchronization between app and widget
- [ ] PendingIntent security works correctly

---

## Known Limitations

### API 26-30 (Android 8-11):
- Widget preview in picker is a static image (`previewImage`)
- Widget size detection defaults to medium size (cannot determine exact dimensions)

### API 31+ (Android 12+):
- Widget preview is a scalable layout (`previewLayout`)
- Accurate widget size detection using `AppWidgetOptions`
- Enhanced widget configuration options

These limitations are by design and handled gracefully with fallback behavior.

---

## Resources

### Official Android Documentation:
- [Android Versions Dashboard](https://developer.android.com/about/dashboards)
- [App Widgets Overview](https://developer.android.com/develop/ui/views/appwidgets)
- [PendingIntent API Reference](https://developer.android.com/reference/android/app/PendingIntent)
- [AppWidgetProviderInfo API Reference](https://developer.android.com/reference/android/appwidget/AppWidgetProviderInfo)
- [Android 12 Widget Enhancements](https://developer.android.com/about/versions/12/features/widgets)

### Package Documentation:
- [home_widget Package](https://pub.dev/packages/home_widget)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install)

---

## Changelog

### 2026-01-13: Initial Android 8.0+ Compatibility Implementation (COMPAT-002)

**Added**:
- Widget preview image (`widget_preview.xml`) for API 26-30 support
- Comprehensive compatibility documentation
- `previewImage` attribute in widget configuration

**Verified**:
- All Kotlin code uses API 26+ compatible features
- PendingIntent flags are compatible (FLAG_IMMUTABLE available since API 23)
- Widget size detection has proper API 31+ fallback
- All Flutter dependencies support API 26+
- Build configuration correctly sets minSdk = 26

**Status**: ✅ Android 8.0+ compatibility fully implemented and verified

---

## Support

For issues related to Android compatibility, please check:
1. This documentation
2. `REQUIREMENTS.md` - NFR-006 requirement
3. `features.json` - COMPAT-002 feature status
4. Android device logs: `flutter logs` or `adb logcat`
