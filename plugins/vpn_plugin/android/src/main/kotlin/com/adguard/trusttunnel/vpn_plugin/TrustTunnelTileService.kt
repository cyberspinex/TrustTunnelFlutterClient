package com.adguard.trusttunnel.vpn_plugin

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class TrustTunnelTileService : TileService() {
    private val vpn by lazy { NativeVpnImpl.get(applicationContext) }
    private val refresh: () -> Unit = { render() }

    override fun onStartListening() {
        super.onStartListening()
        vpn.addListener(refresh)
        render()
    }

    override fun onStopListening() {
        vpn.removeListener(refresh)
        super.onStopListening()
    }

    override fun onClick() {
        super.onClick()
        if (isLocked && isSecure) unlockAndRun { toggle() } else toggle()
    }

    @Suppress("DEPRECATION")
    private fun toggle() = vpn.toggle { ticket ->
        val intent = TileConsentActivity.intent(this, ticket).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= 34) {
            val prompt = PendingIntent.getActivity(this, ticket, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_ONE_SHOT)
            startActivityAndCollapse(prompt)
        } else {
            startActivityAndCollapse(intent)
        }
    }

    private fun render() {
        val tile = qsTile ?: return
        val label = getString(R.string.qs_name)
        val status = getString(vpn.tileStatus)
        tile.state = when {
            !vpn.tileClickable -> Tile.STATE_UNAVAILABLE
            vpn.connected -> Tile.STATE_ACTIVE
            else -> Tile.STATE_INACTIVE
        }
        tile.label = if (Build.VERSION.SDK_INT >= 29) label else getString(R.string.qs_label_status, label, status)
        if (Build.VERSION.SDK_INT >= 29) tile.subtitle = status
        tile.contentDescription = getString(R.string.qs_label_status, label, status)
        if (Build.VERSION.SDK_INT >= 30) tile.stateDescription = status
        tile.updateTile()
    }
}
