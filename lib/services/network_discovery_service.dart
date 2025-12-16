import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DiscoveredDevice {
  final String name;
  final String host;
  final int port;
  final String? type;

  DiscoveredDevice({
    required this.name,
    required this.host,
    required this.port,
    this.type,
  });

  @override
  String toString() => '$name @ $host:$port';
}

class NetworkDiscoveryService {
  /// Scan the local network for ALL active devices (ping sweep)
  Future<List<DiscoveredDevice>> discoverSSHDevices({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final devices = <DiscoveredDevice>[];

    try {
      debugPrint('🔍 Starting network scan for all devices...');

      // Get local network info
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      
      if (wifiIP == null) {
        debugPrint('❌ Could not determine local IP address');
        return devices;
      }

      debugPrint('📱 Local IP: $wifiIP');

      // Parse the network base (e.g., "192.168.1.x" -> "192.168.1")
      final parts = wifiIP.split('.');
      if (parts.length != 4) {
        debugPrint('❌ Invalid IP format: $wifiIP');
        return devices;
      }
      
      final networkBase = '${parts[0]}.${parts[1]}.${parts[2]}';
      debugPrint('🌐 Scanning network: $networkBase.0/24');

      // Scan all IPs in parallel (1-254)
      final futures = <Future<DiscoveredDevice?>>[];
      for (int i = 1; i <= 254; i++) {
        final ip = '$networkBase.$i';
        futures.add(_checkHost(ip));
      }

      // Wait for all scans with timeout
      final results = await Future.wait(futures).timeout(
        timeout,
        onTimeout: () {
          debugPrint('⏱️ Scan timeout reached');
          return List.filled(futures.length, null);
        },
      );

      // Collect non-null results
      for (final device in results) {
        if (device != null) {
          devices.add(device);
        }
      }

      debugPrint('🔍 Scan complete. Found ${devices.length} active device(s)');
    } catch (e) {
      debugPrint('❌ Error during network scan: $e');
    }

    return devices;
  }

  /// Check if a host is reachable and get its details
  Future<DiscoveredDevice?> _checkHost(String ip) async {
    // Try multiple common ports to detect devices
    final portsToCheck = [22, 80, 443, 8080, 445, 139, 3389]; // SSH, HTTP, HTTPS, Alt-HTTP, SMB, RDP
    
    bool isReachable = false;
    int detectedPort = 22; // Default to SSH
    String deviceType = 'Unknown';

    // Try to connect to any of the common ports
    for (final port in portsToCheck) {
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(milliseconds: 500),
        );
        socket.destroy();
        isReachable = true;
        detectedPort = port;
        
        // Determine device type based on port
        switch (port) {
          case 22:
            deviceType = 'SSH Server';
            detectedPort = 22; // Force SSH port
            break;
          case 80:
          case 443:
          case 8080:
            deviceType = 'Web Server';
            break;
          case 445:
          case 139:
            deviceType = 'SMB/Windows';
            break;
          case 3389:
            deviceType = 'RDP/Windows';
            break;
        }
        break; // Stop after first successful connection
      } catch (_) {
        continue;
      }
    }

    if (!isReachable) {
      return null;
    }

    // Try to get hostname via reverse DNS lookup
    String hostname = ip;
    try {
      final addr = InternetAddress(ip);
      final result = await addr.reverse().timeout(const Duration(milliseconds: 800));
      if (result.host != ip && result.host.isNotEmpty) {
        hostname = result.host;
        // Clean up hostname
        if (hostname.endsWith('.local')) {
          hostname = hostname.substring(0, hostname.length - 6);
        }
      }
    } catch (e) {
      // Hostname lookup failed, use IP as name
      debugPrint('  Hostname lookup failed for $ip');
    }

    debugPrint('✓ Found device: $hostname ($ip) - $deviceType');

    return DiscoveredDevice(
      name: hostname,
      host: ip,
      port: detectedPort,
      type: deviceType,
    );
  }

  /// Quick ping check to see if a host is reachable
  Future<bool> isHostReachable(String host, {int port = 22, Duration timeout = const Duration(seconds: 2)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check status of multiple hosts in parallel
  Future<Map<String, bool>> checkHostsStatus(List<String> hosts, {int port = 22}) async {
    final results = <String, bool>{};
    
    await Future.wait(
      hosts.map((host) async {
        results[host] = await isHostReachable(host, port: port);
      }),
    );

    return results;
  }
}
