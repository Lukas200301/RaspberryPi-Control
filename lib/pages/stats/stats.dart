import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ssh_service.dart';
import 'dart:async';
import '../../controllers/stats_controller.dart';
import 'widgets/system_info_widget.dart';
import 'widgets/service_control_widget.dart';
import 'widgets/disk_usage_widget.dart';
import 'widgets/charts/cpu_chart.dart';
import 'widgets/charts/memory_chart.dart';
import 'widgets/charts/temperature_chart.dart';
import 'widgets/charts/network_chart.dart';
import 'widgets/charts/hardware_monitor_chart.dart';
import 'widgets/process_monitor_widget.dart';
import 'widgets/network_ping_widget.dart';
import 'widgets/system_logs_widget.dart';
import 'widgets/boot_performance_widget.dart';
import 'widgets/disk_io_widget.dart';
import 'widgets/security_status_widget.dart';

class Stats extends StatefulWidget {
  final SSHService? sshService;
  final VoidCallback? onDispose;   

  const Stats({
    super.key,
    required this.sshService,
    this.onDispose,  
  });

  @override
  StatsState createState() => StatsState();
}

class StatsState extends State<Stats> {
  Timer? _monitoringTimer;
  bool isLoading = true;
  bool isInstallingPackages = false;
  bool packagesInstalled = false;
  bool _showSearchBar = false;
  SharedPreferences? prefs;
  List<Map<String, String>> services = [];
  String _sortOption = 'Name';
  List<Map<String, String>> filteredServices = [];

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
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

  Map<String, dynamic> currentStats = {
    'cpu': 0.0,
    'memory': 0.0,
    'memory_total': 0.0,
    'memory_used': 0.0,
    'cpu_temperature': 0.0,
    'gpu_temperature': 0.0,
    'disks': [],
    'network_in': 0.0,
    'network_out': 0.0,
    'uptime': '',
  };

  bool _isConnected = true;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    
    if (widget.sshService != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _connectionSubscription = widget.sshService!.connectionStatus.listen((connected) {
            if (mounted) {
              setState(() {
                _isConnected = connected;
                if (connected && !isLoading) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) _fetchStats();
                  });
                }
              });
            }
          });
        }
      });
      
      _checkRequiredPackages();
    }
    
    _searchController.addListener(_filterServices);
    _startInitialFetch();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  void _filterServices() {
    if (_searchController.text.isEmpty) {
      filteredServices = List.from(services);
    } else {
      final query = _searchController.text.toLowerCase();
      filteredServices = services.where((service) {
        return service['name']!.toLowerCase().contains(query) ||
               service['description']!.toLowerCase().contains(query);
      }).toList();
    }
    _sortServices();
  }

  void _sortServices() {
    setState(() {
      if (_sortOption == 'Name') {
        filteredServices.sort((a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
      } else if (_sortOption == 'Status') {
        filteredServices.sort((a, b) {
          const statusOrder = {'running': 0, 'exited': 1, 'dead': 2};
          return statusOrder[a['status']]!.compareTo(statusOrder[b['status']]!);
        });
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _startMonitoring() {
    if (widget.sshService == null) {
      print("Error: SSHService is null. Monitoring cannot start.");
      return;
    }
    
    try {
      StatsController.instance.startMonitoring(widget.sshService!);
      StatsController.instance.statsStream.listen((stats) {
        if (mounted) {
          setState(() {
            currentStats = stats;
            timeIndex = StatsController.instance.timeIndex;
            cpuHistory.clear();
            cpuHistory.addAll(StatsController.instance.cpuHistory);
            memoryHistory.clear();
            memoryHistory.addAll(StatsController.instance.memoryHistory);
            cpuTempHistory.clear();
            cpuTempHistory.addAll(StatsController.instance.cpuTempHistory);
            gpuTempHistory.clear();
            gpuTempHistory.addAll(StatsController.instance.gpuTempHistory);
            networkInHistory.clear();
            networkInHistory.addAll(StatsController.instance.networkInHistory);
            networkOutHistory.clear();
            networkOutHistory.addAll(StatsController.instance.networkOutHistory);
            cpuUserHistory.clear();
            cpuUserHistory.addAll(StatsController.instance.cpuUserHistory);
            cpuSystemHistory.clear();
            cpuSystemHistory.addAll(StatsController.instance.cpuSystemHistory);
            cpuNiceHistory.clear();
            cpuNiceHistory.addAll(StatsController.instance.cpuNiceHistory);
            cpuIoWaitHistory.clear();
            cpuIoWaitHistory.addAll(StatsController.instance.cpuIoWaitHistory);
            cpuIrqHistory.clear();
            cpuIrqHistory.addAll(StatsController.instance.cpuIrqHistory);
            isLoading = false;
          });
        }
      }, onError: (error) {
        print("Stats stream error: $error");
      });
    } catch (e) {
      print("Failed to start monitoring: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start system monitoring: $e')),
      );
    }
  }

  Future<void> _manualReconnect() async {
    if (widget.sshService == null) return;
    
    setState(() { 
      isLoading = true; 
    });
    
    try {
      await widget.sshService!.reconnect();
      await Future.delayed(const Duration(seconds: 1));
      await _fetchStats();
      _startMonitoring();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reconnect: $e')),
      );
    } finally {
      if (mounted) {
        setState(() { 
          isLoading = false; 
        });
      }
    }
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    packagesInstalled = prefs?.getBool('packagesInstalled') ?? false;
    if (packagesInstalled) {
      _startMonitoring();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkRequiredPackages() async {
    if (!packagesInstalled) {
      final hasPackages = await widget.sshService!.checkRequiredPackages();
      if (!hasPackages) {
        if (mounted) {
          final shouldInstall = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Additional Packages Required'),
              content: const Text(
                'To enable advanced monitoring features, the following packages '
                'need to be installed:\n\n'
                '• sysstat (system statistics)\n'
                '• ifstat (network monitoring)\n'
                '• nmon (performance monitoring)\n'
                '• vcgencmd (GPU temperature monitoring)\n'
                '• lsb-release (Show operating system)\n'
                'Would you like to install them now?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Install'),
                ),
              ],
            ),
          );

          if (shouldInstall == true) {
            setState(() {
              isLoading = true;
              isInstallingPackages = true;
            });
            try {
              await widget.sshService!.installRequiredPackages();
              packagesInstalled = true;
              await prefs?.setBool('packagesInstalled', true);
              _startMonitoring();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to install packages: $e')),
                );
              }
            }
            setState(() {
              isLoading = false;
              isInstallingPackages = false;
            });
          }
        }
      } else {
        packagesInstalled = true;
        await prefs?.setBool('packagesInstalled', true);
        _startMonitoring();
      }
    }
  }

  Future<void> _fetchStats() async {
    if (widget.sshService != null && packagesInstalled) {
      try {
        if (!widget.sshService!.isConnected()) {
          await widget.sshService!.connect();
        }
        setState(() {
          currentStats = StatsController.instance.currentStats;
          cpuHistory.clear();
          cpuHistory.addAll(StatsController.instance.cpuHistory);
          memoryHistory.clear();
          memoryHistory.addAll(StatsController.instance.memoryHistory);
          cpuTempHistory.clear();
          cpuTempHistory.addAll(StatsController.instance.cpuTempHistory);
          gpuTempHistory.clear();
          gpuTempHistory.addAll(StatsController.instance.gpuTempHistory);
          networkInHistory.clear();
          networkInHistory.addAll(StatsController.instance.networkInHistory);
          networkOutHistory.clear();
          networkOutHistory.addAll(StatsController.instance.networkOutHistory);
          diskUsageHistory.clear();
          diskUsageHistory.addAll(StatsController.instance.diskUsageHistory);
          cpuUserHistory.clear();
          cpuUserHistory.addAll(StatsController.instance.cpuUserHistory);
          cpuSystemHistory.clear();
          cpuSystemHistory.addAll(StatsController.instance.cpuSystemHistory);
          cpuNiceHistory.clear();
          cpuNiceHistory.addAll(StatsController.instance.cpuNiceHistory);
          cpuIoWaitHistory.clear();
          cpuIoWaitHistory.addAll(StatsController.instance.cpuIoWaitHistory);
          cpuIrqHistory.clear();
          cpuIrqHistory.addAll(StatsController.instance.cpuIrqHistory);
          isLoading = false;
        });
      } catch (e) {
        if (e.toString().contains('Not connected')) {
          await Future.delayed(const Duration(seconds: 5));
          _fetchStats();
        }
      }
    }
  }

  Future<void> _startInitialFetch() async {
    if (widget.sshService != null) {
      await Future.delayed(const Duration(milliseconds: 800)); 
      
      try {
        await _fetchServices();
        _filterServices(); 
        _sortServices(); 
      } catch (e) {
        print("Initial fetch failed: $e - will retry later");
      }
    }
  }

  Future<void> _fetchServices() async {
    if (widget.sshService == null) {
      return;
    }

    try {
      if (!widget.sshService!.isConnected()) {
        await widget.sshService!.connect();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      final fetchedServices = await widget.sshService!.getServices();
      if (mounted) {
        setState(() {
          services = fetchedServices;
          _filterServices(); 
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch services: $e')),
        );
      }
    }
  }

  Future<void> _startService(String serviceName) async {
    if (widget.sshService != null) {
      await widget.sshService!.startService(serviceName);
      _showMessage('Service $serviceName started');
    }
  }

  Future<void> _stopService(String serviceName) async {
    if (widget.sshService != null) {
      await widget.sshService!.stopService(serviceName);
      _showMessage('Service $serviceName stopped');
    }
  }

  Future<void> _restartService(String serviceName) async {
    if (widget.sshService != null) {
      await widget.sshService!.restartService(serviceName);
      _showMessage('Service $serviceName restarted');
    }
  }

  Future<void> _refreshServices() async {
    await _fetchServices();
    _filterServices();
    _sortServices();
  }

  Future<String> _getServiceLogs(String serviceName) async {
    if (widget.sshService == null) {
      return 'SSH service not available';
    }
    
    try {
      return await widget.sshService!.getServiceStatus(serviceName);
    } catch (e) {
      return 'Failed to fetch logs: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (isInstallingPackages) {
      return const Center(
        child: Text(
          'Installing required packages, please wait...',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    if (!packagesInstalled) {
      return const Center(
        child: Text(
          'Install required packages to enable monitoring',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    if (!_isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync_problem, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Connection lost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Attempting to reconnect...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _manualReconnect,
              icon: const Icon(Icons.refresh),
              label: const Text('Reconnect Now'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SystemInfoWidget(systemInfo: currentStats),
            const SizedBox(height: 16),
            BootPerformanceWidget(systemInfo: currentStats),
            const SizedBox(height: 16),
            SecurityStatusWidget(securityInfo: currentStats['security_info'] ?? {}),
            const SizedBox(height: 16),
            ServiceControlWidget(
              services: services,
              filteredServices: filteredServices,
              showSearchBar: _showSearchBar,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              onSearchToggle: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                  if (!_showSearchBar) {
                    _searchController.clear();
                    _filterServices();
                  }
                });
              },
              onRefresh: _refreshServices,
              onFilterChange: _filterServices,
              onStartService: _startService,
              onStopService: _stopService,
              onRestartService: _restartService,
              getServiceLogs: _getServiceLogs,
            ),
            const SizedBox(height: 16),
            HardwareMonitorChart(
              cpuFreqHistory: StatsController.instance.cpuFreqHistory,
              wifiSignalHistory: StatsController.instance.wifiSignalHistory,
              timeIndex: timeIndex,
              currentFreq: currentStats['cpu_frequency'] ?? 0.0,
              coreVoltage: currentStats['core_voltage'] ?? 0.0,
              throttlingStatus: currentStats['throttling_status'] as Map<String, bool>?,
            ),
            const SizedBox(height: 16),
            ProcessMonitorWidget(
              processes: currentStats['top_processes'] ?? [],
            ),
            const SizedBox(height: 16),
            DiskIOWidget(
              ioStats: currentStats['disk_io'] ?? {},
              readHistory: StatsController.instance.diskReadHistory,
              writeHistory: StatsController.instance.diskWriteHistory,
              timeIndex: timeIndex,
            ),
            const SizedBox(height: 16),
            DiskUsageWidget(disks: currentStats['disks'] ?? []),
            const SizedBox(height: 16),
            CpuChartWidget(
              cpuHistory: cpuHistory,
              cpuUserHistory: cpuUserHistory,
              cpuSystemHistory: cpuSystemHistory,
              cpuNiceHistory: cpuNiceHistory,
              cpuIoWaitHistory: cpuIoWaitHistory,
              cpuIrqHistory: cpuIrqHistory,
              timeIndex: timeIndex,
            ),
            const SizedBox(height: 16),
            MemoryChartWidget(
              memoryHistory: memoryHistory,
              memoryTotal: currentStats['memory_total'] ?? 0.0,
              timeIndex: timeIndex,
            ),
            const SizedBox(height: 16),
            NetworkPingWidget(
              pingHistory: StatsController.instance.pingLatencyHistory,
              timeIndex: timeIndex,
              currentLatency: currentStats['ping_latency'] ?? 0.0,
            ),
            const SizedBox(height: 16),
            TemperatureChartWidget(
              cpuTempHistory: cpuTempHistory,
              gpuTempHistory: gpuTempHistory,
              timeIndex: timeIndex,
            ),
            const SizedBox(height: 16),
            NetworkChartWidget(
              networkInHistory: networkInHistory,
              networkOutHistory: networkOutHistory,
              timeIndex: timeIndex,
            ),
            const SizedBox(height: 16),
            SystemLogsWidget(
              logs: currentStats['system_logs'] ?? [],
            ),
          ],
        ),
      ),
    );
  }
}