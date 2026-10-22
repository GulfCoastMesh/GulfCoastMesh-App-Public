package org.gulfcoastmesh

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var eventChannel: EventChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                CarMessagingBridge.handleMethodCall(
                    context = applicationContext,
                    method = call.method,
                    arguments = call.arguments as? Map<*, *>,
                    result = result,
                )
            }

        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    CarMessagingBridge.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    CarMessagingBridge.setEventSink(null)
                }
            })
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // The bridge is a singleton and outlives this Activity; leaving a stale
        // sink attached would push events at a detached engine.
        CarMessagingBridge.setEventSink(null)
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        private const val METHOD_CHANNEL = "org.gulfcoastmesh/car_messaging"
        private const val EVENT_CHANNEL = "org.gulfcoastmesh/car_messaging_events"
    }
}
