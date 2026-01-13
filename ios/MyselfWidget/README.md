# MyselfWidget - iOS WidgetKit Extension

This directory contains the iOS WidgetKit extension for displaying affirmations on the iOS home screen.

## Feature Implementation

**Feature ID:** WIDGET-003
**Description:** Create iOS WidgetKit extension with SwiftUI for small (2x2), medium (4x2), and large (4x4) widget sizes

## Files Included

- `MyselfWidget.swift` - Main widget implementation with TimelineProvider, Entry, and Views for all sizes
- `Info.plist` - Widget extension configuration
- `MyselfWidget.entitlements` - App Group entitlements for data sharing
- `Assets.xcassets/` - Widget assets and color sets

## Widget Sizes Supported

1. **Small (2x2)** - Displays affirmation text with minimal UI, perfect for quick glances
2. **Medium (4x2)** - Shows affirmation with an icon and more breathing room
3. **Large (4x4)** - Full affirmation display with icon, text, and branding

## Features

- ✅ Three widget sizes (small, medium, large)
- ✅ Reads data from App Group shared storage
- ✅ Supports light/dark/system theme modes
- ✅ Font size accessibility support
- ✅ Empty state handling (when no affirmations exist)
- ✅ Zen-inspired design with subtle gradients
- ✅ SwiftUI-based implementation
- ✅ Timeline updates via home_widget package

## Manual Xcode Setup Required

Since the widget extension needs to be added to the Xcode project, follow these steps:

### 1. Add Widget Extension Target in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **File → New → Target**
3. Select **Widget Extension**
4. Configure:
   - Product Name: `MyselfWidget`
   - Team: Your development team
   - Organization Identifier: `com.infyneis`
   - Language: Swift
   - Include Configuration Intent: **NO** (unchecked)
5. Click **Finish**
6. When prompted "Activate 'MyselfWidget' scheme?", click **Activate**

### 2. Replace Generated Files

Xcode will generate a basic widget. Replace the generated files with our custom implementation:

1. Delete the generated `MyselfWidget.swift` file
2. In Xcode, right-click on the `MyselfWidget` folder and select **Add Files to "Runner"...**
3. Navigate to `ios/MyselfWidget/` and add:
   - `MyselfWidget.swift`
   - `Info.plist`
   - `MyselfWidget.entitlements`
   - `Assets.xcassets` folder
4. Ensure "Copy items if needed" is **unchecked**
5. Ensure target membership is set to **MyselfWidget** only

### 3. Configure App Groups

**For MyselfWidget Target:**
1. Select the **MyselfWidget** target in project settings
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** under App Groups
6. Enter: `group.com.infyneis.myself_2_0`
7. Enable the checkbox next to it

**For Runner Target:**
1. Select the **Runner** target in project settings
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** under App Groups
6. Enter: `group.com.infyneis.myself_2_0`
7. Enable the checkbox next to it

### 4. Configure Widget Target Settings

1. Select **MyselfWidget** target
2. Go to **Build Settings**
3. Set **iOS Deployment Target** to `14.0`
4. Go to **General** tab
5. Set **Bundle Identifier** to `com.infyneis.myself-2-0.MyselfWidget`
6. Ensure **Supported Destinations** includes iPhone

### 5. Add Entitlements Files

1. Select **MyselfWidget** target
2. Go to **Build Settings**
3. Search for "Code Signing Entitlements"
4. Set value to: `MyselfWidget/MyselfWidget.entitlements`

For **Runner** target:
1. Select **Runner** target
2. Go to **Build Settings**
3. Search for "Code Signing Entitlements"
4. Set value to: `Runner/Runner.entitlements`

### 6. Build and Test

1. Select **Runner** scheme
2. Build the project (⌘B)
3. Run on a simulator or device
4. Add the widget to the home screen:
   - Long-press on home screen
   - Tap **+** button
   - Search for "Myself"
   - Select widget size and add

## Alternative: Automatic Setup via Ruby Script

If you prefer, you can use `xcodeproj` gem to automate the setup:

```bash
cd ios
gem install xcodeproj
ruby setup_widget.rb
```

(Note: setup_widget.rb script would need to be created for this to work)

## Data Sharing

The widget reads data from the App Group shared UserDefaults:

### Keys Used:
- `affirmation_text` - Current affirmation text
- `affirmation_id` - Current affirmation ID
- `theme_mode` - Theme setting (light/dark/system)
- `font_size_multiplier` - Font size for accessibility
- `has_affirmations` - Whether any affirmations exist

### App Group ID:
`group.com.infyneis.myself_2_0`

## Widget Update Mechanism

The widget timeline is updated:
1. When the Flutter app calls `HomeWidget.updateWidget()`
2. Via the WidgetService in the Flutter app
3. Policy is set to `.atEnd` - widget stays current until next update

## Troubleshooting

### Widget not showing data
- Verify App Group is configured correctly for both targets
- Check that the App Group ID matches: `group.com.infyneis.myself_2_0`
- Ensure entitlements files are set correctly in build settings
- Check Xcode console for errors

### Build errors
- Ensure iOS Deployment Target is 14.0 or higher
- Verify Swift language version is set (should be automatic)
- Clean build folder (⌘⇧K) and rebuild

### Widget not updating
- Ensure `HomeWidget.updateWidget()` is being called from Flutter
- Check that widget extension is included in the build
- Verify the widget is added to the home screen

## Testing

Use the preview provider in Xcode:
1. Open `MyselfWidget.swift`
2. Click **Resume** in the preview pane (or ⌥⌘↩)
3. View different widget sizes and states

## Design Details

### Colors
- **Light mode background:** RGB(0.98, 0.98, 0.98)
- **Dark mode background:** RGB(0.11, 0.11, 0.12)
- **Light mode text:** RGB(0.13, 0.13, 0.14)
- **Dark mode text:** RGB(0.95, 0.95, 0.97)
- **Accent color (light):** RGB(0.46, 0.58, 0.55) - Soft Sage
- **Accent color (dark):** RGB(0.56, 0.68, 0.65) - Lighter Sage

### Typography
- Small widget: 14pt (base size)
- Medium widget: 16pt (base size)
- Large widget: 20pt (base size)
- All sizes support font size multiplier for accessibility

### Spacing
- Small: 12pt padding
- Medium: 16pt padding
- Large: 24pt padding

## Future Enhancements

See related features:
- **WIDGET-004:** Timeline Provider with unlock event refresh
- **WIDGET-007:** Tap to open app functionality
- **WIDGET-008:** Enhanced placeholder states
- **WIDGET-010:** Advanced theme support

## License

Part of the Myself 2.0 project.
Copyright © 2026 Infyneis
