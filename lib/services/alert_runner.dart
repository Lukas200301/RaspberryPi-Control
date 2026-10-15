import '../models/alerts.dart';
import '../models/ssh_connection.dart';
import 'alert_engine.dart';
import 'alert_notifications.dart';
import 'alert_store.dart';
import 'device_probe.dart';

/// Probes devices, evaluates the results and tells the user
class AlertRunner {
  static const _parallel = 3;

  /// Records one check of [device]; returns the stored data afterwards
  static Future<AlertData> process(SSHConnection device, ProbeResult result) async {
    var events = const <AlertEvent>[];
    final data = await AlertStore.update((data) {
      if (!data.rules.monitors(device.id)) return data;
      final evaluation = evaluateAlerts(
        deviceId: device.id,
        deviceName: device.name,
        previous: data.devices[device.id] ?? const DeviceAlertState(),
        result: result,
        rules: data.rules,
      );
      events = evaluation.events;
      return data.copyWith(
        devices: {...data.devices, device.id: evaluation.state},
        history: [...evaluation.events.reversed, ...data.history],
      );
    });
    if (data.rules.systemNotifications) {
      for (final e in events) {
        if (!e.resolved || data.rules.notifyResolved) await AlertNotifications.show(e);
      }
    }
    return data;
  }

  /// Checks every monitored device whose last check is older than [interval]
  static Future<void> checkDue(List<SSHConnection> devices, Duration interval) async {
    final data = await AlertStore.read();
    if (!data.rules.enabled) return;
    final now = DateTime.now();
    final queue = devices.where((d) {
      if (!data.rules.monitors(d.id)) return false;
      final last = data.devices[d.id]?.lastCheck;
      return last == null || now.difference(last) >= interval;
    }).toList();
    await Future.wait([
      for (var w = 0; w < _parallel; w++)
        () async {
          while (queue.isNotEmpty) {
            final device = queue.removeAt(0);
            await process(device, await probeDevice(device));
          }
        }(),
    ]);
  }
}
