package com.optisec.optisec_mobile

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import com.optisec.optisec_mobile.applock.AppLockChannelHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.Instant

class MainActivity : FlutterActivity() {
    private val channelName = "com.optisec.mobile/permission_usage"

    // The permission ops we proxy usage for. Real per-op history
    // (AppOpsManager.getPackageOpsForOps) is a hidden @SystemApi guarded by
    // the signature-only GET_APP_OPS_STATS permission — unreachable for a
    // normal Play Store app. Instead we use UsageStatsManager (public API,
    // gated by the user-granted "Usage Access" special setting) as a
    // foreground-time proxy: an app's usage window is treated as a stand-in
    // for "this app could have used its granted sensors during this time."
    private val trackedPermissions = mapOf(
        android.Manifest.permission.CAMERA to "CAMERA",
        android.Manifest.permission.RECORD_AUDIO to "MICROPHONE",
        android.Manifest.permission.ACCESS_FINE_LOCATION to "LOCATION",
        android.Manifest.permission.ACCESS_COARSE_LOCATION to "LOCATION",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "openUsageAccessSettings" -> {
                        openUsageAccessSettings()
                        result.success(null)
                    }
                    "getPermissionUsage" -> {
                        if (!hasUsageAccess()) {
                            result.error(
                                "NO_USAGE_ACCESS",
                                "Usage Access has not been granted",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        try {
                            result.success(getPermissionUsage())
                        } catch (e: Exception) {
                            result.error("USAGE_QUERY_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        AppLockChannelHandler(this).register(flutterEngine.dartExecutor.binaryMessenger)
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
        }
        try {
            startActivity(intent)
        } catch (_: Exception) {
            // Some OEMs don't honor the package: data URI on this screen;
            // fall back to the bare settings list.
            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
        }
    }

    private data class PkgUsage(
        var lastForeground: Long? = null,
        var count: Int = 0,
        var currentlyForeground: Boolean = false,
    )

    private fun getPermissionUsage(): List<Map<String, Any?>> {
        val pm = packageManager
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val end = System.currentTimeMillis()
        val start = end - 7L * 24 * 60 * 60 * 1000

        // Walk raw foreground/background events rather than
        // queryUsageStats(), since we need per-event timestamps for
        // access counts, not pre-aggregated totals.
        val usage = mutableMapOf<String, PkgUsage>()

        val events = usm.queryEvents(start, end)
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val entry = usage.getOrPut(event.packageName) { PkgUsage() }
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    entry.lastForeground = event.timeStamp
                    entry.count += 1
                    entry.currentlyForeground = true
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                    entry.currentlyForeground = false
                }
            }
        }

        val records = mutableListOf<Map<String, Any?>>()
        for ((pkg, pkgUsage) in usage) {
            val grantedTypes = grantedTrackedPermissions(pm, pkg)
            if (grantedTypes.isEmpty()) continue

            val label = try {
                pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
            } catch (_: PackageManager.NameNotFoundException) {
                pkg
            }

            for (type in grantedTypes) {
                records.add(
                    mapOf(
                        "packageName" to pkg,
                        "appLabel" to label,
                        "permissionType" to type,
                        // These reflect foreground app time (via UsageStatsManager),
                        // not confirmed sensor access — see the class-level comment.
                        "lastForegroundTime" to pkgUsage.lastForeground?.let {
                            Instant.ofEpochMilli(it).toString()
                        },
                        "isCurrentlyInForeground" to pkgUsage.currentlyForeground,
                        "foregroundSessionCountLast7Days" to pkgUsage.count,
                    )
                )
            }
        }
        return records
    }

    private fun grantedTrackedPermissions(pm: PackageManager, pkg: String): Set<String> {
        val info = try {
            pm.getPackageInfo(pkg, PackageManager.GET_PERMISSIONS)
        } catch (_: PackageManager.NameNotFoundException) {
            return emptySet()
        }
        val requested = info.requestedPermissions ?: return emptySet()
        val flags = info.requestedPermissionsFlags ?: return emptySet()

        val result = mutableSetOf<String>()
        for (i in requested.indices) {
            val perm = requested[i]
            val granted = flags[i] and android.content.pm.PackageInfo.REQUESTED_PERMISSION_GRANTED != 0
            if (granted) trackedPermissions[perm]?.let { result.add(it) }
        }
        return result
    }
}
