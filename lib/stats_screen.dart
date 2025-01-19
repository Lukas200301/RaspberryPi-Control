import 'package:flutter/material.dart';
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
  Map<String, dynamic> statsMap = {
    'temperature': '',
    'cpu': '',
    'processes': '',
    'uptime': '',
    'memory': '',
    'swap': '',
    'storages': <Map<String, String>>[],
  };
  Timer? _timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.sshService != null) {
      _fetchStats();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _fetchStats();
      });
    }
  }

  void _parseStats(String rawStats) {
    statsMap['storages'] = <Map<String, String>>[];
    
    final lines = rawStats.split('\n');
    for (var line in lines) {
      line = line.trim();
        if (line.startsWith('temp=')) {
          final temp = line.replaceAll('temp=', '').trim();
          statsMap['temperature'] = temp.replaceAll('\'C', '°C');
        } else if (line.startsWith('%Cpu')) {
          final cpuParts = line.split(',');
          if (cpuParts.isNotEmpty) {
            final userCpu = double.tryParse(
              cpuParts[0]
                  .replaceAll('%Cpu(s):', '')
                  .replaceAll('us', '')
                  .trim()
            ) ?? 0.0;
            statsMap['cpu'] = '${userCpu.toStringAsFixed(2)}%';
          } else {
            statsMap['cpu'] = 'Error';
          }
        } else if (line.startsWith('Tasks:')) {
          final tasksParts = line.split(':')[1].trim().split(',');
          final total = tasksParts[0].replaceAll('total', '').trim();
          if (total.isNotEmpty) {
            statsMap['processes'] = '$total tasks';
          } else {
            statsMap['processes'] = 'Error';
          }
        } else if (line.contains('up ')) {
          final uptimeMatch = RegExp(r'up (.*?),').firstMatch(line);
          if (uptimeMatch != null) {
            statsMap['uptime'] = uptimeMatch.group(1) ?? 'Error';
          } else {
            statsMap['uptime'] = 'Error';
          }
        } else if (line.startsWith('Mem:')) {
          try {
            final memParts = line.split(' ').where((s) => s.isNotEmpty).toList();
            if (memParts.length >= 7) {
              final total = double.parse(memParts[1]) / 1024;
              final used = double.parse(memParts[2]) / 1024;
              statsMap['memory'] = '${used.toStringAsFixed(1)}GB / ${total.toStringAsFixed(1)}GB';
            } else {
              throw Exception('Invalid memory data format');
            }
          } catch (e) {
            statsMap['memory'] = 'Error';
          }
        } else if (line.startsWith('Swap:')) {
          try {
            final swapParts = line.split(' ').where((s) => s.isNotEmpty).toList();
            if (swapParts.length >= 3) {
              final total = double.parse(swapParts[1]) / 1024;
              final used = double.parse(swapParts[2]) / 1024;
              statsMap['swap'] = '${used.toStringAsFixed(1)}GB / ${total.toStringAsFixed(1)}GB';
            } else {
              throw Exception('Invalid swap data format');
            }
          } catch (e) {
            statsMap['swap'] = 'Error';
          }
        } else if (line.contains('/dev/') && !line.contains('tmpfs') && !line.contains('udev')) {
          try {
            final parts = line.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
            if (parts.length >= 6 && parts[0].startsWith('/dev/')) {
              final size = parts[1];
              final used = parts[2];
              final percentage = parts[4];
              final mountPoint = parts[5];
              
              if (!mountPoint.startsWith('/boot')) {
                (statsMap['storages'] as List<Map<String, String>>).add({
                  'mountPoint': mountPoint,
                  'info': '$used / $size ($percentage)',
                });
              }
            }
          } catch (e) {
            (statsMap['storages'] as List<Map<String, String>>).add({
              'mountPoint': 'Error',
              'info': 'Failed to read storage info',
            });
          }
        }
    }
  }

  Future<void> _fetchStats() async {
    if (widget.sshService != null) {
      setState(() {
        isLoading = true;
      });
      
      try {
        final result = await widget.sshService!.getStats();
        setState(() {
          _parseStats(result);
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          statsMap.forEach((key, value) {
            if (key != 'storages') {
              statsMap[key] = 'Connection Error';
            }
          });
          statsMap['storages'] = <Map<String, String>>[];
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getTemperatureColor(String temp) {
    if (temp.isEmpty) return Colors.grey;
    final value = double.tryParse(temp.replaceAll('°C', '').replaceAll('\'C', '')) ?? 0;
    if (value >= 75) return Colors.red;
    if (value >= 67.5) return Colors.orange;
    if (value >= 60) return Colors.yellow;
    return Colors.green;
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    bool isStorageCard = title.startsWith('Storage:');
    double titleFontSize = isStorageCard ? 12 : 14;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 24, 
              color: title == 'Temperature' 
                ? _getTemperatureColor(value)
                : Theme.of(context).primaryColor
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,  
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            isLoading
                ? const SizedBox(
                    height: 12,
                    width: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    value.isEmpty ? 'N/A' : value,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 3, 
                    overflow: TextOverflow.ellipsis,
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mainStats = [
      _buildStatCard('Temperature', 
          statsMap['temperature'] ?? '', 
          Icons.thermostat),
      _buildStatCard('CPU Usage', 
          statsMap['cpu'] ?? '', 
          Icons.memory),
      _buildStatCard('Tasks', 
          statsMap['processes'] ?? '', 
          Icons.apps),
      _buildStatCard('RAM Memory', 
          statsMap['memory'] ?? '', 
          Icons.storage),
      _buildStatCard('Uptime',
          statsMap['uptime'] ?? '',
          Icons.timer),
      _buildStatCard('Swap', 
          statsMap['swap'] ?? '', 
          Icons.swap_horiz),
    ];

    if (statsMap['storages'] is List) {
      for (final storage in statsMap['storages']) {
        mainStats.add(
          _buildStatCard(
            'Storage: ${storage['mountPoint']}',
            storage['info'] ?? '',
            Icons.sd_storage,
          ),
        );
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: mainStats,
              ),
            ],
          ),
        ),
      ),
    );
  }
}