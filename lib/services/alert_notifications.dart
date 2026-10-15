import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alerts.dart';

/// System notifications for alerts, shared by the app and the background service
class AlertNotifications {
  static const alertChannel = 'alerts';
  static const monitorChannel = 'monitor';
  static const monitorNotificationId = 4711;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows);

  static Future<void> init() async {
    if (_ready || !supported) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_pi'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
          windows: WindowsInitializationSettings(
            appName: 'Raspberry Pi Control',
            appUserModelId: 'Lukas200301.RaspberryPiControl',
            guid: '5d3c6a8e-0f4b-4d55-9a3e-7c1b2e9f4a61',
          ),
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          alertChannel,
          'Alerts',
          description: 'Problems on your devices: offline, overheating, failed services',
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          monitorChannel,
          'Background monitoring',
          description: 'Shown while devices are watched in the background',
          importance: Importance.low,
          showBadge: false,
        ),
      );
      _ready = true;
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  /// Asks for permission where the platform needs it; true when allowed
  static Future<bool> requestPermission() async {
    await init();
    if (!_ready) return false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    if (Platform.isMacOS) {
      final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      return await mac?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  static Future<void> show(AlertEvent event) async {
    await init();
    if (!_ready) return;
    final color = switch (event.severity) {
      _ when event.resolved => const Color(0xFF22C55E),
      AlertSeverity.critical => const Color(0xFFEF4444),
      AlertSeverity.warning => const Color(0xFFF59E0B),
      AlertSeverity.info => const Color(0xFF3B82F6),
    };
    try {
      await _plugin.show(
        // One notification per condition: a resolve replaces its alert
        id: '${event.deviceId}/${event.key}'.hashCode & 0x3fffffff,
        title: event.title,
        body: event.message,
        payload: event.deviceId,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            alertChannel,
            'Alerts',
            importance: event.resolved ? Importance.defaultImportance : Importance.high,
            priority: event.resolved ? Priority.defaultPriority : Priority.high,
            color: color,
            category: AndroidNotificationCategory.status,
            groupKey: 'alerts',
            styleInformation: BigTextStyleInformation(event.message),
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Notification failed: $e');
    }
  }
}
