//
//  MyselfWidget.swift
//  MyselfWidget
//
//  Main widget file for Myself 2.0 iOS home screen widgets
//  Supports small (2x2), medium (4x2), and large (4x4) widget sizes
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

/// Timeline entry for widget updates
struct MyselfWidgetEntry: TimelineEntry {
    let date: Date
    let affirmationText: String
    let affirmationId: String
    let themeMode: String
    let fontSizeMultiplier: Double
    let hasAffirmations: Bool
}

// MARK: - Timeline Provider

/// Timeline provider for widget updates
struct MyselfWidgetProvider: TimelineProvider {
    /// Placeholder entry shown while widget is loading
    func placeholder(in context: Context) -> MyselfWidgetEntry {
        MyselfWidgetEntry(
            date: Date(),
            affirmationText: "I am confident and capable",
            affirmationId: "",
            themeMode: "system",
            fontSizeMultiplier: 1.0,
            hasAffirmations: true
        )
    }

    /// Snapshot for widget gallery
    func getSnapshot(in context: Context, completion: @escaping (MyselfWidgetEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    /// Timeline for widget updates
    func getTimeline(in context: Context, completion: @escaping (Timeline<MyselfWidgetEntry>) -> Void) {
        // Access shared UserDefaults via App Group
        let userDefaults = UserDefaults(suiteName: "group.com.infyneis.myself_2_0")

        // Read shared data
        let affirmationText = userDefaults?.string(forKey: "affirmation_text") ?? ""
        let affirmationId = userDefaults?.string(forKey: "affirmation_id") ?? ""
        let themeMode = userDefaults?.string(forKey: "theme_mode") ?? "system"
        let fontSizeMultiplier = userDefaults?.double(forKey: "font_size_multiplier") ?? 1.0
        let hasAffirmations = userDefaults?.bool(forKey: "has_affirmations") ?? false

        // Create entry
        let entry = MyselfWidgetEntry(
            date: Date(),
            affirmationText: affirmationText.isEmpty ? "Create your first affirmation" : affirmationText,
            affirmationId: affirmationId,
            themeMode: themeMode,
            fontSizeMultiplier: fontSizeMultiplier,
            hasAffirmations: hasAffirmations
        )

        // Update timeline at the end (will be refreshed on app updates)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Views

/// Small widget view (2x2)
struct MyselfWidgetSmallView: View {
    let entry: MyselfWidgetEntry
    @Environment(\.colorScheme) var systemColorScheme

    var colorScheme: ColorScheme {
        switch entry.themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return systemColorScheme
        }
    }

    var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98)
    }

    var textColor: Color {
        colorScheme == .dark ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color(red: 0.13, green: 0.13, blue: 0.14)
    }

    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Content
            VStack(alignment: .center, spacing: 8) {
                if entry.hasAffirmations {
                    Text(entry.affirmationText)
                        .font(.system(size: 14 * entry.fontSizeMultiplier, weight: .medium, design: .rounded))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .minimumScaleFactor(0.8)
                } else {
                    // Empty state
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(textColor.opacity(0.6))
                        Text("Tap to create")
                            .font(.system(size: 11 * entry.fontSizeMultiplier, weight: .medium))
                            .foregroundColor(textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(12)
        }
        .preferredColorScheme(colorScheme)
    }
}

/// Medium widget view (4x2)
struct MyselfWidgetMediumView: View {
    let entry: MyselfWidgetEntry
    @Environment(\.colorScheme) var systemColorScheme

    var colorScheme: ColorScheme {
        switch entry.themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return systemColorScheme
        }
    }

    var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98)
    }

    var textColor: Color {
        colorScheme == .dark ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color(red: 0.13, green: 0.13, blue: 0.14)
    }

    var accentColor: Color {
        colorScheme == .dark ? Color(red: 0.56, green: 0.68, blue: 0.65) : Color(red: 0.46, green: 0.58, blue: 0.55)
    }

    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Content
            HStack(spacing: 16) {
                // Icon
                Image(systemName: entry.hasAffirmations ? "heart.circle.fill" : "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(accentColor)
                    .frame(width: 50)

                // Affirmation text
                VStack(alignment: .leading, spacing: 4) {
                    if entry.hasAffirmations {
                        Text(entry.affirmationText)
                            .font(.system(size: 16 * entry.fontSizeMultiplier, weight: .medium, design: .rounded))
                            .foregroundColor(textColor)
                            .lineLimit(4)
                            .minimumScaleFactor(0.85)
                    } else {
                        Text("Create Your First Affirmation")
                            .font(.system(size: 16 * entry.fontSizeMultiplier, weight: .semibold, design: .rounded))
                            .foregroundColor(textColor)

                        Text("Tap to get started")
                            .font(.system(size: 13 * entry.fontSizeMultiplier, weight: .regular))
                            .foregroundColor(textColor.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .preferredColorScheme(colorScheme)
    }
}

/// Large widget view (4x4)
struct MyselfWidgetLargeView: View {
    let entry: MyselfWidgetEntry
    @Environment(\.colorScheme) var systemColorScheme

    var colorScheme: ColorScheme {
        switch entry.themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return systemColorScheme
        }
    }

    var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color(red: 0.98, green: 0.98, blue: 0.98)
    }

    var textColor: Color {
        colorScheme == .dark ? Color(red: 0.95, green: 0.95, blue: 0.97) : Color(red: 0.13, green: 0.13, blue: 0.14)
    }

    var accentColor: Color {
        colorScheme == .dark ? Color(red: 0.56, green: 0.68, blue: 0.65) : Color(red: 0.46, green: 0.58, blue: 0.55)
    }

    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Content
            VStack(spacing: 20) {
                // Icon
                Image(systemName: entry.hasAffirmations ? "heart.circle.fill" : "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(accentColor)

                // Affirmation text
                if entry.hasAffirmations {
                    Text(entry.affirmationText)
                        .font(.system(size: 20 * entry.fontSizeMultiplier, weight: .medium, design: .rounded))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(8)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 12) {
                        Text("Create Your First Affirmation")
                            .font(.system(size: 20 * entry.fontSizeMultiplier, weight: .semibold, design: .rounded))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)

                        Text("Tap to open the app and start your journey of positive self-talk")
                            .font(.system(size: 14 * entry.fontSizeMultiplier, weight: .regular))
                            .foregroundColor(textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 20)
                    }
                }

                // Subtle branding
                Text("Myself 2.0")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(textColor.opacity(0.5))
            }
            .padding(24)
        }
        .preferredColorScheme(colorScheme)
    }
}

// MARK: - Widget Entry View

/// Main widget view that supports all sizes
struct MyselfWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: MyselfWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            MyselfWidgetSmallView(entry: entry)
        case .systemMedium:
            MyselfWidgetMediumView(entry: entry)
        case .systemLarge:
            MyselfWidgetLargeView(entry: entry)
        @unknown default:
            MyselfWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Widget Definition

/// Main widget definition
@main
struct MyselfWidget: Widget {
    let kind: String = "MyselfWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MyselfWidgetProvider()) { entry in
            MyselfWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Affirmation")
        .description("Display your daily affirmation on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

struct MyselfWidget_Previews: PreviewProvider {
    static var previews: some Group {
        // Small widget preview - with affirmation
        MyselfWidgetEntryView(entry: MyselfWidgetEntry(
            date: Date(),
            affirmationText: "I am confident and capable",
            affirmationId: "preview-1",
            themeMode: "light",
            fontSizeMultiplier: 1.0,
            hasAffirmations: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Small - Light")

        MyselfWidgetEntryView(entry: MyselfWidgetEntry(
            date: Date(),
            affirmationText: "I am confident and capable",
            affirmationId: "preview-1",
            themeMode: "dark",
            fontSizeMultiplier: 1.0,
            hasAffirmations: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Small - Dark")

        // Medium widget preview
        MyselfWidgetEntryView(entry: MyselfWidgetEntry(
            date: Date(),
            affirmationText: "I embrace challenges and grow from them",
            affirmationId: "preview-2",
            themeMode: "light",
            fontSizeMultiplier: 1.0,
            hasAffirmations: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .previewDisplayName("Medium - Light")

        // Large widget preview
        MyselfWidgetEntryView(entry: MyselfWidgetEntry(
            date: Date(),
            affirmationText: "I am worthy of love, success, and happiness. Every day I grow stronger and more confident.",
            affirmationId: "preview-3",
            themeMode: "light",
            fontSizeMultiplier: 1.0,
            hasAffirmations: true
        ))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
        .previewDisplayName("Large - Light")

        // Empty state previews
        MyselfWidgetEntryView(entry: MyselfWidgetEntry(
            date: Date(),
            affirmationText: "",
            affirmationId: "",
            themeMode: "light",
            fontSizeMultiplier: 1.0,
            hasAffirmations: false
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        .previewDisplayName("Medium - Empty State")
    }
}
