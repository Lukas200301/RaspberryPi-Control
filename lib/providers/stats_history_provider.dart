import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/pi_control.pb.dart';
import 'app_providers.dart';
import 'settings_provider.dart';

/// Recent values of the live stats stream (one point per second)
@immutable
class StatsHistory {
  final LiveStats? latest;
  final List<double> cpu;
  final List<double> memory;
  final List<double> temperature;

  /// Bytes per second
  final List<double> netDown;
  final List<double> netUp;
  final List<double> diskRead;
  final List<double> diskWrite;

  const StatsHistory({
    this.latest,
    this.cpu = const [],
    this.memory = const [],
    this.temperature = const [],
    this.netDown = const [],
    this.netUp = const [],
    this.diskRead = const [],
    this.diskWrite = const [],
  });

  double get memoryPercent {
    final s = latest;
    if (s == null || s.ramTotal.toInt() == 0) return 0;
    return s.ramUsed.toDouble() / s.ramTotal.toDouble() * 100;
  }
}

final statsHistoryProvider =
    NotifierProvider.autoDispose<StatsHistoryNotifier, StatsHistory>(StatsHistoryNotifier.new);

class StatsHistoryNotifier extends AutoDisposeNotifier<StatsHistory> {
  @override
  StatsHistory build() {
    final capacity = ref.watch(settingsProvider.select((s) => s.statsHistory));
    // A new device or connection starts an empty history
    ref.watch(grpcSessionProvider);
    ref.listen<AsyncValue<LiveStats>>(liveStatsProvider, (_, next) {
      final stats = next.valueOrNull;
      if (stats != null) _add(stats, capacity);
    });
    return const StatsHistory();
  }

  List<double> _push(List<double> list, double value, int capacity) {
    final next = [...list, value];
    return next.length > capacity ? next.sublist(next.length - capacity) : next;
  }

  void _add(LiveStats s, int capacity) {
    final h = state;
    final ramTotal = s.ramTotal.toDouble();
    var read = 0.0, write = 0.0;
    for (final d in s.diskIo) {
      read += d.readBytes.toDouble();
      write += d.writeBytes.toDouble();
    }
    state = StatsHistory(
      latest: s,
      cpu: _push(h.cpu, s.cpuUsage, capacity),
      memory: _push(h.memory, ramTotal == 0 ? 0 : s.ramUsed.toDouble() / ramTotal * 100, capacity),
      temperature: _push(h.temperature, s.cpuTemp, capacity),
      netDown: _push(h.netDown, s.netBytesRecv.toDouble(), capacity),
      netUp: _push(h.netUp, s.netBytesSent.toDouble(), capacity),
      diskRead: _push(h.diskRead, read, capacity),
      diskWrite: _push(h.diskWrite, write, capacity),
    );
  }
}
