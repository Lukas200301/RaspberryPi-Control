import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:dartssh2/dartssh2.dart';
import '../main.dart';
import 'stats_controller.dart';  

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

  Future<void> connect() async {
    if (_client != null) return;
    try {
      if (_isReconnecting) return;
      _isReconnecting = true;
      
      final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
      _client = SSHClient(socket, username: username, onPasswordRequest: () => password);
      
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


    _keepAliveTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_client != null && !_isReconnecting) {
        try {
          await _client!.run('echo keepalive');
        } catch (e) {
          print('Keepalive failed: $e');
          await _handleReconnection();
        }
      }
    });


    _connectionMonitor = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (_client == null && !_isReconnecting) {
        await _handleReconnection();
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
    int retryCount = 0;
    const int maxRetries = 5;

    while (retryCount < maxRetries) {
      try {
        _client?.close();
        _client = null;
        final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
        _client = SSHClient(socket, username: username, onPasswordRequest: () => password);

        _isReconnecting = false;
        _connectionStatusController.add(true);
        print("Reconnection successful.");
        return;
      } catch (e) {
        retryCount++;
        print('Reconnection attempt $retryCount failed: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    _isReconnecting = false;
    print('Reconnection failed after $maxRetries attempts.');
  }


  bool isConnected() {
    return _client != null;
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
      
      _client!.close();
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

  Future<void> uploadFile(String localPath, String remotePath, [void Function(int, int)? onProgress]) async {
    if (_client == null) {
      await connect();
    }

    try {
      final file = File(localPath);
      final totalBytes = await file.length();
      int uploadedBytes = 0;

      final sftp = await _client!.sftp();
      final remoteFile = await sftp.open(remotePath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
      final controller = StreamController<Uint8List>();

      file.openRead().map((chunk) => Uint8List.fromList(chunk)).listen(
        (chunk) {
          uploadedBytes += chunk.length;
          if (onProgress != null) {
            onProgress(uploadedBytes, totalBytes);
          }
          controller.add(chunk);
        },
        onDone: () => controller.close(),
        onError: (error) {
          controller.addError(error);
          controller.close();
        },
      );

      await remoteFile.write(controller.stream);
      await remoteFile.close();
    } catch (e) {
      if (!_isReconnecting) {
        await _handleReconnection();
        return uploadFile(localPath, remotePath, onProgress);
      }
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> downloadFile(String remotePath, String localPath, [void Function(int, int)? onProgress]) async {
    if (_client == null) {
      await connect();
    }

    try {
      final sftp = await _client!.sftp();
      final remoteFile = await sftp.open(remotePath, mode: SftpFileOpenMode.read);
      final file = File(localPath);
      
      final stats = await remoteFile.stat();
      final totalSize = stats.size ?? 0;
      int downloadedSize = 0;

      final sink = file.openWrite();

      await for (final chunk in remoteFile.read()) { 
        sink.add(chunk);
        downloadedSize += chunk.length;

        if (onProgress != null && totalSize > 0) { 
          onProgress(downloadedSize, totalSize);
        }
      }

      await sink.flush();
      await sink.close();
      await remoteFile.close();
    } catch (e) {
      if (!_isReconnecting) {
        await _handleReconnection();
        return downloadFile(remotePath, localPath, onProgress);
      }
      throw Exception('Failed to download file: $e');
    }
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
            if (line.contains('Average:')) {
              final parts = line.split(RegExp(r'\s+'));
              if (parts.length >= 12) {
                final userCpu = double.tryParse(parts[3]) ?? 0.0;
                final niceCpu = double.tryParse(parts[4]) ?? 0.0;
                final systemCpu = double.tryParse(parts[5]) ?? 0.0;
                final iowaitCpu = double.tryParse(parts[6]) ?? 0.0;
                final irqCpu = double.tryParse(parts[7]) ?? 0.0;
                final softCpu = double.tryParse(parts[8]) ?? 0.0;
                final stealCpu = double.tryParse(parts[9]) ?? 0.0;
                final guestCpu = double.tryParse(parts[10]) ?? 0.0;
                final idleCpu = double.tryParse(parts[11]) ?? 0.0;

                stats['cpu_user'] = userCpu;
                stats['cpu_nice'] = niceCpu;
                stats['cpu_system'] = systemCpu;
                stats['cpu_iowait'] = iowaitCpu;
                stats['cpu_irq'] = irqCpu;
                stats['cpu_soft'] = softCpu;
                stats['cpu_steal'] = stealCpu;
                stats['cpu_guest'] = guestCpu;
                stats['cpu_idle'] = idleCpu;

                final combinedUsage = userCpu + niceCpu + systemCpu + 
                                    iowaitCpu + irqCpu + softCpu + 
                                    stealCpu + guestCpu;
                                    
                stats['cpu'] = combinedUsage;
                stats['cpu_combined'] = combinedUsage; 
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
            if (line.startsWith('Mem:')) {
              final memParts = line.split(RegExp(r'\s+'));
              if (memParts.length >= 7) {
                final total = double.parse(memParts[1]);
                final available = double.parse(memParts[6]);
                final actualUsed = total - available;
                stats['memory'] = (actualUsed / total) * 100;
                stats['memory_total'] = total;
                stats['memory_used'] = actualUsed;
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
              final uptimeMatch = RegExp(r'up\s+(.*?),').firstMatch(line);
              if (uptimeMatch != null) {
                stats['uptime'] = uptimeMatch.group(1)?.trim() ?? 'Error';
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
}