package com.infyneis.myself_2_0

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat

/**
 * MyselfAppWidgetProvider
 *
 * Android AppWidgetProvider for displaying affirmations on the home screen.
 * Supports small, medium, and large widget sizes with adaptive layouts.
 *
 * This provider implements:
 * - WIDGET-005: Android Widget Provider
 * - WIDGET-007: Widget Tap-to-Launch Functionality
 *
 * ## Features
 * - Small (2x2), medium (4x2), and large (4x4) widget sizes
 * - Reads affirmation data from SharedPreferences
 * - Handles empty state when no affirmations exist
 * - Tap action to launch main application (WIDGET-007)
 * - Adapts to system light/dark theme
 *
 * ## Tap-to-Launch Implementation (WIDGET-007)
 * Each widget registers a PendingIntent that launches MainActivity when tapped:
 * - Uses FLAG_ACTIVITY_NEW_TASK to start app in new task
 * - Uses FLAG_ACTIVITY_CLEAR_TOP to bring existing app to foreground
 * - PendingIntent attached to widget_container view ID in all layouts
 * - Works consistently across all widget sizes
 *
 * ## Data Sharing
 * Uses SharedPreferences with name "FlutterSharedPreferences" to read data
 * shared from the Flutter app via home_widget package.
 *
 * ## Refresh Strategy
 * - Updates when app writes new data via home_widget
 * - Updates on device unlock (requires BroadcastReceiver - see WIDGET-006)
 * - Updates when widget is added or resized
 */
class MyselfAppWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val SHARED_PREFS_NAME = "FlutterSharedPreferences"

        // Keys for SharedPreferences (must match Flutter side)
        private const val KEY_AFFIRMATION_TEXT = "flutter.affirmation_text"
        private const val KEY_AFFIRMATION_ID = "flutter.affirmation_id"
        private const val KEY_HAS_AFFIRMATIONS = "flutter.has_affirmations"
        private const val KEY_THEME_MODE = "flutter.theme_mode"
        private const val KEY_FONT_SIZE_MULTIPLIER = "flutter.font_size_multiplier"

        /**
         * Updates all widget instances
         *
         * This can be called from BroadcastReceivers to refresh widgets
         */
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, MyselfAppWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

            if (appWidgetIds.isNotEmpty()) {
                val provider = MyselfAppWidgetProvider()
                provider.onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    /**
     * Called when widget is updated
     */
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update each widget instance
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    /**
     * Called when widget is enabled (first instance added)
     */
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // Widget is added to home screen
        // Could initialize any global resources here
    }

    /**
     * Called when widget is disabled (last instance removed)
     */
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // Widget is removed from home screen
        // Clean up any resources here
    }

    /**
     * Updates a single widget instance
     */
    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // Read data from SharedPreferences
        val prefs = context.getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE)
        val affirmationText = prefs.getString(KEY_AFFIRMATION_TEXT, "") ?: ""
        val hasAffirmations = prefs.getBoolean(KEY_HAS_AFFIRMATIONS, false)
        val fontSizeMultiplier = prefs.getFloat(KEY_FONT_SIZE_MULTIPLIER, 1.0f)

        // Determine widget size
        val widgetSize = getWidgetSize(context, appWidgetManager, appWidgetId)

        // Get appropriate layout based on size
        val layoutId = when (widgetSize) {
            WidgetSize.SMALL -> R.layout.widget_small
            WidgetSize.MEDIUM -> R.layout.widget_medium
            WidgetSize.LARGE -> R.layout.widget_large
        }

        // Construct the RemoteViews object
        val views = RemoteViews(context.packageName, layoutId)

        // Update widget content based on whether affirmations exist
        if (hasAffirmations && affirmationText.isNotEmpty()) {
            updateWithAffirmation(views, affirmationText, widgetSize)
        } else {
            updateEmptyState(views, widgetSize)
        }

        // Set up click handler to open the app
        val intent = Intent(context, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    /**
     * Updates widget with affirmation content
     */
    private fun updateWithAffirmation(
        views: RemoteViews,
        affirmationText: String,
        widgetSize: WidgetSize
    ) {
        when (widgetSize) {
            WidgetSize.SMALL -> {
                views.setViewVisibility(R.id.affirmation_text, View.VISIBLE)
                views.setViewVisibility(R.id.empty_icon, View.GONE)
                views.setViewVisibility(R.id.empty_text, View.GONE)
                views.setTextViewText(R.id.affirmation_text, affirmationText)
            }
            WidgetSize.MEDIUM -> {
                views.setViewVisibility(R.id.affirmation_text, View.VISIBLE)
                views.setViewVisibility(R.id.empty_subtitle, View.GONE)
                views.setTextViewText(R.id.affirmation_text, affirmationText)
                // Set icon to heart for affirmation
                views.setImageViewResource(R.id.widget_icon, R.drawable.ic_heart)
            }
            WidgetSize.LARGE -> {
                views.setViewVisibility(R.id.affirmation_text, View.VISIBLE)
                views.setViewVisibility(R.id.empty_subtitle, View.GONE)
                views.setTextViewText(R.id.affirmation_text, affirmationText)
                // Set icon to heart for affirmation
                views.setImageViewResource(R.id.widget_icon, R.drawable.ic_heart)
            }
        }
    }

    /**
     * Updates widget with empty state
     */
    private fun updateEmptyState(views: RemoteViews, widgetSize: WidgetSize) {
        when (widgetSize) {
            WidgetSize.SMALL -> {
                views.setViewVisibility(R.id.affirmation_text, View.GONE)
                views.setViewVisibility(R.id.empty_icon, View.VISIBLE)
                views.setViewVisibility(R.id.empty_text, View.VISIBLE)
            }
            WidgetSize.MEDIUM -> {
                views.setViewVisibility(R.id.affirmation_text, View.VISIBLE)
                views.setViewVisibility(R.id.empty_subtitle, View.VISIBLE)
                views.setTextViewText(
                    R.id.affirmation_text,
                    "Create Your First Affirmation"
                )
                views.setTextViewText(
                    R.id.empty_subtitle,
                    "Tap to get started"
                )
                // Set icon to sparkles for empty state
                views.setImageViewResource(R.id.widget_icon, R.drawable.ic_sparkles)
            }
            WidgetSize.LARGE -> {
                views.setViewVisibility(R.id.affirmation_text, View.VISIBLE)
                views.setViewVisibility(R.id.empty_subtitle, View.VISIBLE)
                views.setTextViewText(
                    R.id.affirmation_text,
                    "Create Your First Affirmation"
                )
                views.setTextViewText(
                    R.id.empty_subtitle,
                    "Tap to open the app and start your journey of positive self-talk"
                )
                // Set icon to sparkles for empty state
                views.setImageViewResource(R.id.widget_icon, R.drawable.ic_sparkles)
            }
        }
    }

    /**
     * Determines the widget size based on dimensions
     */
    private fun getWidgetSize(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ): WidgetSize {
        // For API 31+, we can get exact dimensions
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            val sizes = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = sizes.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = sizes.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)

            return when {
                minWidth >= 250 && minHeight >= 250 -> WidgetSize.LARGE  // 4x4
                minWidth >= 250 -> WidgetSize.MEDIUM  // 4x2
                else -> WidgetSize.SMALL  // 2x2
            }
        }

        // For older Android versions, default to medium
        return WidgetSize.MEDIUM
    }

    /**
     * Widget size enumeration
     */
    private enum class WidgetSize {
        SMALL,   // 2x2
        MEDIUM,  // 4x2
        LARGE    // 4x4
    }
}
