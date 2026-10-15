import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import '../models/alerts.dart';
import 'alert_notifications.dart';
import 'alert_runner.dart';
import 'alert_store.dart';

/// Keeps checking devices while the app is closed (Android foreground service)
class BackgroundMonitor {
  static bool get supported => !kIsWeb && Platform.isAndroid;

  /// Starts, refreshes or stops the service to match [rules]
  static Future<void> apply(AlertRules rules) async {
    if (!supported) return;
    try {
      final service = FlutterBackgroundService();
      final wanted = rules.enabled && rules.background;
      final running = await service.isRunning();
      if (!wanted) {
        if (running) service.invoke('stop');
        return;
      }
      if (running) {
        service.invoke('refresh');
        return;
      }
      await AlertNotifications.init();
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: backgroundMonitorMain,
          autoStart: false,
          autoStartOnBoot: true,
          isForegroundMode: true,
          notificationChannelId: AlertNotifications.monitorChannel,
          initialNotificationTitle: 'Watching your devices',
          initialNotificationContent: 'Starting…',
          foregroundServiceNotificationId: AlertNotifications.monitorNotificationId,
          foregroundServiceTypes: [AndroidForegroundType.specialUse],
        ),
        iosConfiguration: IosConfiguration(autoStart: false),
      );
      await service.startService();
    } catch (e) {
      debugPrint('Background monitor: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> backgroundMonitorMain(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await AlertNotifications.init();

  Timer? timer;
  var busy = false;
  service.on('stop').listen((_) {
    timer?.cancel();
    service.stopSelf();
  });

  Future<void> tick() async {
    if (busy) return;
    busy = true;
    try {
      final data = await AlertStore.read();
      if (!data.rules.enabled || !data.rules.background) {
        timer?.cancel();
        await service.stopSelf();
        return;
      }
      final devices = (await AlertStore.readDevices()).where((d) => data.rules.monitors(d.id)).toList();
      // A little slack, so a check that ran a few seconds early is not skipped
      await AlertRunner.checkDue(
        devices,
        Duration(minutes: data.rules.backgroundMinutes) - const Duration(seconds: 30),
      );
      final after = await AlertStore.read();
      final active = after.devices.entries
          .where((e) => devices.any((d) => d.id == e.key))
          .fold<int>(0, (n, e) => n + e.value.active.length);
      if (service is AndroidServiceInstance) {
        await service.setForegroundNotificationInfo(
          title: 'Watching ${devices.length} ${devices.length == 1 ? 'device' : 'devices'}',
          content: [
            active == 0 ? 'All good' : '$active active ${active == 1 ? 'alert' : 'alerts'}',
            'checked ${DateFormat.Hm().format(DateTime.now())}',
            'every ${data.rules.backgroundMinutes} min',
          ].join(' · '),
        );
      }
    } catch (e) {
      debugPrint('Background check failed: $e');
    } finally {
      busy = false;
    }
  }

  service.on('refresh').listen((_) => tick());
  // Ticks are cheap: only devices that are due get probed
  timer = Timer.periodic(const Duration(minutes: 1), (_) => tick());
  await tick();
}
