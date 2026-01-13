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
 *
 * ## Functionality
 * - Listens for ACTION_USER_PRESENT broadcast (triggered when device is unlocked)
 * - Triggers widget update to display a new random affirmation
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
     * It triggers an update of all Myself widget instances to display a fresh affirmation.
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
            Log.d(TAG, "Device unlocked - updating widgets")

            try {
                // Trigger widget update
                MyselfAppWidgetProvider.updateAllWidgets(context)
                Log.d(TAG, "Widget update triggered successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update widgets on unlock", e)
            }
        } else {
            Log.w(TAG, "Received unexpected intent action: ${intent.action}")
        }
    }
}
