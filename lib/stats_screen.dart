import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/ssh_service.dart';
import 'dart:async';
import 'dart:math';
import 'services/stats_controller.dart';  
class StatsScreen extends StatefulWidget {
  final SSHService? sshService;
  final VoidCallback? onDispose;   

  const StatsScreen({
    super.key,
    required this.sshService,
    this.onDispose,  
  });

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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

   @override
  void initState() {
    super.initState();
    _initializePrefs();
    if (widget.sshService != null) {
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
    });
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
      await Future.delayed(const Duration(milliseconds: 500)); 
      await _fetchServices();
      _filterServices(); 
      _sortServices();  
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

  Color _getStatusColor(String status) {
    if (status == 'running') {
      return Colors.green;
    } else if (status == 'dead') {
      return Colors.red;
    } else if (status == 'exited') {
      return Colors.orange;
    }
    return Colors.grey;
  } 

  Widget _buildChart(String title, List<FlSpot> spots, Color color, String suffix, String maxValue, {double maxY = 100}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  maxValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${spots.isEmpty ? 0 : spots.last.y.toStringAsFixed(1)}$suffix',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  minX: spots.isEmpty ? 0 : spots.first.x,
                  maxX: spots.isEmpty ? timeIndex : spots.last.x,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      colors: [color],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [color.withOpacity(0.1), color.withOpacity(0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCpuChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CPU Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Max: 100%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${cpuHistory.isEmpty ? 0 : cpuHistory.last.y.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  minX: cpuHistory.isEmpty ? 0 : cpuHistory.first.x,
                  maxX: cpuHistory.isEmpty ? timeIndex : cpuHistory.last.x,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: cpuUserHistory,
                      isCurved: true,
                      colors: [Colors.yellow],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuSystemHistory,
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuNiceHistory,
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuIoWaitHistory,
                      isCurved: true,
                      colors: [Colors.orange],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: cpuIrqHistory,
                      isCurved: true,
                      colors: [Colors.purple],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildLegendItem('User', Colors.yellow),
                _buildLegendItem('System', Colors.red),
                _buildLegendItem('Nice', Colors.green),
                _buildLegendItem('I/O Wait', Colors.orange),
                _buildLegendItem('IRQ', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  String _formatNetworkSpeed(double kbps) {
    if (kbps < 1) {
      return '${(kbps * 1024).toStringAsFixed(1)} B/s';
    } else if (kbps < 1024) {
      return '${kbps.toStringAsFixed(1)} KB/s';
    } else if (kbps < 1024 * 1024) {
      return '${(kbps / 1024).toStringAsFixed(1)} MB/s';
    } else {
      return '${(kbps / (1024 * 1024)).toStringAsFixed(1)} GB/s';
    }
  }

  String _formatMaxSpeed(double kbps) {
    if (kbps < 1024) {
      return '${kbps.toStringAsFixed(0)} KB/s';
    } else if (kbps < 1024 * 1024) {
      return '${(kbps / 1024).toStringAsFixed(1)} MB/s';
    } else {
      return '${(kbps / (1024 * 1024)).toStringAsFixed(1)} GB/s';
    }
  }

  Widget _buildNetworkChart() {
    double maxY = 1.0;  
    for (var spot in networkInHistory) {
      if (spot.y > maxY) maxY = spot.y;
    }
    for (var spot in networkOutHistory) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = pow(10, (log(maxY) / ln10).ceil()).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Network Traffic',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Max: ${_formatMaxSpeed(maxY)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'In: ${_formatNetworkSpeed(networkInHistory.isEmpty ? 0 : networkInHistory.last.y)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Out: ${_formatNetworkSpeed(networkOutHistory.isEmpty ? 0 : networkOutHistory.last.y)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  minX: networkInHistory.isEmpty ? 0 : networkInHistory.first.x,
                  maxX: networkInHistory.isEmpty ? timeIndex : networkInHistory.last.x,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: networkInHistory,
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0)],
                      ),
                    ),
                    LineChartBarData(
                      spots: networkOutHistory,
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildLegendItem('Network In', Colors.green),
                _buildLegendItem('Network Out', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
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

    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSystemInfo(),
            const SizedBox(height: 16),
            _buildServiceControl(),
            const SizedBox(height: 16),
            _buildDiskUsage(),
            const SizedBox(height: 16),
            _buildCpuChart(),
            const SizedBox(height: 16),
            _buildChart(
              'Memory Usage',
              memoryHistory,
              Colors.green,
              '%',
              'Max: ${currentStats['memory_total']} MB',
            ),
            const SizedBox(height: 16),
            _buildChart(
              'CPU Temperature',
              cpuTempHistory,
              Colors.orange,
              '°C',
              'Max: 90°C',
            ),
            const SizedBox(height: 16),
            _buildChart(
              'GPU Temperature',
              gpuTempHistory,
              Colors.red,
              '°C',
              'Max: 90°C',
            ),
            const SizedBox(height: 16),
            _buildNetworkChart(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Control',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search Services',
                      onPressed: () {
                        setState(() {
                          _showSearchBar = !_showSearchBar;
                          if (!_showSearchBar) {
                            _searchController.clear();
                            _filterServices();
                          }
                        });
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort Services',
                      onSelected: (String value) {
                        setState(() {
                          _sortOption = value;
                          _sortServices();
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Name',
                          child: Text('Name'),
                        ),
                        const PopupMenuItem(
                          value: 'Status',
                          child: Text('Status'),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Services',
                      onPressed: _refreshServices,
                    ),
                  ],
                ),
              ],
            ),
            if (_showSearchBar) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search services...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _filterServices();
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  final serviceName = service['name'] ?? '';
                  final status = service['status'] ?? '';
                  final description = service['description'] ?? '';
                  
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          serviceName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Text(
                                        'Status: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      title: Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.play_arrow,
                              size: 16,
                            ),
                            tooltip: 'Start Service',
                            onPressed: () => _startService(serviceName),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            color: Colors.green,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.stop,
                              size: 16,
                            ),
                            tooltip: 'Stop Service',
                            onPressed: () => _stopService(serviceName),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            color: Colors.red,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                            ),
                            tooltip: 'Restart Service',
                            onPressed: () => _restartService(serviceName),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiskUsage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disk Usage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (currentStats['disks'] == null || (currentStats['disks'] as List).isEmpty)
              const Text('No disk information available')
            else
              ...(currentStats['disks'] as List).map<Widget>((disk) {
                final usedPercentage = double.tryParse(
                    disk['used_percentage']?.replaceAll('%', '') ?? '0') ?? 0.0;
                Color progressColor;
                if (usedPercentage >= 90) {
                  progressColor = Colors.red;
                } else if (usedPercentage >= 75) {
                  progressColor = Colors.orange;
                } else if (usedPercentage >= 50) {
                  progressColor = Colors.yellow;
                } else {
                  progressColor = Colors.green;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${disk['name']} - ${disk['size']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usedPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${disk['used']} used of ${disk['size']} (${disk['used_percentage']})',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo() {
    String formatUptime(String uptime) {
      if (uptime.isEmpty) return 'N/A';
      return uptime;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
                style: BorderStyle.solid,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Hostname', currentStats['hostname']?.toString() ?? 'N/A'),
                _buildTableRow('Operating System', currentStats['os']?.toString().replaceAll('Description:', '').trim() ?? 'N/A'),
                _buildTableRow('IP Address', currentStats['ip_address']?.toString() ?? 'N/A'),
                _buildTableRow('Uptime', formatUptime(currentStats['uptime']?.toString() ?? '')),
                _buildTableRow('CPU Model', currentStats['cpu_model']?.toString() ?? 'N/A'),
                _buildTableRow('Total Disk Space', currentStats['total_disk_space']?.toString() ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.end,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}