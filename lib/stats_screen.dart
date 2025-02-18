import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ssh_service.dart';
import 'dart:async';

class StatsScreen extends StatefulWidget {
  final SSHService? sshService;

  const StatsScreen({
    super.key,
    required this.sshService,
  });

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Timer? _timer;
  bool isLoading = true;
  bool isInstallingPackages = false;
  bool packagesInstalled = false;
  SharedPreferences? prefs;

  // Historical data storage
  final List<FlSpot> cpuHistory = [];
  final List<FlSpot> memoryHistory = [];
  final List<FlSpot> cpuTempHistory = [];
  final List<FlSpot> gpuTempHistory = [];
  final List<FlSpot> networkInHistory = [];
  final List<FlSpot> networkOutHistory = [];
  final List<FlSpot> diskUsageHistory = [];
  double timeIndex = 0;

  // Update current stats storage
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

  void _startMonitoring() {
    _fetchStats();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchStats();
    });
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
        final stats = await widget.sshService!.getDetailedStats();
        if (mounted) {
          setState(() {
            currentStats = stats;
            timeIndex += 1;

            // Update all history lists
            cpuHistory.add(FlSpot(timeIndex, stats['cpu'] ?? 0));
            memoryHistory.add(FlSpot(timeIndex, stats['memory'] ?? 0));
            cpuTempHistory.add(FlSpot(timeIndex, stats['cpu_temperature'] ?? 0));
            gpuTempHistory.add(FlSpot(timeIndex, stats['gpu_temperature'] ?? 0));
            networkInHistory.add(FlSpot(timeIndex, stats['network_in'] ?? 0));
            networkOutHistory.add(FlSpot(timeIndex, stats['network_out'] ?? 0));
            diskUsageHistory.add(FlSpot(timeIndex, double.tryParse(stats['disk_used'] ?? '0') ?? 0));

            // Limit history length to prevent memory issues
            if (cpuHistory.length > 50) {
              cpuHistory.removeAt(0);
              memoryHistory.removeAt(0);
              cpuTempHistory.removeAt(0);
              gpuTempHistory.removeAt(0);
              networkInHistory.removeAt(0);
              networkOutHistory.removeAt(0);
              diskUsageHistory.removeAt(0);
            }

            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching stats: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
            _buildUptimeInfo(),
            _buildChart(
              'CPU Usage',
              cpuHistory,
              Colors.blue,
              '%',
              'Max: 100%',
            ),
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
            _buildChart(
              'Network In',
              networkInHistory,
              Colors.purple,
              'KB/s',
              'Network Traffic',
              maxY: 1000000, 
            ),
            const SizedBox(height: 16),
            _buildChart(
              'Network Out',
              networkOutHistory,
              Colors.indigo,
              'KB/s',
              'Network Traffic',
              maxY: 1000000,
            ),
            const SizedBox(height: 16),
            _buildDiskUsage(),
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
          ...currentStats['disks'].map<Widget>((disk) {
            final usedPercentage = double.tryParse(disk['used_percentage']?.replaceAll('%', '') ?? '0') ?? 0.0;
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
                    child:LinearProgressIndicator(
                      value: usedPercentage / 100,
                      backgroundColor:progressColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${disk['used']} used of ${disk['size']} (${disk['used_percentage']}%)',
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

  Widget _buildUptimeInfo() {
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
            _buildInfoRow(
              'Uptime', 
              formatUptime(currentStats['uptime']?.toString() ?? '')
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}