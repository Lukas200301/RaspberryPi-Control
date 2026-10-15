import '../models/alerts.dart';
import 'device_probe.dart';

/// New device state plus the events a check produced
class AlertEvaluation {
  final DeviceAlertState state;
  final List<AlertEvent> events;

  const AlertEvaluation(this.state, this.events);
}

/// Turns one health check into alert events.
///
/// A condition alerts once when it starts and once when it ends (if it ends);
/// the [DeviceAlertState] carries what is currently active between checks.
AlertEvaluation evaluateAlerts({
  required String deviceId,
  required String deviceName,
  required DeviceAlertState previous,
  required ProbeResult result,
  required AlertRules rules,
}) {
  final now = result.time;
  final active = {...previous.active};
  final events = <AlertEvent>[];
  var seq = 0;

  AlertEvent event(AlertKind kind, AlertSeverity severity, String title, String message,
      {String subject = '', bool resolved = false}) {
    return AlertEvent(
      id: '${now.microsecondsSinceEpoch}-$deviceId-${seq++}',
      deviceId: deviceId,
      deviceName: deviceName,
      kind: kind,
      subject: subject,
      severity: severity,
      title: title,
      message: message,
      time: now,
      resolved: resolved,
    );
  }

  void raise(AlertKind kind, AlertSeverity severity, String title, String message, {String subject = ''}) {
    final e = event(kind, severity, title, message, subject: subject);
    if (active.containsKey(e.key)) return;
    active[e.key] = e;
    events.add(e);
  }

  void clear(String key, String message) {
    final started = active.remove(key);
    if (started == null) return;
    final s = started.subject;
    events.add(event(
      started.kind,
      AlertSeverity.info,
      switch (started.kind) {
        AlertKind.offline => '$deviceName is back online',
        AlertKind.load => 'CPU load is normal again on $deviceName',
        AlertKind.memory => 'Memory is fine again on $deviceName',
        AlertKind.disk => 'Disk space is fine again on $deviceName',
        AlertKind.temperature => '$deviceName cooled down',
        AlertKind.service => '$s recovered on $deviceName',
        AlertKind.pm2 => 'PM2 app $s recovered on $deviceName',
        AlertKind.container => 'Container $s recovered on $deviceName',
        AlertKind.reboot => started.title,
      },
      message,
      subject: started.subject,
      resolved: true,
    ));
  }

  // Conditions whose rule was switched off end silently
  active.removeWhere((_, e) => !rules.isEnabled(e.kind));

  // ---- Reachability
  if (!result.reachable) {
    final failures = previous.failures + 1;
    if (rules.offline && failures >= rules.offlineChecks) {
      raise(AlertKind.offline, AlertSeverity.critical, '$deviceName is offline',
          'SSH did not answer $failures checks in a row.');
    }
    // Other conditions keep their state until the device answers again
    return AlertEvaluation(previous.copyWith(failures: failures, active: active, lastCheck: now), events);
  }
  clear(AlertKind.offline.name, '$deviceName is reachable again.');

  final snap = result.snapshot;
  if (snap == null) {
    // Port open but no data (e.g. login failed): nothing else to judge
    return AlertEvaluation(previous.copyWith(failures: 0, active: active, lastCheck: now), events);
  }

  // ---- Thresholds, with a little hysteresis so values near the line don't flap
  void threshold(AlertKind kind, bool enabled, double value, int limit, double margin, String Function(double) describe,
      {required String title, AlertSeverity Function(double)? severity}) {
    if (!enabled) return;
    if (value >= limit) {
      raise(kind, severity?.call(value) ?? AlertSeverity.warning, title, describe(value));
    } else if (value < limit - margin) {
      clear(kind.name, describe(value));
    }
  }

  threshold(AlertKind.load, rules.load, snap.loadPercent, rules.loadPercent, 10,
      (v) => 'Load ${snap.load1.toStringAsFixed(2)} on ${snap.cpus} cores (${v.round()}%).',
      title: 'High CPU load on $deviceName');
  if (snap.memTotalKb > 0) {
    threshold(AlertKind.memory, rules.memory, snap.memPercent, rules.memoryPercent, 5,
        (v) => 'Memory ${v.round()}% used.',
        title: 'Memory almost full on $deviceName',
        severity: (v) => v >= 97 ? AlertSeverity.critical : AlertSeverity.warning);
  }
  if (snap.diskTotalKb > 0) {
    threshold(AlertKind.disk, rules.disk, snap.diskPercent, rules.diskPercent, 3,
        (v) => 'Root file system ${v.round()}% full.',
        title: 'Disk almost full on $deviceName',
        severity: (v) => v >= 98 ? AlertSeverity.critical : AlertSeverity.warning);
  }
  if (snap.hasTemp) {
    threshold(AlertKind.temperature, rules.temperature, snap.tempC, rules.temperatureC, 5,
        (v) => 'CPU at ${v.toStringAsFixed(1)} °C.',
        title: '$deviceName is running hot',
        severity: (v) => v >= rules.temperatureC + 5 ? AlertSeverity.critical : AlertSeverity.warning);
  }

  // ---- Named things: each unit, app or container alerts on its own
  void named(AlertKind kind, bool enabled, Map<String, String> bad, String Function(String, String) title,
      String Function(String, String) message, String Function(String) resolved, {bool known = true}) {
    if (!enabled || !known) return;
    for (final entry in bad.entries) {
      raise(kind, AlertSeverity.critical, title(entry.key, entry.value), message(entry.key, entry.value),
          subject: entry.key);
    }
    for (final key in active.keys.where((k) => k.startsWith('${kind.name}:')).toList()) {
      final subject = key.substring(kind.name.length + 1);
      if (!bad.containsKey(subject)) clear(key, resolved(subject));
    }
  }

  named(
    AlertKind.service,
    rules.services,
    {for (final u in snap.failedUnits) u: 'failed'},
    (u, _) => '$u failed on $deviceName',
    (u, _) => 'The systemd unit $u is in the failed state.',
    (u) => '$u is no longer failed.',
  );

  final pm2 = snap.pm2;
  named(
    AlertKind.pm2,
    rules.pm2,
    {for (final e in (pm2 ?? const <String, String>{}).entries) if (e.value == 'errored') e.key: e.value},
    (n, _) => 'PM2 app $n crashed on $deviceName',
    (n, s) => 'PM2 gave up restarting $n (status: $s).',
    (n) => '$n is no longer errored.',
    known: pm2 != null,
  );

  final containers = snap.containers;
  var running = previous.runningContainers;
  if (containers != null) {
    running = {for (final e in containers.entries) if (e.value == 'running') e.key};
    named(
      AlertKind.container,
      rules.containers,
      {
        for (final e in containers.entries)
          if (e.value == 'restarting' || e.value == 'dead' || e.value == 'unhealthy' ||
              // Only a container that was running counts as having stopped
              (e.value == 'exited' && previous.runningContainers.contains(e.key)) ||
              (e.value == 'exited' && active.containsKey('${AlertKind.container.name}:${e.key}')))
            e.key: e.value,
      },
      (n, s) => 'Container $n is $s on $deviceName',
      (n, s) => s == 'exited' ? 'The container $n stopped.' : 'The container $n is $s.',
      (n) => '$n is fine again.',
    );
  }

  // ---- Reboot: uptime went backwards
  if (rules.reboot && previous.lastUptime > 0 && snap.uptimeSeconds > 0 && snap.uptimeSeconds < previous.lastUptime) {
    events.add(event(AlertKind.reboot, AlertSeverity.info, '$deviceName restarted',
        'Up for ${_short(snap.uptimeSeconds)} after ${_short(previous.lastUptime)} before.'));
  }

  return AlertEvaluation(
    DeviceAlertState(
      failures: 0,
      active: active,
      lastUptime: snap.uptimeSeconds > 0 ? snap.uptimeSeconds : previous.lastUptime,
      lastCheck: now,
      runningContainers: running,
    ),
    events,
  );
}

String _short(int seconds) {
  final d = Duration(seconds: seconds);
  if (d.inDays > 0) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
  if (d.inMinutes > 0) return '${d.inMinutes} min';
  return '${d.inSeconds} s';
}
