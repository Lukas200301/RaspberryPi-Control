import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../models/alerts.dart';
import '../models/ssh_connection.dart';
import 'secure_store.dart';

@immutable
class AlertData {
  final AlertRules rules;

  /// Newest first
  final List<AlertEvent> history;
  final Map<String, DeviceAlertState> devices;

  const AlertData({this.rules = const AlertRules(), this.history = const [], this.devices = const {}});

  AlertData copyWith({AlertRules? rules, List<AlertEvent>? history, Map<String, DeviceAlertState>? devices}) =>
      AlertData(rules: rules ?? this.rules, history: history ?? this.history, devices: devices ?? this.devices);

  Map<String, dynamic> toJson() => {
    'version': 1,
    'rules': rules.toJson(),
    'history': history.map((e) => e.toJson()).toList(),
    'devices': {for (final e in devices.entries) e.key: e.value.toJson()},
  };

  factory AlertData.fromJson(Map<String, dynamic> j) => AlertData(
    rules: j['rules'] is Map ? AlertRules.fromJson(Map<String, dynamic>.from(j['rules'] as Map)) : const AlertRules(),
    history: [
      for (final e in (j['history'] as List?) ?? const [])
        if (e is Map) AlertEvent.fromJson(Map<String, dynamic>.from(e)),
    ],
    devices: {
      for (final e in ((j['devices'] as Map?) ?? const {}).entries)
        if (e.value is Map) e.key as String: DeviceAlertState.fromJson(Map<String, dynamic>.from(e.value as Map)),
    },
  );
}

/// Alert rules, history and state in one JSON file.
///
/// The app and the Android background service run in different isolates, so
/// nothing is cached: every change re-reads the file, applies itself and
/// writes the result back atomically.
class AlertStore {
  static const maxHistory = 300;
  static Future<void> _queue = Future.value();

  static Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}alerts.json');
  }

  static Future<AlertData> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const AlertData();
      return AlertData.fromJson(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Alert store unreadable: $e');
      return const AlertData();
    }
  }

  /// Applies [change] to the stored data and returns the result
  static Future<AlertData> update(AlertData Function(AlertData data) change) {
    final completer = Completer<AlertData>();
    _queue = _queue.then((_) async {
      try {
        final next = change(await read());
        final trimmed = next.history.length > maxHistory
            ? next.copyWith(history: next.history.take(maxHistory).toList())
            : next;
        final file = await _file();
        final tmp = File('${file.path}.tmp');
        await tmp.writeAsString(jsonEncode(trimmed.toJson()), flush: true);
        await tmp.rename(file.path);
        completer.complete(trimmed);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  /// Saved devices, read straight from the app's GetStorage file so a
  /// background isolate sees edits made in the app
  static Future<List<SSHConnection>> readDevices() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}GetStorage.gs');
      if (!await file.exists()) return const [];
      final store = jsonDecode(await file.readAsString());
      final raw = store is Map ? store[AppConstants.storageKeyConnections] : null;
      if (raw is! String) return const [];
      var secrets = const <String, DeviceSecret>{};
      try {
        if (await SecureStore.isReady()) secrets = await SecureStore.readSecrets();
      } catch (_) {
        // No secure storage: the secrets are in the stored devices
      }
      return [
        for (final j in jsonDecode(raw) as List)
          if (j is Map)
            switch (SSHConnection.fromJson(Map<String, dynamic>.from(j))) {
              final c when DeviceSecret.of(c).isEmpty => secrets[c.id]?.applyTo(c) ?? c,
              final c => c,
            },
      ];
    } catch (e) {
      debugPrint('Devices unreadable: $e');
      return const [];
    }
  }
}
