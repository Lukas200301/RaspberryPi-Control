import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';

class SSHService {
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;
  SSHClient? _client;

  SSHService({
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  Future<void> connect() async {
    if (_client != null) {
      print("Already connected to $host");
      return; 
    }
    try {
      final socket = await SSHSocket.connect(host, port, timeout: Duration(seconds: 10));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );
      print("Connected to $host");
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  bool isConnected() {
    return _client != null;
  }

  Future<String> executeCommand(String command) async {
    if (!isConnected()) {
      throw Exception('Not connected');
    }

    try {
      final session = await _client!.execute(command);
      final output = await utf8.decodeStream(session.stdout);
      session.close();
      return output;
    } catch (e) {
      if (e.toString().contains('SSHAuthFailError')) {
        throw Exception('Authentication failed: Please check your username and password.');
      } else {
        throw Exception('Failed to execute command: $e');
      }
    }
  }

  Future<void> uploadFile(String localPath, String remotePath, void Function(int, int) onProgress) async {
    if (!isConnected()) {
      throw Exception('Not connected');
    }

    try {
      final file = File(localPath);
      final fileStream = file.openRead().map((data) => Uint8List.fromList(data));

      final sftp = await _client!.sftp();
      final remoteFile = await sftp.open(remotePath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);

      int totalBytes = await file.length();
      int sentBytes = 0;

      final progressStream = fileStream.map((chunk) {
        sentBytes += chunk.length;
        onProgress(sentBytes, totalBytes); 
        return chunk;
      });

      await remoteFile.write(progressStream);
      await remoteFile.close();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> downloadFile(String remotePath, String localPath) async {
    if (!isConnected()) {
      throw Exception('Not connected');
    }

    RandomAccessFile? localFile;
    SftpFile? remoteFile;

    try {
      final file = File(localPath);
      localFile = await file.open(mode: FileMode.write);
      final sftp = await _client!.sftp();
      remoteFile = await sftp.open(remotePath, mode: SftpFileOpenMode.read);

      final stream = remoteFile.read();
      await for (final Uint8List chunk in stream) {
        if (chunk.isEmpty) break;
        await localFile.writeFrom(chunk);
      }

    } catch (e) {
      throw Exception('Failed to download file: $e');
    } finally {
      try {
        await remoteFile?.close();
        await localFile?.close();
      } catch (e) {
        print('Error closing files: $e');
      }
    }
  }

  Future<bool> checkRequiredPackages() async {
      try {
        final result = await executeCommand(
        'dpkg -l | grep -E "htop|iotop|sysstat|ifstat|nmon|libraspberrypi-bin"'
        );
        return result.contains('htop') &&
              result.contains('iotop') &&
              result.contains('sysstat') &&
              result.contains('ifstat') &&
              result.contains('nmon') &&
              result.contains('libraspberrypi-bin');
      } catch (e) {
        return false;
      }
    }

   Future<void> installRequiredPackages() async {
    await executeCommand('''
      sudo apt-get update 
      sudo apt-get install -y htop iotop sysstat ifstat nmon libraspberrypi-bin 
      sudo systemctl enable sysstat 
      sudo systemctl start sysstat
    ''');
  }

  Future<Map<String, dynamic>> getDetailedStats() async {
    final stats = <String, dynamic>{};

    try {
      final result = await executeCommand('''
        echo "===CPU_USAGE===" &&
        mpstat 1 1 | awk '/Average/ {print \$3}' &&
        echo "===CPU_TEMP===" &&
        cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null || echo "N/A" &&
        echo "===GPU_TEMP===" &&
        vcgencmd measure_temp 2>/dev/null || echo "N/A" &&
        echo "===MEM_INFO===" &&
        free -m &&
        echo "===SWAP_INFO===" &&
        free -m | grep Swap &&
        echo "===DISK_INFO===" &&
        df -h &&
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
          case 'CPU_USAGE':
            if (line.isNotEmpty) {
              stats['cpu'] = double.tryParse(line) ?? 0.0;
            }
            break;

          case 'MEM_INFO':
            if (line.startsWith('Mem:')) {
              final memParts = line.split(RegExp(r'\s+'));
              if (memParts.length >= 7) {
                final total = double.parse(memParts[1]);
                final used = double.parse(memParts[2]);
                stats['memory'] = (used / total) * 100;
                stats['memory_total'] = total;
                stats['memory_used'] = used;
              }
            }
            break;

          case 'CPU_TEMP':
            if (line.isNotEmpty && line != "N/A") {
              final temp = double.tryParse(line)?.toDouble() ?? 0.0;
              stats['cpu_temperature'] = temp / 1000.0;
            }
            break;

          case 'GPU_TEMP':
            if (line.contains('temp=')) {
              final temp = line.split('=')[1].replaceAll("'C", "");
              stats['gpu_temperature'] = double.tryParse(temp) ?? 0.0;
            }
            break;

          case 'DISK_INFO':
            if (line.startsWith('/dev/')) {
              final diskParts = line.split(RegExp(r'\s+'));
              if (diskParts.length >= 6) {
                final diskName = diskParts[0];
                final diskSize = diskParts[1];
                final diskUsed = diskParts[2];
                final diskAvailable = diskParts[3];
                final diskUsedPercentage = diskParts[4];
                stats['disks'] ??= [];
                stats['disks'].add({
                  'name': diskName,
                  'size': diskSize,
                  'used': diskUsed,
                  'available': diskAvailable,
                  'used_percentage': diskUsedPercentage,
                });
              }
            }
            break;

          case 'NETWORK_INFO':
            if (line.isNotEmpty) {
              final netParts = line.split(RegExp(r'\s+'));
              if (netParts.length >= 3) {
                stats['network_in'] = double.tryParse(netParts[0]) ?? 0.0;
                stats['network_out'] = double.tryParse(netParts[1]) ?? 0.0;
              }
            }
            break;

          case 'SYSTEM_UPTIME':
            if (line.isNotEmpty) {
              final uptimeMatch = RegExp(r'up\s+([^,]+)').firstMatch(line);
              if (uptimeMatch != null) {
                stats['uptime'] = uptimeMatch.group(1) ?? 'Error';
              } else {
                stats['uptime'] = 'Error';
              }
            }
            break;
        }
      }
    } catch (e) {
      print('Error getting detailed stats: $e');
      return {
        'cpu': 0.0,
        'memory': 0.0,
        'temperature': 0.0,
        'error': e.toString()
      };
    }

    return stats;
  }

  void disconnect() {
    if (_client != null) {
      print("Disconnecting from $host...");
      _client!.close();
      _client = null;
    }
  }
}