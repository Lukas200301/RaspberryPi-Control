package com.lukas200301.raspberrypi_control

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * Keeps the connection to a device alive while the app is not on screen.
 *
 * Android destroys the TCP sockets of an app as soon as it goes to the
 * background (and freezes it shortly after), which cut the SSH session,
 * stopped file transfers and even dropped the connection while the system
 * file picker was open. A foreground service keeps the process in a state
 * that keeps its network access, the same way terminal and SSH apps do.
 * The work itself still happens in Dart; this only shows the notification.
 */
class SessionService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var wifiLock: WifiManager.WifiLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelfCleanly()
            return START_NOT_STICKY
        }
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: "Connected"
        val text = intent?.getStringExtra(EXTRA_TEXT) ?: ""
        val progress = intent?.getIntExtra(EXTRA_PROGRESS, NO_PROGRESS) ?: NO_PROGRESS
        val notification = buildNotification(title, text, progress)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        // Keep the CPU and Wi-Fi awake only while bytes are moving
        if (progress != NO_PROGRESS) acquireLocks() else releaseLocks()
        // Without the app there is nothing to keep alive
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Swiping the app away ends the session
        stopSelfCleanly()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        releaseLocks()
        super.onDestroy()
    }

    private fun stopSelfCleanly() {
        releaseLocks()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
    }

    private fun acquireLocks() {
        if (wakeLock == null) {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "PiControl:transfer").apply {
                setReferenceCounted(false)
                // Safety net: never hold the CPU longer than a few hours
                acquire(4 * 60 * 60 * 1000L)
            }
        }
        if (wifiLock == null) {
            val wm = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            @Suppress("DEPRECATION")
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                WifiManager.WIFI_MODE_FULL_LOW_LATENCY
            } else {
                WifiManager.WIFI_MODE_FULL_HIGH_PERF
            }
            wifiLock = wm.createWifiLock(mode, "PiControl:transfer").apply {
                setReferenceCounted(false)
                acquire()
            }
        }
    }

    private fun releaseLocks() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        wifiLock?.let { if (it.isHeld) it.release() }
        wifiLock = null
    }

    private fun buildNotification(title: String, text: String, progress: Int): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && manager.getNotificationChannel(CHANNEL_ID) == null) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Active connection", NotificationManager.IMPORTANCE_LOW).apply {
                    description = "Shown while the app is connected to a device and while files are transferred"
                    setShowBadge(false)
                },
            )
        }
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setSmallIcon(R.drawable.ic_stat_pi)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(open)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
        if (progress != NO_PROGRESS) builder.setProgress(100, progress.coerceIn(0, 100), progress < 0)
        return builder.build()
    }

    companion object {
        private const val CHANNEL_ID = "session"
        private const val NOTIFICATION_ID = 4712
        private const val ACTION_STOP = "stop"
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_TEXT = "text"
        private const val EXTRA_PROGRESS = "progress"

        /** Progress value meaning "no progress bar" */
        const val NO_PROGRESS = -2

        /** Starts the service or updates its notification */
        fun update(context: Context, title: String, text: String, progress: Int) {
            val intent = Intent(context, SessionService::class.java)
                .putExtra(EXTRA_TITLE, title)
                .putExtra(EXTRA_TEXT, text)
                .putExtra(EXTRA_PROGRESS, progress)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, SessionService::class.java))
        }
    }
}
