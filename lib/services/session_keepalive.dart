import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'grpc_file_transfer_service.dart';

/// Keeps the session alive while the app is in the background (Android).
///
/// Android destroys an app's network sockets when it leaves the screen, so a
/// foreground service with a notification runs while a device is connected.
/// During file transfers the notification shows their progress.
class SessionKeepAlive {
  static const _channel = MethodChannel('pi_control/session');

  /// Matches SessionService.NO_PROGRESS
  static const _noProgress = -2;

  static bool get supported => !kIsWeb && Platform.isAndroid;

  final GrpcFileTransferService transfers;
  String? _device;
  bool _running = false;
  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  String _lastKey = '';

  SessionKeepAlive(this.transfers) {
    if (supported) transfers.addListener(_sync);
  }

  /// The connected device's name, or null when disconnected
  set device(String? name) {
    if (name == _device) return;
    _device = name;
    _sync(force: true);
  }

  void dispose() {
    if (!supported) return;
    transfers.removeListener(_sync);
    if (_running) _invoke('stop');
  }

  void _sync({bool force = false}) {
    if (!supported) return;
    final active = transfers.activeTransfers;
    if (_device == null && active.isEmpty) {
      if (_running) {
        _running = false;
        _lastKey = '';
        _invoke('stop');
      }
      return;
    }

    final String title, text;
    final int progress;
    if (active.isEmpty) {
      title = 'Connected to $_device';
      text = 'Tap to open. Disconnect in the app to end the session.';
      progress = _noProgress;
    } else {
      final total = active.fold<int>(0, (s, t) => s + t.totalBytes);
      final done = active.fold<int>(0, (s, t) => s + t.transferredBytes);
      final uploads = active.where((t) => t.isUpload).length;
      final verb = uploads == active.length
          ? 'Uploading'
          : uploads == 0
          ? 'Downloading'
          : 'Transferring';
      title = '$verb ${active.length == 1 ? active.first.filename : '${active.length} files'}';
      text = active.length == 1 ? active.first.speedString : '${active.first.filename} and ${active.length - 1} more';
      progress = total > 0 ? (done * 100 ~/ total) : -1;
    }

    // Progress arrives many times a second; the notification needs far less
    final key = '$title|$progress';
    final now = DateTime.now();
    if (!force && key == _lastKey) return;
    if (!force && _running && progress >= 0 && now.difference(_lastUpdate) < const Duration(seconds: 1)) return;
    _lastUpdate = now;
    _lastKey = key;
    _running = true;
    _invoke('update', {'title': title, 'text': text, 'progress': progress});
  }

  Future<void> _invoke(String method, [Map<String, Object?>? args]) async {
    try {
      await _channel.invokeMethod(method, args);
    } catch (e) {
      // Without the service everything still works while the app is open
      debugPrint('Session keep-alive ($method) failed: $e');
    }
  }
}
