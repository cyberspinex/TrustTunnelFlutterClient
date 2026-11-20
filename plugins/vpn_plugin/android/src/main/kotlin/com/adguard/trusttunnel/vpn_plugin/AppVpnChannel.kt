package com.adguard.trusttunnel.vpn_plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.os.Build
import com.adguard.trusttunnel.AppVpnException
import com.adguard.trusttunnel.AppVpnRules
import com.adguard.trusttunnel.AppVpnStore
import com.adguard.trusttunnel.VpnService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

/** The installed-app catalog is requested only by the editor, off the UI thread. */
internal class AppVpnChannel(
    private val context: Context,
    messenger: BinaryMessenger,
    private val vpn: NativeVpnImpl
) : EventChannel.StreamHandler {
    private val methods = MethodChannel(messenger, "trusttunnel/app_vpn", StandardMethodCodec.INSTANCE, messenger.makeBackgroundTaskQueue())
    private val changes = EventChannel(messenger, "trusttunnel/app_vpn_changes")
    private var sink: EventChannel.EventSink? = null
    private val changed: () -> Unit = { sink?.success("status") }
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            sink?.success("packages")
        }
    }

    init {
        methods.setMethodCallHandler(::handle)
        changes.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        if (sink != null) onCancel(null)
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_CHANGED)
            addDataScheme("package")
        }
        if (Build.VERSION.SDK_INT >= 33) context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        else @Suppress("DEPRECATION") context.registerReceiver(receiver, filter)
        sink = events
        vpn.addListener(changed)
        events.success("status")
    }

    override fun onCancel(arguments: Any?) {
        if (sink == null) return
        sink = null
        vpn.removeListener(changed)
        context.unregisterReceiver(receiver)
    }

    fun dispose() {
        onCancel(null)
        methods.setMethodCallHandler(null)
        changes.setStreamHandler(null)
    }

    private fun AppVpnRules.toMap() = mapOf(
        "enabled" to enabled, "bypass" to bypass, "packages" to packages.sorted(), "revision" to revision
    )

    private fun snapshot(): Map<String, Any?> {
        var storageError: String? = null
        val rules = try { AppVpnStore.read(context) } catch (e: AppVpnException) {
            storageError = e.reason
            null
        }
        val status = VpnService.appVpnStatus
        val applied = status.applied
        return mapOf(
            "rules" to rules?.toMap(), "storageError" to storageError, "applied" to applied?.rules?.toMap(),
            "effective" to applied?.installed?.keys?.sorted(), "error" to status.error,
            "state" to vpn.getCurrentState().name
        )
    }

    private fun handle(call: MethodCall, reply: MethodChannel.Result) {
        try {
            when (call.method) {
                "catalog" -> {
                    val pm = context.packageManager
                    val apps = pm.getInstalledApplications(0).filter { it.uid != context.applicationInfo.uid }.map { app ->
                        mapOf("package" to app.packageName, "label" to app.loadLabel(pm).toString(), "uid" to app.uid,
                            "system" to (app.flags and (ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0))
                    }
                    reply.success(apps)
                }
                "status" -> reply.success(snapshot())
                "save" -> {
                    val rules = AppVpnRules(
                        requireNotNull(call.argument<Boolean>("enabled")), requireNotNull(call.argument<Boolean>("bypass")),
                        requireNotNull(call.argument<List<String>>("packages")).toSet()
                    )
                    AppVpnStore.save(context, rules, requireNotNull(call.argument<String>("revision")))
                    vpn.appVpnEdited()
                    reply.success(null)
                }
                "repair" -> {
                    AppVpnStore.save(context, AppVpnRules(), null, repair = true)
                    vpn.appVpnEdited()
                    reply.success(null)
                }
                "reconnect" -> {
                    VpnService.reconnectWithAppVpn(context, requireNotNull(call.argument<String>("revision")))
                    reply.success(null)
                }
                else -> reply.notImplemented()
            }
        } catch (e: AppVpnException) {
            reply.error(e.reason, null, null)
        } catch (_: Exception) {
            reply.error("operation", null, null)
        }
    }
}
