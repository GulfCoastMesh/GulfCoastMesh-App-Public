package org.gulfcoastmesh

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Publishes mesh conversations as MessagingStyle notifications and routes what
 * the car sends back to Dart.
 *
 * Why native rather than flutter_local_notifications: Android Auto only
 * recognises a reply action carrying SEMANTIC_ACTION_REPLY (and mark-as-read
 * carrying SEMANTIC_ACTION_MARK_AS_READ), and that plugin does not expose
 * `setSemanticAction`. Everything else here — MessagingStyle, Person, RemoteInput —
 * is what makes Auto read a message aloud and offer voice dictation.
 */
object CarMessagingBridge {

    private const val CHANNEL_ID = "car_messages"
    private const val CHANNEL_NAME = "Mesh messages in the car"

    private var eventSink: EventChannel.EventSink? = null

    /**
     * Events that arrived while no Flutter engine was listening. Android Auto
     * fires the reply PendingIntent without opening the app, so a dictated
     * reply can land before Dart has attached; dropping it would silently lose
     * the driver's message.
     *
     * This only bridges a gap *within* a live process. If the app was fully
     * killed there is no mesh connection either, so the reply could not be sent
     * regardless — replies are only meaningful while the session (and its
     * foreground service) is alive.
     */
    private val pendingEvents = mutableListOf<Map<String, Any?>>()

    /** Per-conversation message history, so a thread reads as a conversation. */
    private val conversations = mutableMapOf<String, MutableList<HistoryEntry>>()

    private data class HistoryEntry(
        val sender: String,
        val text: String,
        val timestamp: Long,
        val fromSelf: Boolean,
    )

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
        if (sink != null && pendingEvents.isNotEmpty()) {
            pendingEvents.forEach { sink.success(it) }
            pendingEvents.clear()
        }
    }

    fun handleMethodCall(
        context: Context,
        method: String,
        arguments: Map<*, *>?,
        result: MethodChannel.Result,
    ) {
        when (method) {
            "isCarConnected" -> result.success(false)

            "showMessage" -> {
                val conversationId = arguments?.get("conversationId") as? String
                val sender = arguments?.get("sender") as? String
                val text = arguments?.get("text") as? String
                if (conversationId == null || sender == null || text == null) {
                    result.error("bad_args", "conversationId, sender and text are required", null)
                    return
                }
                showMessage(
                    context = context,
                    conversationId = conversationId,
                    conversationTitle = arguments["conversationTitle"] as? String,
                    sender = sender,
                    text = text,
                    isGroup = arguments["isGroup"] as? Boolean ?: false,
                )
                result.success(null)
            }

            "appendOutgoing" -> {
                val conversationId = arguments?.get("conversationId") as? String
                val text = arguments?.get("text") as? String
                if (conversationId != null && text != null) {
                    conversations.getOrPut(conversationId) { mutableListOf() }
                        .add(HistoryEntry("", text, System.currentTimeMillis(), true))
                }
                result.success(null)
            }

            "clearConversation" -> {
                val conversationId = arguments?.get("conversationId") as? String
                if (conversationId != null) clearConversation(context, conversationId)
                result.success(null)
            }

            "showSendFailure" -> {
                val conversationId = arguments?.get("conversationId") as? String
                val reason = arguments?.get("reason") as? String
                if (conversationId != null && reason != null) {
                    // Surface the failure inside the same thread so the driver
                    // hears it read back instead of assuming the reply went out.
                    showMessage(
                        context = context,
                        conversationId = conversationId,
                        conversationTitle = arguments["conversationTitle"] as? String,
                        sender = "Gulf Coast Mesh App",
                        text = reason,
                        isGroup = false,
                    )
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Mesh messages announced and answered through Android Auto"
            }
        )
    }

    private fun showMessage(
        context: Context,
        conversationId: String,
        conversationTitle: String?,
        sender: String,
        text: String,
        isGroup: Boolean,
    ) {
        ensureChannel(context)

        val history = conversations.getOrPut(conversationId) { mutableListOf() }
        history.add(HistoryEntry(sender, text, System.currentTimeMillis(), false))
        // Auto only reads the recent thread; an unbounded list would grow for
        // the life of the process for no benefit.
        while (history.size > MAX_HISTORY) history.removeAt(0)

        val self = Person.Builder().setName("You").build()
        val style = NotificationCompat.MessagingStyle(self)
        if (isGroup) {
            // Explicit calls rather than Kotlin synthetic properties: these are
            // chaining setters returning MessagingStyle, and Kotlin only
            // synthesizes a property when the setter returns void.
            style.setGroupConversation(true)
            if (conversationTitle != null) {
                style.setConversationTitle(conversationTitle)
            }
        }
        history.forEach { entry ->
            // Typed explicitly so a null sender picks the Person overload
            // rather than being ambiguous with the CharSequence one.
            val person: Person? = if (entry.fromSelf) {
                null
            } else {
                Person.Builder().setName(entry.sender).build()
            }
            style.addMessage(entry.text, entry.timestamp, person)
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setStyle(style)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setShowWhen(true)
            .addAction(buildReplyAction(context, conversationId))
            .addAction(buildMarkAsReadAction(context, conversationId))
            .build()

        try {
            NotificationManagerCompat.from(context)
                .notify(conversationId.hashCode(), notification)
        } catch (e: SecurityException) {
            // POST_NOTIFICATIONS not granted. Dart already surfaces that state
            // in-app; nothing useful to do from here.
        }
    }

    private fun buildReplyAction(
        context: Context,
        conversationId: String,
    ): NotificationCompat.Action {
        val remoteInput = RemoteInput.Builder(CarReplyReceiver.KEY_TEXT_REPLY)
            .setLabel("Reply")
            .build()

        return NotificationCompat.Action.Builder(
            android.R.drawable.ic_menu_send,
            "Reply",
            pendingIntent(context, conversationId, CarReplyReceiver.ACTION_REPLY),
        )
            .addRemoteInput(remoteInput)
            // Both are required for Android Auto to treat this as a voice reply:
            // the semantic action tells it what the button means, and
            // showsUserInterface(false) promises it will not open a screen.
            .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_REPLY)
            .setShowsUserInterface(false)
            .setAllowGeneratedReplies(true)
            .build()
    }

    private fun buildMarkAsReadAction(
        context: Context,
        conversationId: String,
    ): NotificationCompat.Action {
        return NotificationCompat.Action.Builder(
            android.R.drawable.ic_menu_view,
            "Mark as read",
            pendingIntent(context, conversationId, CarReplyReceiver.ACTION_MARK_AS_READ),
        )
            .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_MARK_AS_READ)
            .setShowsUserInterface(false)
            .build()
    }

    private fun pendingIntent(
        context: Context,
        conversationId: String,
        action: String,
    ): PendingIntent {
        val intent = Intent(context, CarReplyReceiver::class.java).apply {
            this.action = action
            putExtra(CarReplyReceiver.EXTRA_CONVERSATION_ID, conversationId)
        }
        return PendingIntent.getBroadcast(
            context,
            // Distinct per conversation *and* per action, or the two actions
            // would share one PendingIntent and the extras of whichever was
            // created first.
            (conversationId + action).hashCode(),
            intent,
            // MUTABLE is required: RemoteInput fills the dictated text in.
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )
    }

    fun onReply(context: Context, conversationId: String, text: String) {
        // Echo the driver's own words into the thread so the next read-aloud
        // has the full conversation.
        conversations.getOrPut(conversationId) { mutableListOf() }
            .add(HistoryEntry("", text, System.currentTimeMillis(), true))
        emit(
            mapOf(
                "type" to "reply",
                "conversationId" to conversationId,
                "text" to text,
            )
        )
    }

    fun onMarkAsRead(context: Context, conversationId: String) {
        clearConversation(context, conversationId)
        emit(mapOf("type" to "markAsRead", "conversationId" to conversationId))
    }

    private fun clearConversation(context: Context, conversationId: String) {
        conversations.remove(conversationId)
        NotificationManagerCompat.from(context).cancel(conversationId.hashCode())
    }

    private fun emit(event: Map<String, Any?>) {
        val sink = eventSink
        if (sink == null) {
            pendingEvents.add(event)
            while (pendingEvents.size > MAX_PENDING_EVENTS) pendingEvents.removeAt(0)
            return
        }
        sink.success(event)
    }

    private const val MAX_HISTORY = 15
    private const val MAX_PENDING_EVENTS = 20
}
