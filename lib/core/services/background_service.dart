import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:android_intent_plus/android_intent.dart';

/// Background Service for Android
/// Extracted from main.dart for better organization
class BackgroundService extends GetxService {
  static BackgroundService get to => Get.find();

  bool _initialized = false;
  bool _isEnabled = false;

  final _platform = const MethodChannel('com.lukas200301.raspberrypi_control');

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _initialized;

  /// Initialize background service (Android only)
  Future<BackgroundService> init() async {
    if (_initialized) return this;

    try {
      if (Platform.isAndroid) {
        const androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: "Raspberry Pi Control",
          notificationText: "Running in background",
          notificationImportance: AndroidNotificationImportance.normal,
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWifiLock: true,
        );

        try {
          await _platform.invokeMethod('requestNotificationPermissions');
        } catch (e) {
          print('⚠️ Failed to request notifications permission: $e');
        }

        try {
          final initialized = await FlutterBackground.initialize(androidConfig: androidConfig);
          if (!initialized) {
            throw Exception('Failed to initialize FlutterBackground');
          }

          if (!await FlutterBackground.hasPermissions) {
            final intent = AndroidIntent(
              action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
              data: 'package:com.lukas200301.raspberrypi_control',
            );
            await intent.launch();
          }
        } catch (e) {
          print('⚠️ Failed to initialize FlutterBackground: $e');
        }
      } else {
        print('ℹ️ Background services not supported on this platform, skipping initialization');
      }

      _initialized = true;
      return this;
    } catch (e) {
      print('❌ Failed to initialize background service: $e');
      _initialized = false;
      rethrow;
    }
  }

  /// Enable background execution
  Future<void> enableBackground() async {
    print("🔄 Enabling background service...");

    if (!_initialized) {
      await init();
    }

    if (Platform.isAndroid) {
      try {
        if (await FlutterBackground.hasPermissions) {
          await FlutterBackground.enableBackgroundExecution();
          _isEnabled = true;
          print("✅ Background service enabled");

          await Future.delayed(const Duration(milliseconds: 500));
          await _platform.invokeMethod('updateNotification', {
            'title': 'Raspberry Pi Control',
            'text': 'Connected and running in background'
          });
        } else {
          print("⚠️ No background permissions");
          throw Exception('Background permissions not granted');
        }
      } catch (e) {
        print("❌ Error in enableBackground: $e");
      }
    } else {
      print("ℹ️ Background services not supported on this platform, skipping");
      _isEnabled = false;
    }
  }

  /// Disable background execution
  Future<void> disableBackground() async {
    if (_isEnabled) {
      _isEnabled = false;

      if (Platform.isAndroid) {
        try {
          await _platform.invokeMethod('updateNotification', {
            'title': '',
            'text': '',
            'clear': true
          });
          await FlutterBackground.disableBackgroundExecution();
          print("✅ Background service disabled");
        } catch (e) {
          print('❌ Error disabling background service: $e');
        }
      } else {
        print('ℹ️ Background services not supported on this platform, nothing to disable');
      }
    }
  }

  @override
  void onClose() {
    disableBackground();
    super.onClose();
  }
}
