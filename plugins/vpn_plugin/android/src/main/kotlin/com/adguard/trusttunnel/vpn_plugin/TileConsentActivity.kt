package com.adguard.trusttunnel.vpn_plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle

/** The OS owns the consent dialog. Only a request identifier crosses the activity boundary. */
class TileConsentActivity : Activity() {
    companion object {
        private const val REQUEST = 71
        private const val TICKET = "vpn_request"

        fun intent(context: Context, ticket: Int): Intent =
            Intent(context, TileConsentActivity::class.java).putExtra(TICKET, ticket)
    }

    private val vpn by lazy { NativeVpnImpl.get(applicationContext) }
    private var ticket = 0
    private var asking = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ticket = intent.getIntExtra(TICKET, 0)
        if (!vpn.awaitingPermission(ticket)) {
            finish()
            return
        }
        asking = savedInstanceState?.getBoolean("asking") ?: false
        if (asking) return
        vpn.prepareConsent(ticket) { valid, prompt ->
            if (isFinishing || isDestroyed) return@prepareConsent
            if (!valid || !vpn.awaitingPermission(ticket)) {
                finish()
            } else if (prompt == null) {
                vpn.permissionResult(ticket, true)
                finish()
            } else {
                try {
                    asking = true
                    startActivityForResult(prompt, REQUEST)
                } catch (_: RuntimeException) {
                    vpn.permissionResult(ticket, false)
                    finish()
                }
            }
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        outState.putBoolean("asking", asking)
        super.onSaveInstanceState(outState)
    }

    @Deprecated("Android delivers VPN consent as an activity result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST) {
            vpn.permissionResult(ticket, resultCode == RESULT_OK)
            finish()
        }
    }

    override fun onDestroy() {
        if (isFinishing && vpn.awaitingPermission(ticket)) vpn.permissionResult(ticket, false)
        super.onDestroy()
    }
}
