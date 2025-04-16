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
  bool _connectionLost = false;
  int _consecutiveFailures = 0;
  static const int MAX_CONSECUTIVE_FAILURES = 3;
  final _reconnectionLock = Object(); 

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

    _keepAliveTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_client != null && !_isReconnecting) {
        try {
          await _client!.run('echo keepalive');
          _consecutiveFailures = 0;
          
          if (_connectionLost) {
            _connectionLost = false;
            _connectionStatusController.add(true);
            print("Connection restored via keepalive check");
          }
        } catch (e) {
          print('Keepalive failed: $e');
          _consecutiveFailures++;
          
          if (_consecutiveFailures >= MAX_CONSECUTIVE_FAILURES && !_isReconnecting) {
            _connectionLost = true;
            _connectionStatusController.add(false);
            Future.microtask(() => _handleReconnection());
          }
        }
      }
    });

    _connectionMonitor = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_client == null && !_isReconnecting) {
        print("Connection monitor detected null client. Attempting reconnection...");
        _connectionLost = true;
        _connectionStatusController.add(false);
        Future.microtask(() => _handleReconnection());
      }
    });
  }

  Future<void> handleAppResume() async {
    if (!isConnected()) {
      print("App resumed: Reconnecting...");
      await reconnect();
    }
  }

  Future<T> synchronized<T>(Object lock, Future<T> Function() callback) async {
    if (_isReconnecting) {
      throw Exception('Connection operation in progress');
    }
    return callback();
  }

  Future<void> _handleReconnection() async {
    await synchronized(
      _reconnectionLock,
      () async {
        if (_isReconnecting) {
          print("Reconnection already in progress, skipping duplicate attempt");
          return;
        }
        
        _isReconnecting = true;
        print("Starting reconnection process...");
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final autoReconnect = prefs.getBool('autoReconnect') ?? true;
          
          if (!autoReconnect) {
            print('Auto-reconnect disabled in settings');
            _isReconnecting = false;
            return;
          }
          
          int retryCount = 0;
          const int maxReconnectAttempts = 3; 
          
          while (retryCount < maxReconnectAttempts) {
            try {
              _client?.close();
              _client = null;
              
              print("Reconnection attempt ${retryCount + 1}...");
              final socket = await SSHSocket.connect(
                host, 
                port,
                timeout: const Duration(seconds: 5), 
              );
              
              _client = SSHClient(
                socket, 
                username: username, 
                onPasswordRequest: () => password
              );
              
              await _client!.run('echo test');
              
              _isReconnecting = false;
              _connectionLost = false;
              _consecutiveFailures = 0;
              _connectionStatusController.add(true);
              print("Reconnection successful");
              
              return;
            } catch (e) {
              retryCount++;
              print('Reconnection attempt $retryCount failed: $e');
              
              final delay = _connectionRetryDelay;
              await Future.delayed(Duration(seconds: delay)); 
            }
          }
          
          print('Reconnection failed after $maxReconnectAttempts attempts');
        } finally {
          _isReconnecting = false;
        }
      }
    );
  }

  bool isConnected() {
    return _client != null;
  }

  void disconnect() async {
    if (_client != null) {
      StatsController.instance.stopStatsMonitoring(); 
      
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
    if (!isConnected()) {
      _isReconnecting = true;
      try {
        await connect();
      } finally {
        _isReconnecting = false;
      }
    }
  }

  Future<String> executeCommand(String command) async {
    if (_client == null) {
      print("No SSH client available. Attempting to connect...");
      try {
        await connect();
      } catch (e) {
        print("Connection attempt failed: $e");
        throw Exception('Failed to establish SSH connection: $e');
      }
    }

    try {
      final result = await _client!.run(command);
      return utf8.decode(result);
    } catch (e) {
      print("Command execution failed: $e");
      
      if (e.toString().contains('closed') || 
          e.toString().contains('not connected') ||
          e.toString().contains('socket')) {
        
        print("Network error detected in command execution");
        if (!_isReconnecting) {
          _connectionLost = true;
          _connectionStatusController.add(false);
          
          throw Exception('Connection lost: $e');
        }
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
      'dpkg -l | grep -E "htop|iotop|sysstat|ifstat|nmon|libraspberrypi-bin|lsb-release|lynis"'
      );
      return result.contains('htop') &&
            result.contains('iotop') &&
            result.contains('sysstat') &&
            result.contains('ifstat') &&
            result.contains('nmon') &&
            result.contains('lsb-release') &&
            result.contains('libraspberrypi-bin') &&
            result.contains('lynis');
    } catch (e) {
      return false;
    }
  }

  Future<void> installRequiredPackages() async {
    await executeCommand('''
      sudo apt-get update 
      sudo apt-get install -y htop iotop sysstat ifstat nmon libraspberrypi-bin lsb-release lynis
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
        echo "===KERNEL_INFO===" &&
        uname -r &&
        echo "===BOOT_INFO===" &&
        who -b &&
        systemd-analyze 2>/dev/null || echo "N/A" &&
        echo "===CPU_MODEL===" &&
        lscpu | grep 'Model name' &&
        echo "===CPU_USAGE===" &&
        mpstat 1 1 &&
        echo "===CPU_FREQ===" &&
        cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null || echo "N/A" &&
        echo "===CPU_TEMP===" &&
        cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null || echo "N/A" &&
        echo "===GPU_TEMP===" &&
        vcgencmd measure_temp 2>/dev/null || echo "N/A" &&
        echo "===VOLTAGE===" &&
        vcgencmd measure_volts 2>/dev/null || echo "N/A" &&
        echo "===THROTTLING===" &&
        vcgencmd get_throttled 2>/dev/null || echo "N/A" &&
        echo "===MEM_INFO===" &&
        free -m &&
        echo "===DISK_INFO===" &&
        df -h --total &&
        echo "===DISK_IO===" &&
        iostat -d -k 1 1 2>/dev/null || echo "N/A" &&
        echo "===TOP_PROCESSES===" &&
        ps aux --sort=-%cpu | head -6 &&
        echo "===NETWORK_INFO===" &&
        ifstat -T 1 1 | tail -n 1 &&
        echo "===PING_STATS===" &&
        ping -c 1 -W 1 8.8.8.8 2>/dev/null || echo "N/A" &&
        echo "===WIFI_INFO===" &&
        iwconfig wlan0 2>/dev/null || echo "N/A" &&
        echo "===SYSTEM_UPTIME===" &&
        uptime &&
        echo "===SECURITY_INFO===" &&
        sudo lynis audit system --no-colors --quiet || echo "LYNIS_NOT_AVAILABLE" &&
        echo "===LYNIS_REPORT===" &&
        sudo cat /var/log/lynis.log 2>/dev/null || cat /tmp/lynis-report.dat 2>/dev/null || echo "REPORT_NOT_AVAILABLE" &&
        echo "===OPEN_PORTS===" &&
        netstat -tuln 2>/dev/null | grep "LISTEN" | awk '{print \$4}' | awk -F: '{print \$NF}' | sort -n | uniq || echo "N/A" &&
        echo "===SYSTEM_LOGS===" &&
        journalctl -p 3 --no-pager -n 5 2>/dev/null || echo "N/A"
      ''');
      
      final sections = result.split('\n');
      String currentSection = '';
      
      stats['boot_stats'] = {
        'last_boot': 'Unknown',
        'boot_time': 'N/A',
        'kernel_time': 'N/A',
        'systemd_time': 'N/A'
      };
      
      stats['disk_io'] = {
        'read_bytes_per_sec': 0.0,
        'write_bytes_per_sec': 0.0,
        'iops_read': 0,
        'iops_write': 0,
        'total_read': 'N/A',
        'total_write': 'N/A'
      };
      
      stats['security_info'] = {
        'warnings': [],
        'suggestions': [],
        'open_ports': [],
        'hardening_index': 0,
        'vulnerable_packages': 0,
        'updates_available': 0,
        'security_updates': 0,
        'firewall_status': 'Unknown',
        'failed_logins': 0
      };

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

          case 'CPU_FREQ':
            if (line.isNotEmpty && line != "N/A") {
              final freq = double.tryParse(line)?.toDouble() ?? 0.0;
              stats['cpu_frequency'] = freq / 1000.0; 
            }
            break;

          case 'GPU_TEMP':
            if (line.contains('temp=')) {
              final temp = line.split('=')[1].replaceAll("'C", "");
              stats['gpu_temperature'] = double.tryParse(temp) ?? 0.0;
            }
            break;

          case 'VOLTAGE':
            if (line.contains('volt=')) {
              final voltage = line.split('=')[1].replaceAll("V", "");
              stats['core_voltage'] = double.tryParse(voltage) ?? 0.0;
            }
            break;

          case 'THROTTLING':
            if (line.contains('throttled=')) {
              final throttleHex = line.split('=')[1];
              final throttleValue = int.tryParse(throttleHex, radix: 16) ?? 0;
              stats['throttling'] = throttleValue != 0;
              stats['throttling_status'] = _decodeThrottlingStatus(throttleValue);
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

          case 'TOP_PROCESSES':
            if (stats['top_processes'] == null) {
              stats['top_processes'] = [];
            }
            if (line.isNotEmpty && !line.startsWith('USER')) {
              final parts = line.split(RegExp(r'\s+'));
              if (parts.length >= 11) {
                (stats['top_processes'] as List).add({
                  'user': parts[0],
                  'pid': parts[1],
                  'cpu': double.tryParse(parts[2]) ?? 0.0,
                  'memory': double.tryParse(parts[3]) ?? 0.0,
                  'command': parts.sublist(10).join(' '),
                });
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

          case 'PING_STATS':
            if (line.contains('time=')) {
              final timeMatch = RegExp(r'time=(\d+\.?\d*) ms').firstMatch(line);
              if (timeMatch != null) {
                stats['ping_latency'] = double.tryParse(timeMatch.group(1) ?? '0') ?? 0.0;
              }
            }
            break;

          case 'WIFI_INFO':
            if (line.contains('Signal level')) {
              final signalMatch = RegExp(r'Signal level=(-\d+) dBm').firstMatch(line);
              if (signalMatch != null) {
                final signalDbm = int.tryParse(signalMatch.group(1) ?? '0') ?? 0;
                stats['wifi_signal_dbm'] = signalDbm;
                stats['wifi_signal_percent'] = _calculateWifiStrength(signalDbm);
              }
            } else if (line.contains('ESSID')) {
              final essidMatch = RegExp(r'ESSID:"(.*?)"').firstMatch(line);
              if (essidMatch != null) {
                stats['wifi_ssid'] = essidMatch.group(1);
              }
            } else if (line.contains('Bit Rate')) {
              final bitrateMatch = RegExp(r'Bit Rate=(\d+\.?\d*) (\w+/s)').firstMatch(line);
              if (bitrateMatch != null) {
                stats['wifi_bitrate'] = '${bitrateMatch.group(1)} ${bitrateMatch.group(2)}';
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

          case 'SYSTEM_LOGS':
            if (stats['system_logs'] == null) {
              stats['system_logs'] = [];
            }
            if (line.isNotEmpty && !line.contains('N/A')) {
              (stats['system_logs'] as List).add(line);
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
  
  int _calculateWifiStrength(int dbm) {
    if (dbm >= -50) {
      return 100;
    } else if (dbm >= -60) {
      return 90;
    } else if (dbm >= -70) {
      return 70;
    } else if (dbm >= -80) {
      return 50;
    } else if (dbm >= -90) {
      return 30;
    } else {
      return 10;
    }
  }
  
  Map<String, bool> _decodeThrottlingStatus(int throttleValue) {
    return {
      'under_voltage': (throttleValue & 0x1) != 0,
      'freq_capped': (throttleValue & 0x2) != 0,
      'throttled': (throttleValue & 0x4) != 0,
      'under_voltage_occurred': (throttleValue & 0x10000) != 0,
      'freq_capped_occurred': (throttleValue & 0x20000) != 0,
      'throttled_occurred': (throttleValue & 0x40000) != 0,
    };
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
          _client!.run('echo').then((_) {
            _consecutiveFailures = 0;
          }).catchError((e) {
            print('Keep-alive failed: $e');
            _consecutiveFailures++;
            
            if (_consecutiveFailures >= MAX_CONSECUTIVE_FAILURES && !_connectionLost) {
              _connectionLost = true;
              _handleReconnection();
            }
          });
        } catch (e) {
          print('Keep-alive setup error: $e');
        }
      }
    });
  }
}

bool matchesPattern(String text, RegExp pattern) {
  return pattern.hasMatch(text);
}