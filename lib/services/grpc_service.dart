import 'package:grpc/grpc.dart';
import 'package:flutter/foundation.dart';
import 'package:fixnum/fixnum.dart';
import '../generated/pi_control.pbgrpc.dart';

/// Service for communicating with the Go agent via gRPC
class GrpcService {
  ClientChannel? _channel;
  SystemMonitorClient? _client;

  ClientChannel? get channel => _channel;

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
    debugPrint('GrpcService.getDiskInfo() called');
    if (_client == null) {
      debugPrint('ERROR: gRPC client is null for getDiskInfo!');
      throw Exception('gRPC not connected');
    }
    debugPrint('Calling _client.getDiskInfo()...');
    final diskInfo = await _client!.getDiskInfo(Empty());
    debugPrint('getDiskInfo() returned ${diskInfo.partitions.length} partitions');
    return diskInfo;
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

  /// List packages (installed or searchable)
  Future<PackageList> listPackages({String? searchTerm, bool installedOnly = true}) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.listPackages(
      PackageFilter()
        ..searchTerm = searchTerm ?? ''
        ..installedOnly = installedOnly,
    );
  }

  /// Install a package
  Future<ActionStatus> installPackage(String packageName) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.installPackage(PackageCommand()..packageName = packageName);
  }

  /// Remove a package
  Future<ActionStatus> removePackage(String packageName) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.removePackage(PackageCommand()..packageName = packageName);
  }

  /// Update a specific package
  Future<ActionStatus> updatePackage(String packageName) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.updatePackage(PackageCommand()..packageName = packageName);
  }

  /// Update package list (apt update)
  Future<ActionStatus> updatePackageList() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.updatePackageList(Empty());
  }

  /// Upgrade packages (apt upgrade)
  Future<ActionStatus> upgradePackages() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.upgradePackages(Empty());
  }

  /// Get agent version
  Future<VersionInfo> getVersion() async {
    debugPrint('GrpcService.getVersion() called');
    if (_client == null) {
      debugPrint('ERROR: gRPC client is null!');
      throw Exception('gRPC not connected');
    }
    debugPrint('Calling _client.getVersion()...');
    final version = await _client!.getVersion(Empty());
    debugPrint('getVersion() returned: ${version.version}');
    return version;
  }

  /// Get detailed package information
  Future<PackageDetails> getPackageDetails(String packageName) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getPackageDetails(PackageDetailsRequest()..packageName = packageName);
  }

  /// Get package dependencies
  Future<PackageDependencies> getPackageDependencies(String packageName) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getPackageDependencies(PackageDetailsRequest()..packageName = packageName);
  }

  /// Stream package operation logs
  Stream<PackageOperationLog> streamPackageOperation(String packageName) async* {
    if (_client == null) throw Exception('gRPC not connected');

    final stream = _client!.streamPackageOperation(PackageCommand()..packageName = packageName);
    await for (final log in stream) {
      yield log;
    }
  }

  /// Check if the gRPC connection is alive
  bool get isConnected => _client != null && _channel != null;

  // ==================== Network Tools ====================

  // ==================== System Updates ====================

  /// Get system update status (OS info, kernel, upgradable packages)
  Future<SystemUpdateStatus> getSystemUpdateStatus() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getSystemUpdateStatus(Empty());
  }

  /// Stream system upgrade progress (apt update + apt upgrade)
  Stream<UpgradeProgress> streamSystemUpgrade() async* {
    if (_client == null) throw Exception('gRPC not connected');
    final stream = _client!.streamSystemUpgrade(Empty());
    await for (final progress in stream) {
      yield progress;
    }
  }

  // ==================== Network Tools (continued) ====================

  /// Ping a host and stream results
  Stream<PingResponse> pingHost(PingRequest request) async* {
    if (_client == null) throw Exception('gRPC not connected');
    final stream = _client!.pingHost(request);
    await for (final response in stream) {
      yield response;
    }
  }

  /// Scan ports on a target host
  Stream<PortScanResponse> scanPorts(PortScanRequest request) async* {
    if (_client == null) throw Exception('gRPC not connected');
    final stream = _client!.scanPorts(request);
    await for (final response in stream) {
      yield response;
    }
  }

  /// DNS lookup
  Future<DNSResponse> dnsLookup(DNSRequest request) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.dNSLookup(request);
  }

  /// Traceroute to a host
  Stream<TracerouteResponse> traceroute(TracerouteRequest request) async* {
    if (_client == null) throw Exception('gRPC not connected');
    final stream = _client!.traceroute(request);
    await for (final response in stream) {
      yield response;
    }
  }

  /// Get WiFi information
  Future<WifiInfo> getWifiInfo() async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.getWifiInfo(Empty());
  }

  /// Test network speed (download/upload)
  Stream<SpeedTestResponse> testNetworkSpeed(SpeedTestRequest request) async* {
    if (_client == null) throw Exception('gRPC not connected');
    final stream = _client!.testNetworkSpeed(request);
    await for (final response in stream) {
      yield response;
    }
  }

  // ==================== File Transfer ====================

  /// Upload a file via streaming chunks
  /// Returns the upload response with success status and bytes written
  Future<FileUploadResponse> uploadFileStream(Stream<FileChunk> chunkStream) async {
    if (_client == null) throw Exception('gRPC not connected');
    return await _client!.uploadFile(chunkStream);
  }

  /// Download a file as streaming chunks
  /// Use offset > 0 to resume a partial download
  Stream<FileChunk> downloadFileStream(String remotePath, {int offset = 0}) async* {
    if (_client == null) throw Exception('gRPC not connected');
    final request = FileDownloadRequest()
      ..path = remotePath
      ..offset = Int64(offset);
    
    final stream = _client!.downloadFile(request);
    await for (final chunk in stream) {
      yield chunk;
    }
  }

  /// Delete a file or directory
  /// Set isDirectory to true to recursively delete a directory
  Future<FileDeleteResponse> deleteFile(String remotePath, {bool isDirectory = false}) async {
    if (_client == null) throw Exception('gRPC not connected');
    final request = FileDeleteRequest()
      ..path = remotePath
      ..isDirectory = isDirectory;
    
    return await _client!.deleteFile(request);
  }

  /// Disconnect from gRPC server
  Future<void> disconnect() async {
    await _channel?.shutdown();
    _channel = null;
    _client = null;
    debugPrint('gRPC disconnected');
  }
}
