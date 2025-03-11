import 'dart:convert';
import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../controllers/stats_controller.dart';  

class SSHService {
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  SSHClient? _client;
  bool _isReconnecting = false;
  Timer? _keepAliveTimer;
  Timer? _connectionMonitor;
  int _keepAliveInterval = 60;
  static int defaultConnectionTimeout = 30;
  bool _compression = false;
  int _connectionRetryDelay = 5; 
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool get isReconnecting => _isReconnecting;

  SSHService({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  Future<void> _loadSSHSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _keepAliveInterval = int.tryParse(prefs.getString('sshKeepAliveInterval') ?? '60') ?? 60;
    _compression = prefs.getBool('sshCompression') ?? false;
    _connectionRetryDelay = prefs.getInt('connectionRetryDelay') ?? 5;
  }

  Future<void> connect() async {
    if (_client != null) return;

    await _loadSSHSettings();
    
    try {
      if (_isReconnecting) return;
      _isReconnecting = true;
      
      final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
      
      _client = SSHClient(
        socket, 
        username: username, 
        onPasswordRequest: () => password,
      );
            
      try {
        await BackgroundService.instance.enableBackground();
      } catch (e) {
        print('Warning: Background service error: $e');
        _client?.close();
        _client = null;
        throw e;
      }
      
      _startConnectionMonitoring();
      _isReconnecting = false;
      _connectionStatusController.add(true);
      
      if (_compression) {
        try {
          await _client!.run('compress yes');
        } catch (e) {
          print('Warning: Could not enable SSH compression: $e');
        }
      }
      
      _setupKeepAlive();
      
    } catch (e) {
      _isReconnecting = false;
      _connectionStatusController.add(false);
      await BackgroundService.instance.disableBackground();
      throw Exception('Failed to connect: $e');
    }
  }

  void _startConnectionMonitoring() {
    _keepAliveTimer?.cancel();
    _connectionMonitor?.cancel();

    // More aggressive connection monitoring - check every 2 seconds
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_client != null && !_isReconnecting) {
        try {
          // Use a smaller timeout to quickly detect connection issues
          await _client!.run('echo keepalive').timeout(
            const Duration(seconds: 1),
            onTimeout: () => throw TimeoutException('Connection keepalive timed out'),
          );
        } catch (e) {
          print('Keepalive failed: $e');
          _connectionStatusController.add(false); // Broadcast connection loss immediately
        }
      }
    });

    // Monitor for null client (already disconnected case)
    _connectionMonitor = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_client == null && !_isReconnecting) {
        _connectionStatusController.add(false);
      }
    });
  }

  Future<void> handleAppResume() async {
    if (!isConnected()) {
      print("App resumed: Reconnecting...");
      await reconnect();
    }
  }

  Future<void> _handleReconnection() async {
    if (_isReconnecting) return; 
    _isReconnecting = true;
    _connectionStatusController.add(false);
    
    final prefs = await SharedPreferences.getInstance();
    final autoReconnect = prefs.getBool('autoReconnect') ?? true;
    final maxRetries = prefs.getInt('autoReconnectAttempts') ?? 3;
    
    if (!autoReconnect) {
      print('Auto-reconnect disabled in settings');
      _isReconnecting = false;
      return;
    }
    
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        _client?.close();
        _client = null;
        final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
        
        _client = SSHClient(
          socket, 
          username: username, 
          onPasswordRequest: () => password
        );
        
        _isReconnecting = false;
        _connectionStatusController.add(true);
        print("Reconnection successful.");
        
        return;
      } catch (e) {
        retryCount++;
        print('Reconnection attempt $retryCount failed: $e');
        await Future.delayed(Duration(seconds: _connectionRetryDelay)); 
      }
    }

    _isReconnecting = false;
    print('Reconnection failed after $maxRetries attempts.');
  }


  bool isConnected() {
    try {
      return _client != null && !_client!.isClosed;
    } catch (e) {
      _connectionStatusController.add(false);
      return false;
    }
  }

  void disconnect() async {
    if (_client != null) {
      StatsController.instance.stopMonitoring(); 
      _keepAliveTimer?.cancel();
      _connectionMonitor?.cancel();

      try {
        await BackgroundService.instance.disableBackground();
      } catch (e) {
        print('Warning: Failed to disable background service: $e');
      }
      
      _client?.close();
      _client = null;
    }
  }

  Future<void> reconnect() async {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    
    try {
      // Close any existing connection
      _client?.close();
      _client = null;
      
      // Get connection timeout from settings
      final prefs = await SharedPreferences.getInstance();
      final connectionTimeout = prefs.getInt('connectionTimeout') ?? 30;
      
      // Create new connection with timeout
      final socket = await SSHSocket.connect(
        host, 
        port, 
        timeout: Duration(seconds: connectionTimeout)
      );
      
      _client = SSHClient(
        socket, 
        username: username, 
        onPasswordRequest: () => password,
      );
      
      // Setup connection monitoring and keepalive
      _startConnectionMonitoring();
      _setupKeepAlive();
      
      // Signal successful connection
      _connectionStatusController.add(true);
      return;
      
    } catch (e) {
      _client?.close();
      _client = null;
      _connectionStatusController.add(false);
      print('SSH reconnection failed: $e');
      throw e; // Rethrow to let caller handle
    } finally {
      _isReconnecting = false;
    }
  }

  Future<String> executeCommand(String command) async {
    if (_client == null) {
      await connect();
    }

    try {
      final result = await _client!.run(command);
      return utf8.decode(result);
    } catch (e) {
      if (!_isReconnecting) {
        await _handleReconnection();
        return executeCommand(command); 
      }
      throw Exception('Failed to execute command: $e');
    }
  }

  Future<void> startService(String serviceName) async {
    await executeCommand('sudo systemctl start $serviceName');
  }

  Future<void> stopService(String serviceName) async {
    await executeCommand('sudo systemctl stop $serviceName');
  }

  Future<void> restartService(String serviceName) async {
    await executeCommand('sudo systemctl restart $serviceName');
  }

  Future<String> getServiceStatus(String serviceName) async {
    return await executeCommand('sudo systemctl status $serviceName');
  }

  Future<List<Map<String, String>>> getServices() async {
    final result = await executeCommand(
      'systemctl list-units --type=service --state=loaded --no-pager --no-legend'
    );
    final lines = result.split('\n');
    final services = <Map<String, String>>[];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 4) {
        final serviceFullName = parts[0];
        final serviceName = serviceFullName.endsWith('.service')
            ? serviceFullName.substring(0, serviceFullName.length - 8)  
            : serviceFullName;

        final status = parts[3];  
        final description = parts.length > 4 ? parts.sublist(4).join(' ') : 'No Description';

        services.add({
          'name': serviceName,
          'status': status,
          'description': description,
        });
      }
    }
    return services..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  Future<bool> checkRequiredPackages() async {
      try {
        final result = await executeCommand(
        'dpkg -l | grep -E "htop|iotop|sysstat|ifstat|nmon|libraspberrypi-bin|lsb-release"'
        );
        return result.contains('htop') &&
              result.contains('iotop') &&
              result.contains('sysstat') &&
              result.contains('ifstat') &&
              result.contains('nmon') &&
              result.contains('lsb-release') &&
              result.contains('libraspberrypi-bin');
      } catch (e) {
        return false;
      }
    }

    Future<void> installRequiredPackages() async {
    await executeCommand('''
      sudo apt-get update 
      sudo apt-get install -y htop iotop sysstat ifstat nmon libraspberrypi-bin lsb-release
      sudo systemctl enable sysstat 
      sudo systemctl start sysstat
    ''');
  }

  Future<Map<String, dynamic>> getDetailedStats() async {
    final stats = <String, dynamic>{};

    try {
      final result = await executeCommand('''
        echo "===HOSTNAME===" &&
        hostname &&
        echo "===IP_ADDRESS===" &&
        hostname -I &&
        echo "===OS_INFO===" &&
        lsb_release -d &&
        echo "===CPU_MODEL===" &&
        lscpu | grep 'Model name' &&
        echo "===CPU_USAGE===" &&
        mpstat 1 1 &&
        echo "===CPU_TEMP===" &&
        cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null || echo "N/A" &&
        echo "===GPU_TEMP===" &&
        vcgencmd measure_temp 2>/dev/null || echo "N/A" &&
        echo "===MEM_INFO===" &&
        free -m &&
        echo "===DISK_INFO===" &&
        df -h --total &&
        echo "===NETWORK_INFO===" &&
        ifstat -T 1 1 | tail -n 1 &&
        echo "===SYSTEM_UPTIME===" &&
        uptime
      ''');
      final sections = result.split('\n');
      String currentSection = '';

      for (var line in sections) {
        line = line.trim();

        if (line.startsWith('===') && line.endsWith('===')) {
          currentSection = line.replaceAll('===', '').trim();
          continue;
        }

        switch (currentSection) {
          case 'HOSTNAME':
            if (line.isNotEmpty) {
              stats['hostname'] = line;
            }
            break;

          case 'IP_ADDRESS':
            if (line.isNotEmpty) {
              stats['ip_address'] = line.split(' ')[0];
            }
            break;

          case 'OS_INFO':
            if (line.startsWith('Description:')) {
              stats['os'] = line.replaceAll('Description:', '').trim();
            }
            break;

          case 'CPU_MODEL':
            if (line.startsWith('Model name:')) {
              stats['cpu_model'] = line.replaceAll('Model name:', '').trim();
            }
            break;

          case 'CPU_TEMP':
            if (line.isNotEmpty && line != "N/A") {
              final temp = double.tryParse(line)?.toDouble() ?? 0.0;
              stats['cpu_temperature'] = temp / 1000.0; 
            }
            break;

          case 'CPU_USAGE':
            if (line.contains('Average:') || line.contains('Durchschn.:')) {
                final parts = line.split(RegExp(r'\s+'));
                if (parts.length >= 12) {
                    String normalizeNumber(String value) {
                        return value.replaceAll(',', '.');
                    }

                    final values = parts.map((part) => normalizeNumber(part)).toList();
                    final startIndex = 2;

                    try {
                        stats['cpu_user'] = double.parse(values[startIndex]);
                        stats['cpu_nice'] = double.parse(values[startIndex + 1]);
                        stats['cpu_system'] = double.parse(values[startIndex + 2]);
                        stats['cpu_iowait'] = double.parse(values[startIndex + 3]);
                        stats['cpu_irq'] = double.parse(values[startIndex + 4]);
                        stats['cpu_soft'] = double.parse(values[startIndex + 5]);
                        stats['cpu_steal'] = double.parse(values[startIndex + 6]);
                        stats['cpu_guest'] = double.parse(values[startIndex + 7]);
                        stats['cpu_gnice'] = double.parse(values[startIndex + 8]);
                        stats['cpu_idle'] = double.parse(values[startIndex + 9]);

                        final combinedUsage = stats['cpu_user'] + 
                                            stats['cpu_nice'] + 
                                            stats['cpu_system'] + 
                                            stats['cpu_iowait'] + 
                                            stats['cpu_irq'] + 
                                            stats['cpu_soft'] + 
                                            stats['cpu_steal'] + 
                                            stats['cpu_guest'];
                        
                        stats['cpu'] = combinedUsage;
                        stats['cpu_combined'] = combinedUsage;
                    } catch (e) {
                        print('Error parsing CPU values: $e');
                        print('Raw values: ${parts.join(', ')}');
                    }
                }
            }
            break;

          case 'GPU_TEMP':
            if (line.contains('temp=')) {
              final temp = line.split('=')[1].replaceAll("'C", "");
              stats['gpu_temperature'] = double.tryParse(temp) ?? 0.0;
            }
            break;

          case 'MEM_INFO':
            if (line.startsWith('Mem:') || line.startsWith('Speicher')) {
                final memParts = line.split(RegExp(r'\s+'));
                if (line.startsWith('Speicher')) {
                    if (memParts.length >= 7) {
                        final total = double.parse(memParts[1]); 
                        final available = double.parse(memParts[6]); 
                        final actualUsed = total - available;
                        stats['memory'] = (actualUsed / total) * 100;
                        stats['memory_total'] = total;
                        stats['memory_used'] = actualUsed;
                    }
                } else {
                    if (memParts.length >= 7) {
                        final total = double.parse(memParts[1]);
                        final available = double.parse(memParts[6]);
                        final actualUsed = total - available;
                        stats['memory'] = (actualUsed / total) * 100;
                        stats['memory_total'] = total;
                        stats['memory_used'] = actualUsed;
                    }
                }
            }
            break;

          case 'DISK_INFO':
            if (stats['disks'] == null) {
              stats['disks'] = [];
            }
            if (line.startsWith('/dev/')) {
              final diskParts = line.split(RegExp(r'\s+'));
              if (diskParts.length >= 6) {
                (stats['disks'] as List).add({
                  'name': diskParts[0],
                  'size': diskParts[1],
                  'used': diskParts[2],
                  'available': diskParts[3],
                  'used_percentage': diskParts[4],
                  'mount_point': diskParts[5],
                });
              }
            } else if (line.startsWith('total')) {
              final totalParts = line.split(RegExp(r'\s+'));
              if (totalParts.length >= 4) {
                stats['total_disk_space'] = totalParts[1];
              }
            }
            break;

          case 'NETWORK_INFO':
            if (line.isNotEmpty && !line.contains('KB/s')) {
              final netParts = line.trim().split(RegExp(r'\s+'));
              if (netParts.length >= 2) {
                stats['network_in'] = double.tryParse(netParts[0]) ?? 0.0;
                stats['network_out'] = double.tryParse(netParts[1]) ?? 0.0;
              }
            }
            break;

          case 'SYSTEM_UPTIME':
            if (line.isNotEmpty) {
              final uptimeMatch = RegExp(r'up\s+(.*?)(,\s+\d+\s+user|\s+user)').firstMatch(line);
              if (uptimeMatch != null) {
                stats['uptime'] = uptimeMatch.group(1)?.trim() ?? 'Error';
              } else {
                final simpleMatch = RegExp(r'up\s+(.*?),').firstMatch(line);
                if (simpleMatch != null) {
                  stats['uptime'] = simpleMatch.group(1)?.trim() ?? 'Error';
                }
              }
            }
            break;
        }
      }
    } catch (e) {
      print('Error parsing stats: $e');
      return {
        'cpu': 0.0,
        'memory': 0.0,
        'temperature': 0.0,
        'error': e.toString()
      };
    }

    return stats;
  }

  void dispose() {
    _keepAliveTimer?.cancel();
    _connectionMonitor?.cancel();
    _connectionStatusController.close();
    _client?.close();
    _client = null;
  }

  void setKeepAliveInterval(int seconds) {
    _keepAliveInterval = seconds;
    if (_keepAliveTimer != null) {
      _keepAliveTimer!.cancel();
      _setupKeepAlive();
    }
  }

  void _setupKeepAlive() {
    if (_client == null || _keepAliveInterval <= 0) {
      return;
    }
    
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(Duration(seconds: _keepAliveInterval), (_) {
      if (_client != null && _client!.isClosed == false) {
        try {
          _client!.run('echo');
        } catch (e) {
          print('Keep-alive failed: $e');
        }
      }
    });
  }
}