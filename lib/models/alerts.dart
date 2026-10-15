/// Alert rules, alert events and the per-device state the evaluator keeps.
library;

import 'package:flutter/foundation.dart';

enum AlertKind {
  offline('Offline'),
  load('High CPU load'),
  memory('Memory'),
  disk('Disk space'),
  temperature('Temperature'),
  service('Failed service'),
  pm2('PM2 app'),
  container('Docker container'),
  reboot('Reboot');

  final String label;

  const AlertKind(this.label);

  static AlertKind byName(String? name) =>
      AlertKind.values.firstWhere((k) => k.name == name, orElse: () => AlertKind.offline);
}

enum AlertSeverity {
  info,
  warning,
  critical;

  static AlertSeverity byName(String? name) =>
      AlertSeverity.values.firstWhere((s) => s.name == name, orElse: () => AlertSeverity.warning);
}

/// What to watch and how to tell the user
@immutable
class AlertRules {
  final bool enabled;
  final bool systemNotifications;
  final bool notifyResolved;

  /// Keep checking while the app is closed (Android)
  final bool background;
  final int backgroundMinutes;

  /// Check interval while the app is open
  final int foregroundSeconds;

  final bool offline;

  /// Failed checks in a row before a device counts as offline
  final int offlineChecks;
  final bool load;
  final int loadPercent;
  final bool memory;
  final int memoryPercent;
  final bool disk;
  final int diskPercent;
  final bool temperature;
  final int temperatureC;
  final bool services;
  final bool pm2;
  final bool containers;
  final bool reboot;

  /// Devices that are never checked
  final Set<String> mutedDevices;

  const AlertRules({
    this.enabled = false,
    this.systemNotifications = true,
    this.notifyResolved = true,
    this.background = false,
    this.backgroundMinutes = 15,
    this.foregroundSeconds = 60,
    this.offline = true,
    this.offlineChecks = 2,
    this.load = true,
    this.loadPercent = 90,
    this.memory = true,
    this.memoryPercent = 90,
    this.disk = true,
    this.diskPercent = 90,
    this.temperature = true,
    this.temperatureC = 80,
    this.services = true,
    this.pm2 = true,
    this.containers = true,
    this.reboot = true,
    this.mutedDevices = const {},
  });

  bool isEnabled(AlertKind kind) => switch (kind) {
    AlertKind.offline => offline,
    AlertKind.load => load,
    AlertKind.memory => memory,
    AlertKind.disk => disk,
    AlertKind.temperature => temperature,
    AlertKind.service => services,
    AlertKind.pm2 => pm2,
    AlertKind.container => containers,
    AlertKind.reboot => reboot,
  };

  bool monitors(String deviceId) => enabled && !mutedDevices.contains(deviceId);

  AlertRules copyWith({
    bool? enabled,
    bool? systemNotifications,
    bool? notifyResolved,
    bool? background,
    int? backgroundMinutes,
    int? foregroundSeconds,
    bool? offline,
    int? offlineChecks,
    bool? load,
    int? loadPercent,
    bool? memory,
    int? memoryPercent,
    bool? disk,
    int? diskPercent,
    bool? temperature,
    int? temperatureC,
    bool? services,
    bool? pm2,
    bool? containers,
    bool? reboot,
    Set<String>? mutedDevices,
  }) {
    return AlertRules(
      enabled: enabled ?? this.enabled,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      notifyResolved: notifyResolved ?? this.notifyResolved,
      background: background ?? this.background,
      backgroundMinutes: backgroundMinutes ?? this.backgroundMinutes,
      foregroundSeconds: foregroundSeconds ?? this.foregroundSeconds,
      offline: offline ?? this.offline,
      offlineChecks: offlineChecks ?? this.offlineChecks,
      load: load ?? this.load,
      loadPercent: loadPercent ?? this.loadPercent,
      memory: memory ?? this.memory,
      memoryPercent: memoryPercent ?? this.memoryPercent,
      disk: disk ?? this.disk,
      diskPercent: diskPercent ?? this.diskPercent,
      temperature: temperature ?? this.temperature,
      temperatureC: temperatureC ?? this.temperatureC,
      services: services ?? this.services,
      pm2: pm2 ?? this.pm2,
      containers: containers ?? this.containers,
      reboot: reboot ?? this.reboot,
      mutedDevices: mutedDevices ?? this.mutedDevices,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'systemNotifications': systemNotifications,
    'notifyResolved': notifyResolved,
    'background': background,
    'backgroundMinutes': backgroundMinutes,
    'foregroundSeconds': foregroundSeconds,
    'offline': offline,
    'offlineChecks': offlineChecks,
    'load': load,
    'loadPercent': loadPercent,
    'memory': memory,
    'memoryPercent': memoryPercent,
    'disk': disk,
    'diskPercent': diskPercent,
    'temperature': temperature,
    'temperatureC': temperatureC,
    'services': services,
    'pm2': pm2,
    'containers': containers,
    'reboot': reboot,
    'mutedDevices': mutedDevices.toList(),
  };

  factory AlertRules.fromJson(Map<String, dynamic> j) {
    const d = AlertRules();
    bool b(String k, bool fallback) => j[k] is bool ? j[k] as bool : fallback;
    int n(String k, int fallback) => j[k] is num ? (j[k] as num).toInt() : fallback;
    return AlertRules(
      enabled: b('enabled', d.enabled),
      systemNotifications: b('systemNotifications', d.systemNotifications),
      notifyResolved: b('notifyResolved', d.notifyResolved),
      background: b('background', d.background),
      backgroundMinutes: n('backgroundMinutes', d.backgroundMinutes).clamp(5, 240),
      foregroundSeconds: n('foregroundSeconds', d.foregroundSeconds).clamp(15, 3600),
      offline: b('offline', d.offline),
      offlineChecks: n('offlineChecks', d.offlineChecks).clamp(1, 10),
      load: b('load', d.load),
      loadPercent: n('loadPercent', d.loadPercent).clamp(10, 400),
      memory: b('memory', d.memory),
      memoryPercent: n('memoryPercent', d.memoryPercent).clamp(10, 100),
      disk: b('disk', d.disk),
      diskPercent: n('diskPercent', d.diskPercent).clamp(10, 100),
      temperature: b('temperature', d.temperature),
      temperatureC: n('temperatureC', d.temperatureC).clamp(30, 110),
      services: b('services', d.services),
      pm2: b('pm2', d.pm2),
      containers: b('containers', d.containers),
      reboot: b('reboot', d.reboot),
      mutedDevices: {...?(j['mutedDevices'] as List?)?.whereType<String>()},
    );
  }
}

/// Something that happened on a device: a problem started, or ended
@immutable
class AlertEvent {
  final String id;
  final String deviceId;
  final String deviceName;
  final AlertKind kind;

  /// What the alert is about within its kind, e.g. a unit or app name
  final String subject;
  final AlertSeverity severity;
  final String title;
  final String message;
  final DateTime time;

  /// This event ends an earlier alert
  final bool resolved;
  final bool read;

  const AlertEvent({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.kind,
    this.subject = '',
    required this.severity,
    required this.title,
    required this.message,
    required this.time,
    this.resolved = false,
    this.read = false,
  });

  /// Identifies the condition, so a condition alerts once until it clears
  String get key => subject.isEmpty ? kind.name : '${kind.name}:$subject';

  AlertEvent copyWith({bool? read}) => AlertEvent(
    id: id,
    deviceId: deviceId,
    deviceName: deviceName,
    kind: kind,
    subject: subject,
    severity: severity,
    title: title,
    message: message,
    time: time,
    resolved: resolved,
    read: read ?? this.read,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'kind': kind.name,
    'subject': subject,
    'severity': severity.name,
    'title': title,
    'message': message,
    'time': time.toIso8601String(),
    'resolved': resolved,
    'read': read,
  };

  factory AlertEvent.fromJson(Map<String, dynamic> j) => AlertEvent(
    id: j['id'] as String? ?? '',
    deviceId: j['deviceId'] as String? ?? '',
    deviceName: j['deviceName'] as String? ?? '',
    kind: AlertKind.byName(j['kind'] as String?),
    subject: j['subject'] as String? ?? '',
    severity: AlertSeverity.byName(j['severity'] as String?),
    title: j['title'] as String? ?? '',
    message: j['message'] as String? ?? '',
    time: DateTime.tryParse(j['time'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    resolved: j['resolved'] as bool? ?? false,
    read: j['read'] as bool? ?? false,
  );
}

/// What the evaluator remembers about a device between checks
@immutable
class DeviceAlertState {
  final int failures;

  /// Alerts that have started and not ended, by [AlertEvent.key]
  final Map<String, AlertEvent> active;
  final int lastUptime;
  final DateTime? lastCheck;

  /// Containers seen running at the last check, to notice ones that stop
  final Set<String> runningContainers;

  const DeviceAlertState({
    this.failures = 0,
    this.active = const {},
    this.lastUptime = 0,
    this.lastCheck,
    this.runningContainers = const {},
  });

  DeviceAlertState copyWith({
    int? failures,
    Map<String, AlertEvent>? active,
    int? lastUptime,
    DateTime? lastCheck,
    Set<String>? runningContainers,
  }) => DeviceAlertState(
    failures: failures ?? this.failures,
    active: active ?? this.active,
    lastUptime: lastUptime ?? this.lastUptime,
    lastCheck: lastCheck ?? this.lastCheck,
    runningContainers: runningContainers ?? this.runningContainers,
  );

  Map<String, dynamic> toJson() => {
    'failures': failures,
    'active': {for (final e in active.entries) e.key: e.value.toJson()},
    'lastUptime': lastUptime,
    'lastCheck': lastCheck?.toIso8601String(),
    'runningContainers': runningContainers.toList(),
  };

  factory DeviceAlertState.fromJson(Map<String, dynamic> j) => DeviceAlertState(
    failures: (j['failures'] as num?)?.toInt() ?? 0,
    active: {
      for (final e in ((j['active'] as Map?) ?? const {}).entries)
        if (e.value is Map) e.key as String: AlertEvent.fromJson(Map<String, dynamic>.from(e.value as Map)),
    },
    lastUptime: (j['lastUptime'] as num?)?.toInt() ?? 0,
    lastCheck: DateTime.tryParse(j['lastCheck'] as String? ?? ''),
    runningContainers: {...?(j['runningContainers'] as List?)?.whereType<String>()},
  );
}
