package com.optisec.optisec_mobile.applock

import android.content.Context
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.WindowManager

/**
 * Draws an opaque full-screen curtain via TYPE_APPLICATION_OVERLAY the
 * instant a locked app is detected in the foreground, so there is no frame
 * of the underlying app's content visible while [LockScreenActivity] is
 * still being launched on top of it. Requires SYSTEM_ALERT_WINDOW.
 */
class LockOverlayManager(private val context: Context) {

    private val windowManager =
        context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private var curtain: View? = null

    fun show() {
        if (curtain != null) return
        if (!hasOverlayPermission()) return

        val view = View(context.applicationContext).apply {
            setBackgroundColor(Color.BLACK)
        }

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
            android.graphics.PixelFormat.OPAQUE,
        )

        try {
            windowManager.addView(view, params)
            curtain = view
        } catch (_: Exception) {
            // OEM-specific overlay restrictions; the lock Activity is the
            // real gate, the curtain is only a best-effort flash-guard.
            curtain = null
        }
    }

    fun hide() {
        val view = curtain ?: return
        try {
            windowManager.removeView(view)
        } catch (_: Exception) {
            // Already detached.
        }
        curtain = null
    }

    private fun hasOverlayPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            android.provider.Settings.canDrawOverlays(context.applicationContext)

    companion object {
        // Shared across the monitor service (which shows it) and the lock
        // Activity (which hides it) so both operate on the same curtain view.
        @Volatile
        private var instance: LockOverlayManager? = null

        fun getInstance(context: Context): LockOverlayManager =
            instance ?: synchronized(this) {
                instance ?: LockOverlayManager(context).also { instance = it }
            }
    }
}
