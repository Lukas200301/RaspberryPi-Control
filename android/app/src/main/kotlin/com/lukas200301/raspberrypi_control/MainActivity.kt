package com.lukas200301.raspberrypi_control

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth for the biometric prompt
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Lets Dart keep the connection alive while the app is in the background
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pi_control/session").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "update" -> {
                        SessionService.update(
                            applicationContext,
                            call.argument<String>("title") ?: "Connected",
                            call.argument<String>("text") ?: "",
                            call.argument<Int>("progress") ?: SessionService.NO_PROGRESS,
                        )
                        result.success(null)
                    }
                    "stop" -> {
                        SessionService.stop(applicationContext)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                // e.g. starting a foreground service is not allowed right now
                result.error("transfer_service", e.message, null)
            }
        }
    }
}
