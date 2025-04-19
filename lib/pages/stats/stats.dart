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
import 'widgets/system_processes_widget.dart'; 
import 'widgets/network_ping_widget.dart';
import 'widgets/system_logs_widget.dart';
import 'widgets/active_connections_widget.dart';
import '../settings/settings.dart';  

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

class StatsState extends State<Stats> with WidgetsBindingObserver {
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
  StreamSubscription? _dashboardChangedSubscription;

  List<DashboardWidgetInfo> _dashboardWidgets = [];

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    WidgetsBinding.instance.addObserver(this);
    
    _dashboardChangedSubscription = Settings.dashboardChanged.listen((_) {
      _loadDashboardSettings();
    });
    
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
    _loadDashboardSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dashboardChangedSubscription?.cancel();
    _monitoringTimer?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardSettings();
    }
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

  Future<void> _loadDashboardSettings() async {
    print("Loading dashboard settings");
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, bool> visibilityMap = {};
    final hiddenWidgetsStr = prefs.getStringList('hiddenDashboardWidgets') ?? [];
    
    final hasSavedSettings = (prefs.getStringList('dashboardWidgetOrder') != null || 
                            !hiddenWidgetsStr.isEmpty);
    
    for (final widgetId in hiddenWidgetsStr) {
      visibilityMap[widgetId] = false;
    }
    
    final List<String>? savedOrder = prefs.getStringList('dashboardWidgetOrder');
    
    final allWidgets = DashboardWidgetInfo.getDefaultWidgets();
    
    List<DashboardWidgetInfo> widgetsToUse = [];
    
    if (savedOrder != null && savedOrder.isNotEmpty) {
      final List<DashboardWidgetInfo> orderedWidgets = [];
      
      for (String widgetId in savedOrder) {
        final widget = allWidgets.firstWhere(
          (w) => w.id == widgetId,
          orElse: () => DashboardWidgetInfo(
            id: widgetId,
            name: widgetId.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
            icon: Icons.widgets,
          ),
        );
        
        if (visibilityMap.containsKey(widget.id)) {
          widget.visible = visibilityMap[widget.id]!;
        }
        
        orderedWidgets.add(widget);
      }
      
      for (final widget in allWidgets) {
        if (!orderedWidgets.any((w) => w.id == widget.id)) {
          if (visibilityMap.containsKey(widget.id)) {
            widget.visible = visibilityMap[widget.id]!;
          }
          orderedWidgets.add(widget);
        }
      }
      
      widgetsToUse = orderedWidgets;
    } else {
      widgetsToUse = [...allWidgets]; 
      for (final widget in widgetsToUse) {
        if (visibilityMap.containsKey(widget.id)) {
          widget.visible = visibilityMap[widget.id]!;
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _dashboardWidgets = widgetsToUse;
        _hasSavedSettings = hasSavedSettings; 
        print("Dashboard widgets updated: ${_dashboardWidgets.length}, custom settings: $hasSavedSettings");
      });
    }
  }

  bool _hasSavedSettings = false;

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
          'Loading stats, please wait...',
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 96.0),
              ..._buildDashboardWidgets(),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildDashboardWidgets() {
    final List<Widget> widgets = [];
    
    final Map<String, Widget Function()> widgetBuilders = {
      'system_info': () => SystemInfoWidget(systemInfo: currentStats),
      'service_control': () => ServiceControlWidget(
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
      'hardware_monitor': () => HardwareMonitorChart(
        cpuFreqHistory: StatsController.instance.cpuFreqHistory,
        wifiSignalHistory: StatsController.instance.wifiSignalHistory,
        timeIndex: timeIndex,
        currentFreq: currentStats['cpu_frequency'] ?? 0.0,
        coreVoltage: currentStats['core_voltage'] ?? 0.0,
        throttlingStatus: currentStats['throttling_status'] as Map<String, bool>?,
      ),
      'system_processes': () => SystemProcessesWidget(
        processes: currentStats['processes'] ?? [],
      ),
      'disk_usage': () => DiskUsageWidget(disks: currentStats['disks'] ?? []),
      'active_connections': () => ActiveConnectionsWidget(
        connections: currentStats['active_connections'] ?? [],
      ),
      'cpu_chart': () => CpuChartWidget(
        cpuHistory: cpuHistory,
        cpuUserHistory: cpuUserHistory,
        cpuSystemHistory: cpuSystemHistory,
        cpuNiceHistory: cpuNiceHistory,
        cpuIoWaitHistory: cpuIoWaitHistory,
        cpuIrqHistory: cpuIrqHistory,
        timeIndex: timeIndex,
      ),
      'memory_chart': () => MemoryChartWidget(
        memoryHistory: memoryHistory,
        memoryTotal: currentStats['memory_total'] ?? 0.0,
        timeIndex: timeIndex,
      ),
      'network_ping': () => NetworkPingWidget(
        pingHistory: StatsController.instance.pingLatencyHistory,
        timeIndex: timeIndex,
        currentLatency: currentStats['ping_latency'] ?? 0.0,
      ),
      'temperature_chart': () => TemperatureChartWidget(
        cpuTempHistory: cpuTempHistory,
        gpuTempHistory: gpuTempHistory,
        timeIndex: timeIndex,
      ),
      'network_chart': () => NetworkChartWidget(
        networkInHistory: networkInHistory,
        networkOutHistory: networkOutHistory,
        timeIndex: timeIndex,
      ),
      'system_logs': () => SystemLogsWidget(
        logs: currentStats['system_logs'] ?? [],
      ),
    };
    
    List<DashboardWidgetInfo> widgetsToShow = DashboardWidgetInfo.getDefaultWidgets();
    
    if (_hasSavedSettings) {
      final visibleWidgets = _dashboardWidgets.where((w) => w.visible).toList();
      
      if (visibleWidgets.isNotEmpty) {
        widgetsToShow = visibleWidgets;
      }
    }
    
    print("Building dashboard with ${widgetsToShow.length} widgets, customized: $_hasSavedSettings");
    
    for (int i = 0; i < widgetsToShow.length; i++) {
      final widget = widgetsToShow[i];
      
      if (widgetBuilders.containsKey(widget.id)) {
        widgets.add(widgetBuilders[widget.id]!());
        
        if (i < widgetsToShow.length - 1) {
          widgets.add(const SizedBox(height: 16));
        }
      }
    }
    
    return widgets;
  }
}