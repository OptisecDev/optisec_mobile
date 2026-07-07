package com.optisec.optisec_mobile.applock

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

/**
 * Dedicated MethodChannel handler for the `com.optisec.mobile/app_lock`
 * channel. Kept separate from [com.optisec.optisec_mobile.MainActivity]
 * (unlike the existing permission_usage channel, which is inlined there)
 * because App Lock owns considerably more native surface area.
 */
class AppLockChannelHandler(private val activity: Activity) {

    private val store = AppLockStore.getInstance(activity)

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getInstalledApps" -> result.success(getInstalledApps())
                    "getLockedApps" -> result.success(store.getLockedPackages().toList())
                    "setLockedApps" -> {
                        val packages = (call.arguments as? List<*>)
                            ?.filterIsInstance<String>()
                            ?.toSet()
                            ?: emptySet()
                        store.setLockedPackages(packages)
                        store.setFeatureEnabled(packages.isNotEmpty())
                        result.success(null)
                    }
                    "isPinSet" -> result.success(store.isPinSet())
                    "setPin" -> {
                        val pin = call.argument<String>("pin")
                        if (pin.isNullOrEmpty()) {
                            result.error("INVALID_PIN", "PIN must not be empty", null)
                            return@setMethodCallHandler
                        }
                        store.setPin(pin)
                        result.success(null)
                    }
                    "verifyPin" -> {
                        val pin = call.argument<String>("pin")
                        if (pin.isNullOrEmpty()) {
                            result.error("INVALID_PIN", "PIN must not be empty", null)
                            return@setMethodCallHandler
                        }
                        val remaining = store.getLockoutRemainingMillis()
                        if (remaining > 0) {
                            result.error(
                                "LOCKED_OUT",
                                "Too many failed attempts",
                                remaining,
                            )
                            return@setMethodCallHandler
                        }
                        result.success(store.verifyPin(pin))
                    }
                    "hasOverlayPermission" -> result.success(hasOverlayPermission())
                    "openOverlaySettings" -> {
                        openOverlaySettings()
                        result.success(null)
                    }
                    "isMonitorServiceRunning" -> result.success(
                        AppLockMonitorService.isRunning(activity),
                    )
                    "startMonitorService" -> {
                        store.setFeatureEnabled(true)
                        AppLockMonitorService.start(activity)
                        result.success(null)
                    }
                    "stopMonitorService" -> {
                        store.setFeatureEnabled(false)
                        AppLockMonitorService.stop(activity)
                        result.success(null)
                    }
                    "isIgnoringBatteryOptimizations" -> result.success(
                        isIgnoringBatteryOptimizations(),
                    )
                    "requestIgnoreBatteryOptimizations" -> {
                        requestIgnoreBatteryOptimizations()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("APP_LOCK_ERROR", e.message, null)
            }
        }
    }

    // ── Installed apps ───────────────────────────────────────────────
    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = activity.packageManager
        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)

        val resolved: List<ResolveInfo> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(
                launcherIntent,
                PackageManager.ResolveInfoFlags.of(0L),
            )
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(launcherIntent, 0)
        }

        return resolved
            .mapNotNull { it.activityInfo?.packageName }
            .distinct()
            .filter { it != activity.packageName }
            .mapNotNull { pkg ->
                try {
                    val appInfo = pm.getApplicationInfo(pkg, 0)
                    mapOf(
                        "packageName" to pkg,
                        "appName" to pm.getApplicationLabel(appInfo).toString(),
                        "icon" to drawableToBase64Png(pm.getApplicationIcon(appInfo)),
                    )
                } catch (_: PackageManager.NameNotFoundException) {
                    null
                }
            }
            .sortedBy { (it["appName"] as String).lowercase() }
    }

    private fun drawableToBase64Png(drawable: Drawable, size: Int = 96): String {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            Bitmap.createScaledBitmap(drawable.bitmap, size, size, true)
        } else {
            val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, size, size)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }

    // ── Overlay permission ───────────────────────────────────────────
    private fun hasOverlayPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(activity)

    private fun openOverlaySettings() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${activity.packageName}"),
        )
        try {
            activity.startActivity(intent)
        } catch (_: Exception) {
            activity.startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION))
        }
    }

    // ── Battery optimization ─────────────────────────────────────────
    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val powerManager = activity.getSystemService(Context.POWER_SERVICE) as PowerManager
        return powerManager.isIgnoringBatteryOptimizations(activity.packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${activity.packageName}")
        }
        try {
            activity.startActivity(intent)
        } catch (_: Exception) {
            activity.startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
        }
    }

    companion object {
        const val CHANNEL_NAME = "com.optisec.mobile/app_lock"
    }
}
