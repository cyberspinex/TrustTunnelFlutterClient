package com.adguard.trusttunnel.vpn_plugin

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel

class VpnPlugin : FlutterPlugin, ActivityAware, IVpnManager {
    @Volatile private var activity: Activity? = null
    private lateinit var vpn: NativeVpnImpl
    private val subscriptions = mutableMapOf<EventChannel, EventChannel.StreamHandler>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        vpn = NativeVpnImpl.get(binding.applicationContext)
        val messenger = binding.binaryMessenger
        IVpnManager.setUp(messenger, this)
        IDeepLink.setUp(messenger, DeepLinkImpl())

        fun register(name: String, handler: EventChannel.StreamHandler) {
            val channel = EventChannel(messenger, name)
            channel.setStreamHandler(handler)
            subscriptions[channel] = handler
        }
        register("vpn_plugin_event_channel", vpn.states.handler())
        register("trusttunnel/tile_session", vpn.tileSessions.handler())
        register("vpn_plugin_event_channel_query_log", object : EventChannel.StreamHandler {
            private var listening = false
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                listening = true
                vpn.queryLogHandler.onListen(arguments, events)
            }
            override fun onCancel(arguments: Any?) {
                if (listening) vpn.queryLogHandler.onCancel(arguments)
                listening = false
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        subscriptions.forEach { (channel, handler) ->
            handler.onCancel(null)
            channel.setStreamHandler(null)
        }
        subscriptions.clear()
        IVpnManager.setUp(binding.binaryMessenger, null)
        IDeepLink.setUp(binding.binaryMessenger, null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onDetachedFromActivity() { activity = null }

    override fun start(config: String, fallIntoRecovery: Boolean) = vpn.startFromApp(config, fallIntoRecovery, activity)
    override fun stop() = vpn.stop()
    override fun updateConfiguration(config: String?) = Unit
    override fun getCurrentState(): VpnManagerState = vpn.getCurrentState()
    override fun exportLogs(): List<String> = vpn.exportLogs()
    override fun clearLogs() = vpn.clearLogs()
}
