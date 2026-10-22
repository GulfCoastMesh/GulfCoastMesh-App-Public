package org.gulfcoastmesh

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.RemoteInput

/**
 * Receives what the driver dictated in the car, plus mark-as-read taps.
 *
 * Android Auto fires the notification's PendingIntent rather than opening the
 * app, so this runs with no Activity and possibly no Flutter engine. Events are
 * handed to [CarMessagingBridge], which forwards them to Dart when the engine
 * is alive and queues them when it is not.
 */
class CarReplyReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val conversationId = intent.getStringExtra(EXTRA_CONVERSATION_ID) ?: return

        when (intent.action) {
            ACTION_REPLY -> {
                val reply = RemoteInput.getResultsFromIntent(intent)
                    ?.getCharSequence(KEY_TEXT_REPLY)
                    ?.toString()
                    ?.trim()
                    .orEmpty()
                // An empty dictation is a misfire, not a message worth sending
                // over a constrained LoRa link.
                if (reply.isEmpty()) return
                CarMessagingBridge.onReply(context, conversationId, reply)
            }

            ACTION_MARK_AS_READ -> CarMessagingBridge.onMarkAsRead(context, conversationId)
        }
    }

    companion object {
        const val ACTION_REPLY = "org.gulfcoastmesh.CAR_REPLY"
        const val ACTION_MARK_AS_READ = "org.gulfcoastmesh.CAR_MARK_AS_READ"
        const val EXTRA_CONVERSATION_ID = "conversation_id"
        const val KEY_TEXT_REPLY = "key_text_reply"
    }
}
