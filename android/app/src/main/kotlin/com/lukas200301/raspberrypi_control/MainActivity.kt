package com.lukas200301.raspberrypi_control

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.app.PendingIntent
import android.app.NotificationManager
import android.app.NotificationChannel
import android.os.Build
import android.os.Environment
import androidx.core.app.NotificationCompat
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.os.Bundle
import androidx.core.content.FileProvider
import android.util.Log
import java.io.File
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.lukas200301.raspberrypi_control"
    private val NOTIFICATION_PERMISSION_CODE = 123
    private val STORAGE_PERMISSION_CODE = 124
    private lateinit var channel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestNotificationPermissions()
        requestStoragePermissions()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result -> 
            when (call.method) {
                "requestNotificationPermissions" -> {
                    requestNotificationPermissions()
                    result.success(null)
                }
                "requestStoragePermissions" -> {
                    requestStoragePermissions()
                    result.success(null)
                }
                "updateNotification" -> {
                    val title = call.argument<String>("title") ?: ""
                    val text = call.argument<String>("text") ?: ""
                    val clear = call.argument<Boolean>("clear") ?: false
                    if (clear || (title.isEmpty() && text.isEmpty())) {
                        getSystemService(NotificationManager::class.java).cancel(1)
                    } else {
                        updateNotification(title, text)
                    }
                    result.success(null)
                }
                "onDisconnectRequested" -> {
                    getSystemService(NotificationManager::class.java).cancel(1)
                    channel.invokeMethod("onDisconnect", null)
                    result.success(null)
                }
                "installApk" -> {
                    try {
                        val filePath = call.argument<String>("filePath")
                        if (filePath != null) {
                            Log.d("APK_INSTALL", "Installing APK from: $filePath")
                            val success = installApk(filePath)
                            result.success(success)
                        } else {
                            Log.e("APK_INSTALL", "No file path provided")
                            result.error("INVALID_PATH", "No file path provided", null)
                        }
                    } catch (e: Exception) {
                        Log.e("APK_INSTALL", "Error installing APK: ${e.message}", e)
                        result.error("INSTALLATION_ERROR", e.message, e.toString())
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestStoragePermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                ),
                STORAGE_PERMISSION_CODE
            )
        }
    }

    private fun requestNotificationPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(
                        Manifest.permission.POST_NOTIFICATIONS,
                        Manifest.permission.FOREGROUND_SERVICE,
                        Manifest.permission.WAKE_LOCK
                    ),
                    NOTIFICATION_PERMISSION_CODE
                )
            }
        }
    }

    private fun updateNotification(title: String, text: String) {
        try {
            val notificationManager = getSystemService(NotificationManager::class.java)
            println("Updating notification: $title - $text") 

            if (title.isEmpty() && text.isEmpty()) {
                notificationManager.cancel(1)
                return
            }

            val channelId = "raspberry_pi_control_channel"
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    notificationManager.deleteNotificationChannel(channelId)
                    
                    val channel = NotificationChannel(
                        channelId,
                        "Raspberry Pi Control",
                        NotificationManager.IMPORTANCE_HIGH
                    ).apply {
                        description = "SSH Connection Status"
                        setShowBadge(true)
                        enableLights(true)
                        enableVibration(true)
                    }
                    notificationManager.createNotificationChannel(channel)
                } catch (e: Exception) {
                    println("Error creating notification channel: $e")
                }
            }

            val disconnectIntent = Intent(this, MainActivity::class.java).apply {
                action = "DISCONNECT_ACTION"
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            
            val pendingIntent = PendingIntent.getActivity(
                this,
                0,
                disconnectIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val builder = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(com.lukas200301.raspberrypi_control.R.mipmap.ic_launcher) 
                .setContentTitle(title)
                .setContentText(text)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setAutoCancel(false)
                .setOngoing(true)
                .addAction(com.lukas200301.raspberrypi_control.R.mipmap.ic_launcher, "Disconnect", pendingIntent) 

            notificationManager.notify(1, builder.build())
            println("Notification posted successfully") 
        } catch (e: Exception) {
            println("Error showing notification: $e") 
        }
    }

    private fun installApk(filePath: String): Boolean {
        return try {
            Log.d("APK_INSTALL", "Starting APK installation from: $filePath")
            
            val file = File(filePath)
            if (!file.exists()) {
                Log.e("APK_INSTALL", "APK file does not exist at path: $filePath")
                return false
            }
            
            Log.d("APK_INSTALL", "APK file exists, size: ${file.length()} bytes")
            
            val apkUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                file
            )
            Log.d("APK_INSTALL", "Generated URI: $apkUri")
            
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(apkUri, "application/vnd.android.package-archive")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            
            startActivity(intent)
            
            Log.d("APK_INSTALL", "APK installation intent launched")
            true
        } catch (e: Exception) {
            Log.e("APK_INSTALL", "Error installing APK: ${e.message}", e)
            false
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent) 
        println("Received intent: ${intent.action}")

        if (intent.action == "DISCONNECT_ACTION") {
            println("Processing disconnect action")

            channel.invokeMethod("onDisconnect", null)

            getSystemService(NotificationManager::class.java).cancel(1)

            finishAffinity()
            System.exit(0)
        }
    }

    override fun onDestroy() { 
        super.onDestroy()
        println("App is being destroyed, removing notification.")
        getSystemService(NotificationManager::class.java).cancel(1)
    }

    private fun getResourceId(name: String, defType: String): Int {
        return resources.getIdentifier(name, defType, packageName)
    }
}
