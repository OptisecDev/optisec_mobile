package com.optisec.optisec_mobile.applock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Restarts [AppLockMonitorService] after a reboot, but only if the user has
 * actually turned App Lock on and locked at least one app — otherwise there
 * is nothing to monitor and no reason to burn a foreground service slot.
 */
class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        val store = AppLockStore.getInstance(context)
        if (store.isFeatureEnabled() && store.getLockedPackages().isNotEmpty()) {
            AppLockMonitorService.start(context)
        }
    }
}
