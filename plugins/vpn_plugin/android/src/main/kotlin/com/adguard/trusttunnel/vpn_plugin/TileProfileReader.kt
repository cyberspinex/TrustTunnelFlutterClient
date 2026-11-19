package com.adguard.trusttunnel.vpn_plugin

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

internal data class TileProfile(val id: String, val config: String)

/** One short-lived isolate reads the same Drift database and Dart codec as the UI. */
internal class TileProfileReader(private val context: Context) {
    private val main = Handler(Looper.getMainLooper())
    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null

    fun load(done: (TileProfile?, Int) -> Unit) {
        cancel()
        try {
            val worker = FlutterEngine(context)
            engine = worker
            val bridge = MethodChannel(worker.dartExecutor.binaryMessenger, "trusttunnel/tile_profile")
            channel = bridge
            bridge.setMethodCallHandler { call, result ->
                if (call.method != "profile") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val config = call.argument<String>("config")
                val id = call.argument<String>("id")
                val profile = if (!id.isNullOrBlank() && !config.isNullOrBlank()) TileProfile(id, config) else null
                val error = when (call.argument<String>("error")) {
                    "no_server" -> R.string.qs_no_server
                    "choose_server" -> R.string.qs_choose_server
                    else -> R.string.qs_invalid_profile
                }
                result.success(null)
                main.post {
                    if (engine === worker) {
                        cancel()
                        done(profile, error)
                    }
                }
            }
            val bundle = FlutterInjector.instance().flutterLoader().findAppBundlePath()
            worker.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(bundle, "quickSettingsProfileMain"))
        } catch (_: Exception) {
            cancel()
            done(null, R.string.qs_failed)
        }
    }

    fun cancel() {
        channel?.setMethodCallHandler(null)
        channel = null
        engine?.destroy()
        engine = null
    }
}
