import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ssh_connection.dart';
import '../providers/app_providers.dart';
import 'alert_center.dart';
import 'ssh_service.dart';

/// A quick health snapshot of a device, taken over a short SSH session
@immutable
class DeviceSnapshot {
  final double load1;
  final int cpus;
  final int memTotalKb;
  final int memAvailableKb;
  final double tempC;
  final int uptimeSeconds;
  final int diskUsedKb;
  final int diskTotalKb;
  final String hostname;
  final String os;
  final String model;

  /// systemd units in the failed state
  final List<String> failedUnits;

  /// PM2 app name -> status; null when PM2 is not running for the user
  final Map<String, String>? pm2;

  /// Container name -> state ("running", "exited", "unhealthy", ...);
  /// null when Docker is missing or not accessible
  final Map<String, String>? containers;

  const DeviceSnapshot({
    this.load1 = 0,
    this.cpus = 1,
    this.memTotalKb = 0,
    this.memAvailableKb = 0,
    this.tempC = 0,
    this.uptimeSeconds = 0,
    this.diskUsedKb = 0,
    this.diskTotalKb = 0,
    this.hostname = '',
    this.os = '',
    this.model = '',
    this.failedUnits = const [],
    this.pm2,
    this.containers,
  });

  /// Load relative to the number of cores, in percent
  double get loadPercent => cpus <= 0 ? 0 : (load1 / cpus * 100).clamp(0, 999);
  double get memPercent =>
      memTotalKb <= 0 ? 0 : (memTotalKb - memAvailableKb) / memTotalKb * 100;
  double get diskPercent => diskTotalKb <= 0 ? 0 : diskUsedKb / diskTotalKb * 100;
  bool get hasTemp => tempC > 0;

  static const command = r'''
echo "LOAD $(cut -d' ' -f1 /proc/loadavg)"
echo "CPUS $(nproc 2>/dev/null || echo 1)"
grep -E '^(MemTotal|MemAvailable):' /proc/meminfo
echo "TEMP $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)"
echo "UPTIME $(cut -d. -f1 /proc/uptime)"
echo "DISK $(df -Pk / | tail -1)"
echo "HOST $(hostname)"
echo "OS $(. /etc/os-release 2>/dev/null; echo "$PRETTY_NAME")"
echo "MODEL $(tr -d '\0' < /proc/device-tree/model 2>/dev/null)"
command -v systemctl >/dev/null 2>&1 && systemctl --failed --no-legend --plain 2>/dev/null | awk 'NF {print "FAILED " $1}'
P=""
for c in "$(command -v pm2 2>/dev/null)" "$HOME"/.nvm/versions/node/*/bin/pm2 /usr/local/bin/pm2 /usr/bin/pm2; do
  if [ -n "$c" ] && [ -x "$c" ]; then P="$c"; break; fi
done
# Only ask a PM2 daemon that already runs; `pm2 jlist` would start one
if [ -n "$P" ] && [ -S "${PM2_HOME:-$HOME/.pm2}/rpc.sock" ]; then
  PATH="$(dirname "$P"):$PATH" "$P" jlist 2>/dev/null | PATH="$(dirname "$P"):$PATH" node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const l=s.split("\n").filter(x=>x.startsWith("["));try{for(const p of JSON.parse(l[l.length-1]))console.log("PM2 "+p.pm2_env.status+" "+p.name)}catch(e){}console.log("PM2_OK")})' 2>/dev/null
fi
if command -v docker >/dev/null 2>&1 && docker ps -a --format 'DOCKER {{.State}}|{{.Status}}|{{.Names}}' 2>/dev/null; then echo "DOCKER_OK"; fi
''';

  factory DeviceSnapshot.parse(String output) {
    final v = <String, String>{};
    final failed = <String>[];
    final pm2 = <String, String>{};
    final containers = <String, String>{};
    var pm2Ok = false, dockerOk = false;
    for (final line in LineSplitter.split(output)) {
      if (line == 'PM2_OK') pm2Ok = true;
      if (line == 'DOCKER_OK') dockerOk = true;
      final i = line.indexOf(' ');
      if (i <= 0) continue;
      final key = line.substring(0, i);
      final value = line.substring(i + 1).trim();
      switch (key) {
        case 'FAILED':
          failed.add(value);
        case 'PM2':
          final j = value.indexOf(' ');
          if (j > 0) pm2[value.substring(j + 1)] = value.substring(0, j);
        case 'DOCKER':
          final parts = value.split('|');
          if (parts.length >= 3) {
            containers[parts.sublist(2).join('|')] = parts[1].contains('(unhealthy)') ? 'unhealthy' : parts[0];
          }
        default:
          v[key] = value;
      }
    }
    int i(String k) => int.tryParse(v[k]?.split(RegExp(r'\s+')).first ?? '') ?? 0;
    // df: device total used available use% mount
    final disk = (v['DISK'] ?? '').split(RegExp(r'\s+'));
    final temp = double.tryParse(v['TEMP'] ?? '') ?? 0;
    return DeviceSnapshot(
      load1: double.tryParse(v['LOAD'] ?? '') ?? 0,
      cpus: i('CPUS').clamp(1, 1024),
      memTotalKb: i('MemTotal:'),
      memAvailableKb: i('MemAvailable:'),
      // The kernel reports millidegrees
      tempC: temp > 1000 ? temp / 1000 : temp,
      uptimeSeconds: i('UPTIME'),
      diskUsedKb: disk.length > 2 ? int.tryParse(disk[2]) ?? 0 : 0,
      diskTotalKb: disk.length > 1 ? int.tryParse(disk[1]) ?? 0 : 0,
      hostname: v['HOST'] ?? '',
      os: v['OS'] ?? '',
      model: v['MODEL'] ?? '',
      failedUnits: failed,
      pm2: pm2Ok ? pm2 : null,
      containers: dockerOk ? containers : null,
    );
  }
}

/// Result of one health check
@immutable
class ProbeResult {
  final bool reachable;
  final int? latencyMs;
  final DeviceSnapshot? snapshot;
  final String? error;
  final DateTime time;

  const ProbeResult({required this.reachable, this.latencyMs, this.snapshot, this.error, required this.time});
}

/// Checks the SSH port, then takes a [DeviceSnapshot] over a short session
Future<ProbeResult> probeDevice(SSHConnection device) async {
  final watch = Stopwatch()..start();
  try {
    final socket = await Socket.connect(device.host, device.port, timeout: const Duration(seconds: 3));
    socket.destroy();
  } catch (_) {
    return ProbeResult(reachable: false, time: DateTime.now());
  }
  final latency = watch.elapsedMilliseconds;
  try {
    final client = await SSHService.openClient(device, timeout: const Duration(seconds: 8), keepAliveInterval: null);
    try {
      final out = utf8.decode(await client.run(DeviceSnapshot.command).timeout(const Duration(seconds: 12)));
      return ProbeResult(reachable: true, latencyMs: latency, snapshot: DeviceSnapshot.parse(out), time: DateTime.now());
    } finally {
      client.close();
    }
  } catch (e) {
    final text = e.toString().toLowerCase();
    return ProbeResult(
      reachable: true,
      latencyMs: latency,
      error: text.contains('auth') ? 'Login failed' : 'No details',
      time: DateTime.now(),
    );
  }
}

enum Reachability { unknown, checking, online, offline }

@immutable
class DeviceStatus {
  final Reachability reachability;
  final int? latencyMs;
  final DeviceSnapshot? snapshot;
  final String? error;
  final DateTime? checkedAt;

  const DeviceStatus({
    this.reachability = Reachability.unknown,
    this.latencyMs,
    this.snapshot,
    this.error,
    this.checkedAt,
  });

  DeviceStatus copyWith({
    Reachability? reachability,
    int? latencyMs,
    DeviceSnapshot? snapshot,
    String? error,
    bool clearError = false,
    DateTime? checkedAt,
  }) {
    return DeviceStatus(
      reachability: reachability ?? this.reachability,
      latencyMs: latencyMs ?? this.latencyMs,
      snapshot: snapshot ?? this.snapshot,
      error: clearError ? null : (error ?? this.error),
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}

/// Status of every saved device, refreshed while someone watches it
final deviceStatusProvider =
    NotifierProvider.autoDispose<DeviceStatusNotifier, Map<String, DeviceStatus>>(
      DeviceStatusNotifier.new,
    );

class DeviceStatusNotifier extends AutoDisposeNotifier<Map<String, DeviceStatus>> {
  static const _interval = Duration(seconds: 30);
  static const _parallel = 3;

  Timer? _timer;
  bool _running = false;

  @override
  Map<String, DeviceStatus> build() {
    _timer = Timer.periodic(_interval, (_) => refreshAll());
    ref.onDispose(() => _timer?.cancel());
    // Re-check when devices are added or edited
    ref.listen(connectionListProvider, (_, _) => refreshAll());
    Future.microtask(refreshAll);
    return {};
  }

  Future<void> refreshAll() async {
    if (_running) return;
    _running = true;
    try {
      final devices = [...ref.read(connectionListProvider)];
      final current = ref.read(currentConnectionProvider)?.id;
      final queue = devices.where((d) => d.id != current).toList();
      final workers = [
        for (var w = 0; w < _parallel; w++)
          () async {
            while (queue.isNotEmpty) {
              await refresh(queue.removeAt(0));
            }
          }(),
      ];
      await Future.wait(workers);
    } finally {
      _running = false;
    }
  }

  void _put(String id, DeviceStatus status) => state = {...state, id: status};

  Future<void> refresh(SSHConnection device) async {
    final previous = state[device.id] ?? const DeviceStatus();
    _put(device.id, previous.copyWith(reachability: Reachability.checking));
    final result = await probeDevice(device);
    if (!result.reachable) {
      _put(device.id, previous.copyWith(reachability: Reachability.offline, checkedAt: result.time, clearError: true));
    } else {
      _put(
        device.id,
        previous.copyWith(
          reachability: Reachability.online,
          latencyMs: result.latencyMs,
          checkedAt: result.time,
          snapshot: result.snapshot,
          error: result.error,
          clearError: result.error == null,
        ),
      );
    }
    // Every check also feeds the alerts, so devices are not probed twice
    ref.read(alertCenterProvider.notifier).ingest(device, result);
  }
}
