package com.optisec.optisec_mobile.applock

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import com.optisec.optisec_mobile.MainActivity
import com.optisec.optisec_mobile.R

/**
 * Foreground service that polls [UsageStatsManager] roughly every 700ms to
 * detect when a locked app enters the foreground, then throws up the
 * overlay curtain immediately and launches [LockScreenActivity] on top of
 * it. Reuses the same "Usage Access" special permission already required by
 * the Permission Usage feature — no additional permission grant needed.
 */
class AppLockMonitorService : Service() {

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var store: AppLockStore
    private lateinit var overlayManager: LockOverlayManager
    private lateinit var usageStatsManager: UsageStatsManager

    private var lastEventTime: Long = 0L
    private var currentForegroundPackage: String? = null

    private val pollRunnable = object : Runnable {
        override fun run() {
            poll()
            handler.postDelayed(this, POLL_INTERVAL_MS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        store = AppLockStore.getInstance(this)
        overlayManager = LockOverlayManager.getInstance(this)
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        lastEventTime = System.currentTimeMillis() - POLL_INTERVAL_MS
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundWithNotification()
        handler.removeCallbacks(pollRunnable)
        handler.post(pollRunnable)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(pollRunnable)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun poll() {
        if (!store.isFeatureEnabled()) return
        val lockedPackages = store.getLockedPackages()
        if (lockedPackages.isEmpty()) return

        val now = System.currentTimeMillis()
        var latestForeground: String? = null

        try {
            val events = usageStatsManager.queryEvents(lastEventTime, now)
            val event = UsageEvents.Event()
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                    latestForeground = event.packageName
                }
            }
        } catch (_: Exception) {
            // Usage Access may have been revoked mid-session; skip this tick.
        }
        lastEventTime = now

        if (latestForeground != null && latestForeground != currentForegroundPackage) {
            onForegroundChanged(latestForeground, lockedPackages)
        }
    }

    private fun onForegroundChanged(pkg: String, lockedPackages: Set<String>) {
        currentForegroundPackage = pkg
        if (pkg == packageName) return

        if (pkg != unlockedPackage) {
            unlockedPackage = null
        }

        if (pkg in lockedPackages && pkg != unlockedPackage) {
            triggerLock(pkg)
        }
    }

    private fun triggerLock(pkg: String) {
        overlayManager.show()
        val intent = Intent(this, LockScreenActivity::class.java).apply {
            putExtra(LockScreenActivity.EXTRA_TARGET_PACKAGE, pkg)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun startForegroundWithNotification() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                getString(R.string.app_lock_notification_channel_name),
                NotificationManager.IMPORTANCE_MIN,
            ).apply {
                description = getString(R.string.app_lock_notification_channel_description)
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }

        val openAppIntent = android.app.PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            android.app.PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle(getString(R.string.app_lock_notification_title))
            .setContentText(getString(R.string.app_lock_notification_text))
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(openAppIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceCompat.startForeground(
                this,
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    companion object {
        private const val POLL_INTERVAL_MS = 700L
        private const val NOTIFICATION_CHANNEL_ID = "app_lock_monitor"
        private const val NOTIFICATION_ID = 4201

        /**
         * The package currently authenticated for this foreground session.
         * Cleared as soon as the foreground app changes to something else,
         * so returning to it later re-prompts.
         */
        @Volatile
        var unlockedPackage: String? = null

        fun markUnlocked(packageName: String) {
            unlockedPackage = packageName
        }

        fun start(context: Context) {
            val intent = Intent(context, AppLockMonitorService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, AppLockMonitorService::class.java))
        }

        fun isRunning(context: Context): Boolean {
            val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            @Suppress("DEPRECATION")
            return manager.getRunningServices(Int.MAX_VALUE).any {
                it.service.className == AppLockMonitorService::class.java.name
            }
        }
    }
}
