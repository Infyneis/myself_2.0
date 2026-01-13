# REQUIREMENTS.md — Myself 2.0

## Product Requirements Document (PRD)

**Version:** 1.0  
**Date:** January 13, 2026  
**Platform:** Flutter (iOS & Android)

---

## 1. Executive Summary

**Myself 2.0** is a personal development mobile application that helps users visualize and internalize their ideal self. Users write affirmations describing who they want to become, and these phrases are displayed through a home screen widget, reinforcing positive identity changes each time they unlock their phone.

**Core Philosophy:** Transform through repetition and intention — see who you want to become, become who you see.

---

## 2. Problem Statement

Personal growth requires consistent reinforcement. Traditional methods like journaling or vision boards are static and easily forgotten. Users need a passive, frictionless way to keep their personal development goals top-of-mind throughout the day.

---

## 3. Target Audience

- Individuals focused on personal development and self-improvement
- People practicing mindfulness, meditation, or cognitive behavioral techniques
- Users seeking to break negative thought patterns or build new habits
- Ages 18-45, comfortable with smartphone technology

---

## 4. Product Vision

A zen-inspired application that seamlessly integrates personal affirmations into daily life, creating micro-moments of reflection and reinforcement without requiring active engagement.

---

## 5. Functional Requirements

### 5.1 Core Features

#### 5.1.1 Affirmation Management

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-001 | Users can create new affirmations with free-form text input | Must Have |
| FR-002 | Users can edit existing affirmations | Must Have |
| FR-003 | Users can delete affirmations | Must Have |
| FR-004 | Users can view all saved affirmations in a list | Must Have |
| FR-005 | Affirmations support multi-line text | Should Have |
| FR-006 | Character limit of 280 characters per affirmation | Must Have |
| FR-007 | Users can reorder affirmations via drag-and-drop | Could Have |

**Affirmation Format Examples:**
- "Le [Name] 2.0 ne se laisse plus submerger par ses émotions"
- "Je suis calme et maître de mes réactions"
- "Chaque jour, je deviens une meilleure version de moi-même"

#### 5.1.2 Home Screen Widget

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-008 | Widget displays one random affirmation from the user's list | Must Have |
| FR-009 | Affirmation changes each time the user unlocks their phone | Must Have |
| FR-010 | Widget supports multiple sizes: small (2x2), medium (4x2), large (4x4) | Must Have |
| FR-011 | Tapping the widget opens the main application | Must Have |
| FR-012 | Widget displays placeholder text when no affirmations exist | Must Have |
| FR-013 | Widget updates in real-time when affirmations are added/modified | Should Have |

**Widget Behavior:**
- iOS: WidgetKit with timeline refresh on device unlock
- Android: AppWidgetProvider with broadcast receiver for screen unlock events

#### 5.1.3 In-App Display

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-014 | Main screen shows a random affirmation with zen animation | Must Have |
| FR-015 | User can swipe or tap to see another random affirmation | Should Have |
| FR-016 | Manual refresh button to cycle affirmations | Should Have |

### 5.2 Data Management

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-017 | All data stored locally on device | Must Have |
| FR-018 | Data persists between app sessions | Must Have |
| FR-019 | Export affirmations to text file | Could Have |
| FR-020 | Import affirmations from text file | Could Have |
| FR-021 | Optional cloud backup (iCloud/Google Drive) | Won't Have (v1) |

### 5.3 Settings

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-022 | Toggle to enable/disable widget rotation | Should Have |
| FR-023 | Option to set refresh interval (every unlock, hourly, daily) | Could Have |
| FR-024 | Language selection (French, English) | Should Have |
| FR-025 | Dark/Light mode toggle | Must Have |
| FR-026 | Font size adjustment for accessibility | Should Have |

---

## 6. Non-Functional Requirements

### 6.1 Performance

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-001 | App cold start time | < 2 seconds |
| NFR-002 | Widget update latency | < 500ms |
| NFR-003 | Maximum memory footprint | < 50MB |
| NFR-004 | Offline functionality | 100% features available |

### 6.2 Compatibility

| ID | Requirement | Specification |
|----|-------------|---------------|
| NFR-005 | iOS minimum version | iOS 14.0+ |
| NFR-006 | Android minimum version | Android 8.0 (API 26)+ |
| NFR-007 | Flutter SDK version | 3.x stable |
| NFR-008 | Screen size support | 4" to 13" displays |

### 6.3 Security & Privacy

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-009 | No data collection or analytics in v1 | Must Have |
| NFR-010 | No internet permission required for core functionality | Must Have |
| NFR-011 | Local data encrypted using platform-native encryption | Should Have |
| NFR-012 | No third-party SDKs that collect user data | Must Have |

### 6.4 Accessibility

| ID | Requirement | Priority |
|----|-------------|----------|
| NFR-013 | Full VoiceOver (iOS) / TalkBack (Android) support | Must Have |
| NFR-014 | Minimum touch target size of 44x44 points | Must Have |
| NFR-015 | Color contrast ratio minimum 4.5:1 | Must Have |
| NFR-016 | Support for system font scaling | Should Have |

---

## 7. Design Requirements

### 7.1 Design Philosophy

The visual identity must evoke **calm, serenity, and mindfulness**. Every element should feel intentional and peaceful.

**Keywords:** Zen, minimalist, breathing space, natural, tranquil

### 7.2 Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Cloud White | `#FAFBFC` | Primary background (light mode) |
| Deep Night | `#1A1D21` | Primary background (dark mode) |
| Soft Sage | `#A8C5B5` | Primary accent |
| Mist Gray | `#E8EAED` | Secondary elements |
| Stone | `#6B7280` | Muted text |
| Zen Black | `#2D3436` | Primary text (light mode) |
| Soft White | `#F1F3F4` | Primary text (dark mode) |

### 7.3 Typography

| Element | Font | Weight | Size |
|---------|------|--------|------|
| Affirmation Display | Playfair Display / Noto Serif | Regular | 24-32sp |
| Body Text | Inter / System Default | Regular | 16sp |
| Headings | Inter | Semi-Bold | 20sp |
| Button Text | Inter | Medium | 14sp |

### 7.4 Visual Elements

**Animations:**
- Subtle fade-in for affirmation transitions (300-500ms)
- Gentle breathing animation on main screen (optional)
- Smooth page transitions with minimal bounce

**Imagery:**
- Abstract nature-inspired backgrounds (optional)
- Subtle gradient overlays
- No harsh shadows — use soft elevation

**Spacing:**
- Generous padding (minimum 24px margins)
- Ample breathing room between elements
- Card-based layout with rounded corners (16px radius)

### 7.5 Widget Design

```
┌─────────────────────────────────────┐
│                                     │
│    "Le Samy 2.0 ne se laisse       │
│     plus submerger par ses          │
│     émotions"                       │
│                                     │
│                        — Myself 2.0 │
└─────────────────────────────────────┘
```

**Widget Specifications:**
- Translucent background with blur effect
- Centered text with comfortable padding
- Discrete app branding in corner
- Adapts to system light/dark mode

---

## 8. User Flows

### 8.1 First Launch Flow

```
App Launch
    │
    ▼
Welcome Screen (Illustration + Brief explanation)
    │
    ▼
"Create Your First Affirmation" Prompt
    │
    ▼
Affirmation Input Screen
    │
    ▼
Success Animation + Widget Setup Instructions
    │
    ▼
Main Screen (Affirmation Display)
```

### 8.2 Daily Usage Flow

```
User Unlocks Phone
    │
    ▼
Widget Displays Random Affirmation
    │
    ▼
(Optional) User Taps Widget
    │
    ▼
App Opens to Full Affirmation View
    │
    ▼
User Reads, Reflects, Closes App
```

### 8.3 Affirmation Management Flow

```
Main Screen
    │
    ├──► "+" Button → Create New Affirmation
    │         │
    │         ▼
    │    Text Input → Save → Return to List
    │
    └──► Affirmation List → Select Item
              │
              ├──► Edit → Modify → Save
              │
              └──► Delete → Confirm → Remove
```

---

## 9. Technical Architecture

### 9.1 Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── dimensions.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   └── utils/
│       └── random_selector.dart
├── features/
│   ├── affirmations/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── affirmation.dart
│   │   │   └── repositories/
│   │   │       └── affirmation_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── affirmation_list_screen.dart
│   │   │   │   └── affirmation_edit_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── affirmation_card.dart
│   │   │   │   └── affirmation_input.dart
│   │   │   └── providers/
│   │   │       └── affirmation_provider.dart
│   │   └── domain/
│   │       └── usecases/
│   │           └── get_random_affirmation.dart
│   ├── settings/
│   │   └── ...
│   └── onboarding/
│       └── ...
└── widgets/
    └── native_widget/
        ├── android/
        └── ios/
```

### 9.2 Data Model

```dart
class Affirmation {
  final String id;           // UUID
  final String text;         // Max 280 chars
  final DateTime createdAt;
  final DateTime updatedAt;
  final int displayCount;    // Analytics (future)
  final bool isActive;       // Enable/disable individual affirmations
}
```

### 9.3 Local Storage

**Primary:** `shared_preferences` or `hive` for lightweight key-value storage

**Schema:**
```json
{
  "affirmations": [
    {
      "id": "uuid-1",
      "text": "Le Samy 2.0 ne se laisse plus submerger par ses émotions",
      "createdAt": "2026-01-13T10:00:00Z",
      "updatedAt": "2026-01-13T10:00:00Z",
      "displayCount": 15,
      "isActive": true
    }
  ],
  "settings": {
    "theme": "system",
    "refreshMode": "on_unlock",
    "language": "fr"
  },
  "lastDisplayedId": "uuid-1"
}
```

### 9.4 Widget Implementation

**iOS (WidgetKit):**
- Swift/SwiftUI widget extension
- SharedDefaults (App Group) for data sharing
- TimelineProvider for refresh scheduling

**Android (AppWidgetProvider):**
- Kotlin widget implementation
- SharedPreferences for data sharing
- BroadcastReceiver for `ACTION_USER_PRESENT`

**Flutter Bridge:**
- `home_widget` package for cross-platform widget management
- Method channel for native communication

### 9.5 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.x
  # OR
  flutter_riverpod: ^2.x
  
  # Local Storage
  hive: ^2.x
  hive_flutter: ^1.x
  
  # Widget Support
  home_widget: ^0.x
  
  # Utilities
  uuid: ^4.x
  intl: ^0.x  # Localization
  
  # UI
  google_fonts: ^6.x
  flutter_animate: ^4.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.x
  build_runner: ^2.x
  flutter_lints: ^3.x
```

---

## 10. Localization

### 10.1 Supported Languages (v1)

- French (fr) — Primary
- English (en) — Secondary

### 10.2 Key Strings

| Key | French | English |
|-----|--------|---------|
| app_name | Myself 2.0 | Myself 2.0 |
| create_affirmation | Créer une affirmation | Create an affirmation |
| edit_affirmation | Modifier | Edit |
| delete_affirmation | Supprimer | Delete |
| no_affirmations | Aucune affirmation. Commencez par en créer une ! | No affirmations yet. Start by creating one! |
| widget_placeholder | Ajoutez votre première affirmation | Add your first affirmation |
| settings | Paramètres | Settings |
| theme_light | Clair | Light |
| theme_dark | Sombre | Dark |
| theme_system | Système | System |

---

## 11. Testing Requirements

### 11.1 Unit Tests

- Affirmation CRUD operations
- Random selection algorithm
- Data persistence

### 11.2 Widget Tests

- UI component rendering
- User interaction flows
- Theme switching

### 11.3 Integration Tests

- Full user flows (onboarding, create, edit, delete)
- Widget ↔ App data synchronization
- Platform-specific widget functionality

### 11.4 Manual Testing Checklist

- [ ] Fresh install experience
- [ ] Affirmation creation (normal text)
- [ ] Affirmation with special characters (é, è, ç, etc.)
- [ ] Affirmation at max character limit
- [ ] Widget display on home screen
- [ ] Widget update on phone unlock
- [ ] Dark mode / Light mode transitions
- [ ] App backgrounding and foregrounding
- [ ] Data persistence after app kill
- [ ] Accessibility with VoiceOver/TalkBack

---

## 12. Release Criteria

### 12.1 MVP (v1.0)

**Must Have:**
- [ ] Create, read, update, delete affirmations
- [ ] Home screen widget (iOS & Android)
- [ ] Widget updates on unlock
- [ ] Light/Dark mode support
- [ ] French language support
- [ ] Zen-inspired design implementation
- [ ] Local data persistence

**Should Have:**
- [ ] English language support
- [ ] Onboarding flow
- [ ] Accessibility compliance

### 12.2 Future Versions (v1.x+)

- Cloud backup/sync
- Daily notifications with affirmations
- Affirmation categories/tags
- Usage statistics (most viewed affirmations)
- Widget customization (colors, fonts)
- Apple Watch / Wear OS widgets
- Share affirmations feature

---

## 13. Success Metrics

| Metric | Target (90 days post-launch) |
|--------|------------------------------|
| App Store Rating | ≥ 4.5 stars |
| Daily Active Users | Track baseline |
| Widget Active Rate | ≥ 70% of users |
| Avg. Affirmations per User | ≥ 5 |
| Crash-free Sessions | ≥ 99.5% |

---

## 14. Appendix

### A. Competitor Analysis

| App | Strengths | Weaknesses |
|-----|-----------|------------|
| I Am | Large affirmation library | No custom creation |
| ThinkUp | Voice recording | Complex UI |
| Motivation | Daily notifications | Ads-heavy |

**Myself 2.0 Differentiator:** Widget-first, fully customizable, zero distractions, privacy-focused.

### B. Technical References

- [Flutter Home Widget Package](https://pub.dev/packages/home_widget)
- [iOS WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Android App Widgets](https://developer.android.com/develop/ui/views/appwidgets)

### C. Design Inspiration

- Headspace app (calm, breathing animations)
- Notion (clean typography, whitespace)
- Apple Health (soft colors, card-based layout)

---

**Document Owner:** Infyneis  
**Last Updated:** January 13, 2026  
**Status:** Draft — Ready for Review
