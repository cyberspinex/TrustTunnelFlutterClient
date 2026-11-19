package com.adguard.trusttunnel.vpn_plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.VpnService as AndroidVpn
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import com.adguard.trusttunnel.AppNotifier
import com.adguard.trusttunnel.VpnService
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.util.ArrayDeque
import java.util.concurrent.ThreadLocalRandom

/** The SDK has one AppNotifier per process. Both Android entry points use this owner. */
internal class NativeVpnImpl private constructor(private val context: Context) : AppNotifier {
    companion object {
        private var instance: NativeVpnImpl? = null

        @Synchronized fun get(context: Context): NativeVpnImpl =
            instance ?: NativeVpnImpl(context.applicationContext).also { instance = it }
    }

    private enum class Stage { IDLE, PROFILE, PERMISSION, STARTING, STOPPING }
    private data class AppStart(val config: String, val recovery: Boolean, val activity: Activity?)

    private val main = Handler(Looper.getMainLooper())
    private val reader = TileProfileReader(context)
    private val observers = mutableSetOf<() -> Unit>()
    private var known = false
    @Volatile private var state = VpnManagerState.DISCONNECTED
    private var stage = Stage.IDLE
    private var ticket = 0
    private var timeout: Runnable? = null
    private var firstAction: (() -> Unit)? = null
    private var appRequest: AppStart? = null
    private var afterStop: AppStart? = null
    private var permissionServer: String? = null
    private var tileServer: String? = null
    private var awaitingConnection = false
    private var problem: Int? = null
    val states = ReplayStream { state.ordinal }
    val tileSessions = ReplayStream { tileServer }
    val queryLogHandler = QueryLogStreamHandler()

    init {
        VpnService.initialize(context)
        VpnService.setAppNotifier(File(context.filesDir, "query_log.dat"), this)
    }

    val connected get() = state == VpnManagerState.CONNECTED
    val tileClickable get() = known && stage == Stage.IDLE
    val tileStatus: Int get() = when {
        !known -> R.string.qs_checking
        stage == Stage.PROFILE -> R.string.qs_loading
        stage == Stage.PERMISSION -> R.string.qs_permission
        stage == Stage.STARTING -> R.string.qs_connecting
        stage == Stage.STOPPING -> R.string.qs_stopping
        problem != null -> problem!!
        else -> when (state) {
            VpnManagerState.DISCONNECTED -> R.string.qs_off
            VpnManagerState.CONNECTED -> R.string.qs_on
            VpnManagerState.CONNECTING -> R.string.qs_connecting
            VpnManagerState.WAITING_FOR_NETWORK -> R.string.qs_network
            VpnManagerState.WAITING_FOR_RECOVERY -> R.string.qs_wait_retry
            VpnManagerState.RECOVERING -> R.string.qs_retry
        }
    }

    fun addListener(observer: () -> Unit) { observers.add(observer) }
    fun removeListener(observer: () -> Unit) { observers.remove(observer) }
    private fun refresh() = observers.toList().forEach { it() }
    fun getCurrentState(): VpnManagerState = state

    /** All transitions, including callbacks from the SDK's worker thread, are serialized on main. */
    override fun onStateChanged(state: Int) {
        val next = VpnManagerState.entries.getOrNull(state) ?: return
        main.post {
            val initial = !known
            known = true
            this.state = next
            if (next == VpnManagerState.DISCONNECTED) {
                if (!initial && awaitingConnection && stage != Stage.STOPPING) problem = R.string.qs_failed
                awaitingConnection = false
                tileServer = null
                tileSessions.emit()
                if (stage == Stage.STARTING || stage == Stage.STOPPING) setStage(Stage.IDLE)
            } else {
                problem = null
                if (stage == Stage.STARTING) setStage(Stage.IDLE)
                if (stage == Stage.PROFILE || stage == Stage.PERMISSION) invalidate()
                if (next == VpnManagerState.CONNECTED) awaitingConnection = false
            }
            states.emit()
            refresh()
            if (initial) {
                val action = firstAction
                firstAction = null
                action?.invoke()
            }
            if (next == VpnManagerState.DISCONNECTED && stage == Stage.IDLE) {
                val queued = afterStop
                afterStop = null
                if (queued != null) beginApp(queued)
            }
        }
    }

    override fun onConnectionInfo(info: String) = queryLogHandler.offer(info)

    fun toggle(openConsent: (Int) -> Unit) {
        if (!known) {
            if (firstAction == null) firstAction = { toggle(openConsent) }
            return
        }
        if (stage != Stage.IDLE) return
        if (state != VpnManagerState.DISCONNECTED) {
            stopNow()
            return
        }
        begin()
        try {
            if (AndroidVpn.prepare(context) == null) loadAndStart(ticket) else {
                setStage(Stage.PERMISSION)
                openConsent(ticket)
            }
        } catch (_: RuntimeException) {
            fail(R.string.qs_permission_failed)
        }
    }

    fun startFromApp(config: String, recovery: Boolean, activity: Activity?) {
        main.post {
            val request = AppStart(config, recovery, activity)
            if (known) beginApp(request) else firstAction = { beginApp(request) }
        }
    }

    private fun beginApp(request: AppStart) {
        if (stage == Stage.STOPPING) {
            afterStop = request
            return
        }
        if (stage == Stage.STARTING || state != VpnManagerState.DISCONNECTED) {
            afterStop = request
            stopNow()
            return
        }
        begin()
        appRequest = request
        try {
            if (AndroidVpn.prepare(context) == null) submit(request.config, request.recovery, null) else {
                val activity = request.activity
                if (activity == null || activity.isFinishing || activity.isDestroyed) {
                    fail(R.string.qs_permission_failed)
                    return
                }
                setStage(Stage.PERMISSION)
                activity.startActivity(TileConsentActivity.intent(activity, ticket))
            }
        } catch (_: RuntimeException) {
            fail(R.string.qs_permission_failed)
        }
    }

    fun stop() {
        main.post {
            afterStop = null
            firstAction = null
            if (known) stopNow() else firstAction = { stopNow() }
        }
    }

    private fun stopNow() {
        if (stage == Stage.STOPPING) return
        val sentStart = stage == Stage.STARTING
        invalidate()
        problem = null
        awaitingConnection = false
        if (!sentStart && state == VpnManagerState.DISCONNECTED) {
            states.emit()
            refresh()
            return
        }
        setStage(Stage.STOPPING)
        try {
            VpnService.stop(context)
        } catch (_: RuntimeException) {
            fail(R.string.qs_stop_failed)
        }
    }

    fun awaitingPermission(id: Int) = ticket == id && stage == Stage.PERMISSION

    fun prepareConsent(id: Int, ready: (Boolean, Intent?) -> Unit) {
        if (!awaitingPermission(id)) return ready(false, null)
        fun prompt() {
            try {
                ready(true, AndroidVpn.prepare(context))
            } catch (_: RuntimeException) {
                fail(R.string.qs_permission_failed)
                ready(false, null)
            }
        }
        if (appRequest != null) return prompt()
        reader.load { profile, error ->
            if (!awaitingPermission(id)) return@load ready(false, null)
            if (profile == null) {
                fail(error)
                ready(false, null)
            } else {
                permissionServer = profile.id
                prompt()
            }
        }
    }

    fun permissionResult(id: Int, granted: Boolean) {
        if (!awaitingPermission(id)) return
        if (!granted) {
            fail(R.string.qs_permission_denied)
            return
        }
        val app = appRequest
        if (app == null) loadAndStart(id) else submit(app.config, app.recovery, null)
    }

    private fun loadAndStart(id: Int) {
        setStage(Stage.PROFILE)
        reader.load { profile, error ->
            if (ticket != id || stage != Stage.PROFILE) return@load
            if (profile == null) fail(error)
            else if (permissionServer != null && permissionServer != profile.id) fail(R.string.qs_profile_changed)
            else submit(profile.config, false, profile.id)
        }
    }

    private fun submit(config: String, recovery: Boolean, externalId: String?) {
        try {
            if (AndroidVpn.prepare(context) != null) {
                fail(R.string.qs_permission_failed)
                return
            }
            appRequest = null
            tileServer = externalId
            tileSessions.emit()
            awaitingConnection = true
            setStage(Stage.STARTING)
            VpnService.start(context, config, recovery)
        } catch (_: RuntimeException) {
            fail(R.string.qs_failed)
        }
    }

    private fun begin() {
        invalidate()
        problem = null
    }

    private fun invalidate() {
        ticket = ThreadLocalRandom.current().nextInt(1, Int.MAX_VALUE)
        appRequest = null
        permissionServer = null
        reader.cancel()
        setStage(Stage.IDLE)
    }

    private fun fail(message: Int) {
        afterStop = null
        awaitingConnection = false
        if (state == VpnManagerState.DISCONNECTED) {
            tileServer = null
            tileSessions.emit()
        }
        invalidate()
        problem = message
        states.emit()
        refresh()
        Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }

    private fun setStage(value: Stage) {
        timeout?.let(main::removeCallbacks)
        timeout = null
        stage = value
        if (value != Stage.IDLE) {
            val id = ticket
            val watchdog = Runnable {
                if (ticket != id || stage != value) return@Runnable
                if (value == Stage.STARTING) {
                    // The SDK can return without a state event. Withdraw any late start.
                    try { VpnService.stop(context) } catch (_: RuntimeException) { }
                }
                fail(when (value) {
                    Stage.PERMISSION -> R.string.qs_permission_failed
                    Stage.STOPPING -> R.string.qs_stop_failed
                    else -> R.string.qs_failed
                })
            }
            timeout = watchdog
            main.postDelayed(watchdog, if (value == Stage.PERMISSION) 180_000L else 30_000L)
        }
        refresh()
    }

    fun exportLogs(): List<String> = VpnService.exportLogs(context)
    fun clearLogs() = VpnService.clearLogs()
}

/** Each Flutter engine gets its own subscription; detaching a worker cannot disconnect the UI. */
internal class ReplayStream(private val snapshot: () -> Any?) {
    private val sinks = mutableSetOf<EventChannel.EventSink>()
    fun handler() = object : EventChannel.StreamHandler {
        var sink: EventChannel.EventSink? = null
        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            sink?.let(sinks::remove)
            sink = events
            sinks.add(events)
            events.success(snapshot())
        }
        override fun onCancel(arguments: Any?) {
            sink?.let(sinks::remove)
            sink = null
        }
    }
    fun emit() = sinks.toList().forEach { it.success(snapshot()) }
}

internal class QueryLogStreamHandler : EventChannel.StreamHandler {
    private val main = Handler(Looper.getMainLooper())
    private val queue = ArrayDeque<String>()
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        while (queue.isNotEmpty()) events?.success(queue.removeFirst()) ?: break
    }
    override fun onCancel(arguments: Any?) { sink = null }
    fun offer(record: String) {
        main.post {
            val listener = sink
            if (listener != null) listener.success(record) else {
                if (queue.size == 1000) queue.removeFirst()
                queue.addLast(record)
            }
        }
    }
}
