import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import '../services/ssh_service.dart';

class StatsController {
  static final StatsController _instance = StatsController._internal();
  static StatsController get instance => _instance;
  
  StatsController._internal();

  Timer? _monitoringTimer;
  StreamSubscription? _connectionStatusSubscription;
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
  final List<FlSpot> cpuFreqHistory = [];
  final List<FlSpot> pingLatencyHistory = [];
  final List<FlSpot> wifiSignalHistory = [];

  List<Map<String, dynamic>> services = [];
  DateTime _lastServicesFetchTime = DateTime(1970);
  static const Duration SERVICES_FETCH_INTERVAL = Duration(minutes: 1);

  double timeIndex = 0;
  Map<String, dynamic> currentStats = {};
  final _statsStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statsStream => _statsStreamController.stream;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;
  bool _paused = false;
  static const Duration STATS_INTERVAL = Duration(seconds: 3);
  
  int _failedFetchCount = 0;
  static const int MAX_FAILED_FETCHES = 5;

  void startMonitoring(SSHService sshService) {
    if (_isMonitoring) {
      print("Monitoring already active, ignoring duplicate start request");
      return;
    }
    
    _isMonitoring = true;
    _paused = false;
    _monitoringTimer?.cancel();
    
    _connectionStatusSubscription?.cancel();
    _connectionStatusSubscription = sshService.connectionStatus.listen((isConnected) {
      if (isConnected && _isMonitoring && _paused) {
        print("Connection restored, resuming monitoring");
        _paused = false;
        _startMonitoringTimer(sshService);
      } else if (!isConnected && _isMonitoring && !_paused) {
        print("Connection lost, pausing monitoring");
        _paused = true;
        _monitoringTimer?.cancel();
      }
    });
    
    if (sshService.isConnected()) {
      _fetchServices(sshService);
      _startMonitoringTimer(sshService);
    }
  }
  
  void stopStatsMonitoring() {
    _isMonitoring = false;
    _paused = false;
    _monitoringTimer?.cancel();
    _connectionStatusSubscription?.cancel();
    _failedFetchCount = 0;
  }
  
  void _startMonitoringTimer(SSHService sshService) {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(STATS_INTERVAL, (timer) {
      if (!_paused) {
        _fetchStats(sshService);
      }
    });
  }

  Future<void> _fetchStats(SSHService sshService) async {
    if (_paused || !_isMonitoring) {
      return; 
    }
    
    if (!sshService.isConnected()) {
      _failedFetchCount++;
      print("SSH not connected. Failed fetch count: $_failedFetchCount");
      
      if (_failedFetchCount >= MAX_FAILED_FETCHES) {
        _paused = true; 
        print("Too many failed fetches, connection appears to be down");
        _failedFetchCount = 0;
      }
      return;
    }

    try {
      final stats = await sshService.getDetailedStats();
      _failedFetchCount = 0; 
      timeIndex += 1;

      final now = DateTime.now();
      if (now.difference(_lastServicesFetchTime) >= SERVICES_FETCH_INTERVAL) {
        await _fetchServices(sshService);
      }

      _updateChartData(stats);
      
      stats['services'] = services;
      
      currentStats = stats;
      _statsStreamController.add(stats);
    } catch (e) {
      _failedFetchCount++;
      print('Error fetching stats (attempt $_failedFetchCount): $e');
      
      if (_failedFetchCount >= MAX_FAILED_FETCHES) {
        _paused = true; 
        print("Too many failed fetches, pausing monitoring");
        _failedFetchCount = 0;
      }
    }
  }

  Future<void> _fetchServices(SSHService sshService) async {
    if (!sshService.isConnected()) return;
    
    try {
      final fetchedServices = await sshService.getServices();
      services = fetchedServices.map((service) => 
        Map<String, dynamic>.from(service)
      ).toList();
      _lastServicesFetchTime = DateTime.now();
      print("Services updated: ${services.length}");
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  Future<void> refreshServices(SSHService sshService) async {
    if (!sshService.isConnected()) return;
    
    try {
      await _fetchServices(sshService);
      if (currentStats.isNotEmpty) {
        currentStats['services'] = services;
        _statsStreamController.add(currentStats);
      }
    } catch (e) {
      print("Error refreshing services: $e");
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

    addToHistory(cpuFreqHistory, stats['cpu_frequency'] ?? 0);
    addToHistory(pingLatencyHistory, stats['ping_latency'] ?? 0);
    addToHistory(wifiSignalHistory, stats['wifi_signal_percent']?.toDouble() ?? 0);
  }

  void dispose() {
    stopStatsMonitoring(); 
    _statsStreamController.close();
    _connectionStatusSubscription?.cancel();
  }
}
