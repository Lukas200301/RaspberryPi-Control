import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alerts.dart';
import '../models/ssh_connection.dart';
import '../providers/app_providers.dart';
import 'alert_runner.dart';
import 'alert_store.dart';
import 'background_monitor.dart';
import 'device_probe.dart';

/// Alerts while the app runs: checks devices on a timer, takes in checks the
/// Devices screen makes anyway, and picks up what the background service found
final alertCenterProvider = NotifierProvider<AlertCenter, AlertData>(AlertCenter.new);

class AlertCenter extends Notifier<AlertData> {
  /// Loaded in main() so the first frame already knows the rules
  static AlertData preloaded = const AlertData();

  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _checking = false;

  @override
  AlertData build() {
    _lifecycle = AppLifecycleListener(onResume: reload);
    ref.onDispose(() {
      _timer?.cancel();
      _lifecycle?.dispose();
    });
    _schedule(preloaded.rules);
    return preloaded;
  }

  AlertRules get rules => state.rules;

  int get unread => state.history.where((e) => !e.read).length;

  /// Alerts that are still going on, newest first
  List<AlertEvent> get active {
    final list = [
      for (final e in state.devices.entries)
        if (rules.monitors(e.key)) ...e.value.active.values,
    ]..sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  List<AlertEvent> activeFor(String deviceId) => [...?state.devices[deviceId]?.active.values];

  void _schedule(AlertRules rules) {
    _timer?.cancel();
    if (!rules.enabled) return;
    _timer = Timer.periodic(Duration(seconds: rules.foregroundSeconds), (_) => checkDue());
    Future.delayed(const Duration(seconds: 5), checkDue);
  }

  Future<void> reload() async {
    state = await AlertStore.read();
  }

  List<SSHConnection> get _devices => ref.read(connectionListProvider);

  /// Probes devices that have not been checked for a while
  Future<void> checkDue({bool force = false}) async {
    if (_checking || !rules.enabled) return;
    _checking = true;
    try {
      await AlertRunner.checkDue(
        _devices,
        force ? Duration.zero : Duration(seconds: rules.foregroundSeconds) - const Duration(seconds: 5),
      );
      await reload();
    } finally {
      _checking = false;
    }
  }

  /// A check made elsewhere, e.g. by the Devices screen
  Future<void> ingest(SSHConnection device, ProbeResult result) async {
    if (!rules.monitors(device.id)) return;
    state = await AlertRunner.process(device, result);
  }

  Future<void> setRules(AlertRules rules) async {
    final before = state.rules;
    state = await AlertStore.update((d) => d.copyWith(rules: rules));
    if (before.enabled != rules.enabled || before.foregroundSeconds != rules.foregroundSeconds) {
      _schedule(rules);
    }
    if (before.enabled != rules.enabled ||
        before.background != rules.background ||
        before.backgroundMinutes != rules.backgroundMinutes) {
      await BackgroundMonitor.apply(rules);
    }
  }

  Future<void> update(AlertRules Function(AlertRules r) change) => setRules(change(state.rules));

  Future<void> markAllRead() async {
    if (unread == 0) return;
    state = await AlertStore.update(
      (d) => d.copyWith(history: [for (final e in d.history) e.read ? e : e.copyWith(read: true)]),
    );
  }

  Future<void> clearHistory() async {
    state = await AlertStore.update((d) => d.copyWith(history: const []));
  }

  /// Forgets what a deleted device was doing
  Future<void> forgetDevice(String id) async {
    state = await AlertStore.update(
      (d) => d.copyWith(
        devices: {...d.devices}..remove(id),
        history: d.history.where((e) => e.deviceId != id).toList(),
        rules: d.rules.copyWith(mutedDevices: {...d.rules.mutedDevices}..remove(id)),
      ),
    );
  }

  Future<void> setMuted(String id, bool muted) => update(
    (r) => r.copyWith(mutedDevices: muted ? {...r.mutedDevices, id} : ({...r.mutedDevices}..remove(id))),
  );
}
