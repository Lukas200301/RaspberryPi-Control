import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'ssh_service.dart';

class StatsController {
  static final StatsController _instance = StatsController._internal();
  static StatsController get instance => _instance;

  Timer? _monitoringTimer;
  final List<FlSpot> cpuHistory = [];
  final List<FlSpot> memoryHistory = [];
  final List<FlSpot> cpuTempHistory = [];
  final List<FlSpot> gpuTempHistory = [];
  final List<FlSpot> networkInHistory = [];
  final List<FlSpot> networkOutHistory = [];
  final List<FlSpot> diskUsageHistory = [];
  final List<FlSpot> cpuUserHistory = [];
  final List<FlSpot> cpuSystemHistory = [];
  final List<FlSpot> cpuNiceHistory = [];
  final List<FlSpot> cpuIoWaitHistory = [];
  final List<FlSpot> cpuIrqHistory = [];
  
  double timeIndex = 0;
  Map<String, dynamic> currentStats = {};
  final _statsStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statsStream => _statsStreamController.stream;

  StatsController._internal();

  void startMonitoring(SSHService sshService) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchStats(sshService);
    });
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
  }

  Future<void> _fetchStats(SSHService sshService) async {
    if (!sshService.isConnected()) return;

    try {
      final stats = await sshService.getDetailedStats();
      timeIndex += 1;

      _updateChartData(stats);
      currentStats = stats;
      _statsStreamController.add(stats);
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  void _updateChartData(Map<String, dynamic> stats) {
    void addToHistory(List<FlSpot> history, double value) {
      history.add(FlSpot(timeIndex, value));
      if (history.length > 100) history.removeAt(0);
    }

    addToHistory(cpuHistory, stats['cpu'] ?? 0);
    addToHistory(memoryHistory, stats['memory'] ?? 0);
    addToHistory(cpuTempHistory, stats['cpu_temperature'] ?? 0);
    addToHistory(gpuTempHistory, stats['gpu_temperature'] ?? 0);
    addToHistory(networkInHistory, stats['network_in'] ?? 0);
    addToHistory(networkOutHistory, stats['network_out'] ?? 0);
    addToHistory(cpuUserHistory, stats['cpu_user'] ?? 0);
    addToHistory(cpuSystemHistory, stats['cpu_system'] ?? 0);
    addToHistory(cpuNiceHistory, stats['cpu_nice'] ?? 0);
    addToHistory(cpuIoWaitHistory, stats['cpu_iowait'] ?? 0);
    addToHistory(cpuIrqHistory, stats['cpu_irq'] ?? 0);
  }

  void dispose() {
    stopMonitoring();
    _statsStreamController.close();
  }
}
