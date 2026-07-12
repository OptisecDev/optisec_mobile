package com.optisec.optisec_mobile

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import com.optisec.optisec_mobile.applock.AppLockChannelHandler
import com.optisec.optisec_mobile.purchase.PurchaseChannelHandler
import com.optisec.optisec_mobile.vault.VaultChannelHandler
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.Instant

/**
 * Extends [FlutterFragmentActivity] rather than the lighter-weight
 * `FlutterActivity` because the Password Vault's biometric unlock
 * ([com.optisec.optisec_mobile.vault.VaultBiometricManager]) needs a
 * `FragmentActivity` host for `BiometricPrompt` — the App Lock feature's own
 * biometric prompt runs in a separate [com.optisec.optisec_mobile.applock.LockScreenActivity]
 * that already extends `FragmentActivity` directly, so this only matters now
 * that a Flutter screen itself triggers a biometric prompt.
 */
class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.optisec.mobile/permission_usage"
    private val screenSecurityChannelName = "com.optisec.mobile/screen_security"

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

    // Maps Android runtime permissions to the Privacy Guard permission ids
    // used in the Flutter UI (lib/features/privacy_guard). Separate from
    // [trackedPermissions] above (which only covers the 3 categories the
    // usage-timeline feature proxies via UsageStatsManager) since Privacy
    // Guard also needs contacts/phone/storage, which have no foreground-use
    // proxy but *do* have a real granted/not-granted signal via PackageManager.
    private val privacyGuardPermissions = mapOf(
        android.Manifest.permission.ACCESS_FINE_LOCATION to "location",
        android.Manifest.permission.ACCESS_COARSE_LOCATION to "location",
        android.Manifest.permission.CAMERA to "camera",
        android.Manifest.permission.RECORD_AUDIO to "microphone",
        android.Manifest.permission.READ_CONTACTS to "contacts",
        android.Manifest.permission.READ_PHONE_STATE to "phone",
        android.Manifest.permission.READ_EXTERNAL_STORAGE to "storage",
        android.Manifest.permission.READ_MEDIA_IMAGES to "storage",
        android.Manifest.permission.READ_MEDIA_VIDEO to "storage",
        android.Manifest.permission.READ_MEDIA_AUDIO to "storage",
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
                    "getPermissionHolders" -> {
                        try {
                            result.success(getPermissionHolders())
                        } catch (e: Exception) {
                            result.error("PERMISSION_HOLDERS_QUERY_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, screenSecurityChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        runOnUiThread {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    "disable" -> {
                        runOnUiThread {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        AppLockChannelHandler(this).register(flutterEngine.dartExecutor.binaryMessenger)
        VaultChannelHandler(this).register(flutterEngine.dartExecutor.binaryMessenger)
        PurchaseChannelHandler().register(flutterEngine.dartExecutor.binaryMessenger)
    }

    // ── Password Vault: Storage Access Framework pickers ───────────────
    // Classic startActivityForResult/onActivityResult rather than the
    // androidx Activity Result API: FlutterFragmentActivity doesn't
    // guarantee registerForActivityResult() can be called this late (it
    // must happen before the activity reaches STARTED), and the rest of
    // this file already uses the classic pattern for every other
    // Settings-screen round trip.
    private var pendingCreateDocumentCallback: ((Uri?) -> Unit)? = null
    private var pendingOpenDocumentCallback: ((Uri?) -> Unit)? = null

    fun launchCreateDocument(suggestedName: String, onResult: (Uri?) -> Unit) {
        pendingCreateDocumentCallback = onResult
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, suggestedName)
        }
        startActivityForResult(intent, REQUEST_CODE_CREATE_DOCUMENT)
    }

    fun launchOpenDocument(onResult: (Uri?) -> Unit) {
        pendingOpenDocumentCallback = onResult
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
        }
        startActivityForResult(intent, REQUEST_CODE_OPEN_DOCUMENT)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val uri = if (resultCode == RESULT_OK) data?.data else null
        when (requestCode) {
            REQUEST_CODE_CREATE_DOCUMENT -> {
                pendingCreateDocumentCallback?.invoke(uri)
                pendingCreateDocumentCallback = null
            }
            REQUEST_CODE_OPEN_DOCUMENT -> {
                pendingOpenDocumentCallback?.invoke(uri)
                pendingOpenDocumentCallback = null
            }
        }
    }

    companion object {
        private const val REQUEST_CODE_CREATE_DOCUMENT = 4301
        private const val REQUEST_CODE_OPEN_DOCUMENT = 4302
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

    // ── Privacy Guard: real per-app permission holders ─────────────────
    // Returns, for each Privacy Guard permission id (location/camera/
    // microphone/contacts/phone/storage), the list of other installed apps
    // that actually hold that permission grant — via PackageManager, no
    // fabricated data. Enumeration is scoped to apps with a launcher
    // activity (the same <queries> intent-filter declared in the manifest
    // for the App Lock picker in AppLockChannelHandler.getInstalledApps),
    // so background-only apps without a launcher icon won't appear here;
    // that's a real, disclosed scope limit, not an accuracy issue for the
    // apps it does report.
    private fun getPermissionHolders(): Map<String, List<Map<String, Any?>>> {
        val pm = packageManager
        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(launcherIntent, PackageManager.ResolveInfoFlags.of(0L))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(launcherIntent, 0)
        }

        val result = mutableMapOf<String, MutableList<Map<String, Any?>>>()
        val seenPerCategory = mutableMapOf<String, MutableSet<String>>()

        resolved
            .mapNotNull { it.activityInfo?.packageName }
            .distinct()
            .filter { it != packageName }
            .forEach { pkg ->
                val categories = grantedPrivacyGuardCategories(pm, pkg)
                if (categories.isEmpty()) return@forEach

                val label = try {
                    pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
                } catch (_: PackageManager.NameNotFoundException) {
                    pkg
                }

                for (category in categories) {
                    val seen = seenPerCategory.getOrPut(category) { mutableSetOf() }
                    if (seen.add(pkg)) {
                        result.getOrPut(category) { mutableListOf() }.add(
                            mapOf("packageName" to pkg, "appName" to label),
                        )
                    }
                }
            }
        return result
    }

    private fun grantedPrivacyGuardCategories(pm: PackageManager, pkg: String): Set<String> {
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
            if (granted) privacyGuardPermissions[perm]?.let { result.add(it) }
        }
        return result
    }
}
