import 'package:grpc/grpc.dart';
import 'package:flutter/foundation.dart';
import '../generated/pi_control.pbgrpc.dart';

/// Service for communicating with the Go agent via gRPC
class GrpcService {
  ClientChannel? _channel;
  SystemMonitorClient? _client;

  /// Connect to the gRPC server (via SSH tunnel on localhost)
  Future<void> connect(int port) async {
    try {
      _channel = ClientChannel(
        'localhost',
        port: port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );

      _client = SystemMonitorClient(_channel!);

      debugPrint('gRPC connected to localhost:$port');
    } catch (e) {
      debugPrint('gRPC connection failed: $e');
      rethrow;
    }
  }

  /// Stream live system statistics
  /// Returns a stream of LiveStats updates every 500ms
  /// Automatically retries on connection failures
  Stream<LiveStats> streamStats() async* {
    if (_client == null) throw Exception('gRPC not connected');

    int retryCount = 0;
    const maxRetries = 3;
    const initialDelay = Duration(seconds: 2);

    while (true) {
      try {
        debugPrint('Starting stats stream (attempt ${retryCount + 1})');
        final stream = _client!.streamStats(Empty());
        retryCount = 0; // Reset retry count on successful connection
        
        await for (final stats in stream) {
          yield stats;
        }
        
        // If stream ends normally, break
        break;
      } catch (e) {
        debugPrint('Error streaming stats: $e');
        
        // Check if it's a connection error
        if (e is GrpcError && (e.code == 14 || e.code == 2)) {
          retryCount++;
          
          if (retryCount >= maxRetries) {
            debugPrint('Max retries reached, stopping reconnection attempts');
            rethrow;
          }
          
          // Exponential backoff
          final delay = initialDelay * (1 << (retryCount - 1));
          debugPrint('Connection lost, retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          continue;
        }
        
        // For other errors, rethrow immediately
        rethrow;
      }
    }
  }

  /// Get list of all processes
  Future<ProcessList> listProcesses() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.listProcesses(Empty());
  }

  /// Get list of all processes (alias for consistency)
  Future<ProcessList> getProcessList() async {
    return await listProcesses();
  }

  /// Kill a process by PID
  Future<ActionStatus> killProcess(int pid) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.killProcess(ProcessId()..pid = pid);
  }

  /// List all systemd services
  Future<ServiceList> listServices() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.listServices(Empty());
  }

  /// Manage a systemd service (start/stop/restart/enable/disable)
  Future<ActionStatus> manageService(String serviceName, ServiceAction action) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.manageService(
      ServiceCommand()
        ..serviceName = serviceName
        ..action = action,
    );
  }

  /// Stream system logs in real-time
  Stream<LogEntry> streamLogs({
    List<String>? levels,
    String? service,
    int? tailLines,
  }) async* {
    if (_client == null) throw Exception('gRPC not connected');

    final filter = LogFilter()
      ..levels.addAll(levels ?? [])
      ..service = service ?? ''
      ..tailLines = tailLines ?? 0;

    try {
      final stream = _client!.streamLogs(filter);
      await for (final entry in stream) {
        yield entry;
      }
    } catch (e) {
      debugPrint('Error streaming logs: $e');
      rethrow;
    }
  }

  /// Get disk usage information
  Future<DiskInfo> getDiskInfo() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getDiskInfo(Empty());
  }

  /// Get network interface information
  Future<NetworkInfo> getNetworkInfo() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getNetworkInfo(Empty());
  }

  /// Get active network connections
  Future<NetworkConnectionList> getNetworkConnections() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getNetworkConnections(Empty());
  }

  /// Check if the gRPC connection is alive
  bool get isConnected => _client != null && _channel != null;

  /// Disconnect from gRPC server
  Future<void> disconnect() async {
    await _channel?.shutdown();
    _channel = null;
    _client = null;
    debugPrint('gRPC disconnected');
  }
}
