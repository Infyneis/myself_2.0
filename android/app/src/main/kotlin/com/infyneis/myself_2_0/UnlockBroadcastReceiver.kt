package com.infyneis.myself_2_0

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * UnlockBroadcastReceiver
 *
 * BroadcastReceiver that listens for ACTION_USER_PRESENT to update widgets when
 * the user unlocks their phone.
 *
 * This receiver implements WIDGET-006: Android Unlock Broadcast Receiver
 * and respects WIDGET-011: Widget Rotation Toggle setting
 *
 * ## Functionality
 * - Listens for ACTION_USER_PRESENT broadcast (triggered when device is unlocked)
 * - Checks if widget rotation is enabled in settings (WIDGET-011)
 * - Triggers widget update to display a new random affirmation if enabled
 * - Ensures widgets stay fresh and engaging every time user unlocks their phone
 *
 * ## Security
 * - Only responds to system broadcasts (ACTION_USER_PRESENT)
 * - No sensitive data is processed or stored
 * - Widget updates are handled securely through standard Android APIs
 *
 * ## Performance
 * - Minimal processing: immediately delegates to widget provider
 * - Non-blocking: widget update happens asynchronously
 * - No battery impact: only runs on unlock events
 */
class UnlockBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "UnlockBroadcastReceiver"
    }

    /**
     * Called when the BroadcastReceiver receives an Intent broadcast.
     *
     * This method is invoked when the user unlocks their phone (ACTION_USER_PRESENT).
     * It checks if widget rotation is enabled (WIDGET-011) and triggers an update
     * of all Myself widget instances to display a fresh affirmation if enabled.
     *
     * @param context The Context in which the receiver is running
     * @param intent The Intent being received (should be ACTION_USER_PRESENT)
     */
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) {
            Log.w(TAG, "Received null context or intent")
            return
        }

        // Verify this is the unlock broadcast
        if (intent.action == Intent.ACTION_USER_PRESENT) {
            Log.d(TAG, "Device unlocked - checking widget rotation setting")

            try {
                // Check if widget rotation is enabled (WIDGET-011)
                val rotationEnabled = MyselfAppWidgetProvider.isWidgetRotationEnabled(context)

                if (rotationEnabled) {
                    Log.d(TAG, "Widget rotation enabled - updating widgets")
                    // Trigger widget update
                    MyselfAppWidgetProvider.updateAllWidgets(context)
                    Log.d(TAG, "Widget update triggered successfully")
                } else {
                    Log.d(TAG, "Widget rotation disabled - skipping update")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update widgets on unlock", e)
            }
        } else {
            Log.w(TAG, "Received unexpected intent action: ${intent.action}")
        }
    }
}
