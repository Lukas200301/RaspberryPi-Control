// This is a generated file - do not edit.
//
// Generated from pi_control.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'pi_control.pb.dart' as $0;

export 'pi_control.pb.dart';

@$pb.GrpcServiceName('picontrol.SystemMonitor')
class SystemMonitorClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SystemMonitorClient(super.channel, {super.options, super.interceptors});

  /// Stream real-time system statistics (CPU, RAM, temp, etc.)
  $grpc.ResponseStream<$0.LiveStats> streamStats(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamStats, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get list of all running processes
  $grpc.ResponseFuture<$0.ProcessList> listProcesses(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listProcesses, request, options: options);
  }

  /// Kill a specific process by PID
  $grpc.ResponseFuture<$0.ActionStatus> killProcess(
    $0.ProcessId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$killProcess, request, options: options);
  }

  /// Pause a specific process by PID (SIGSTOP)
  $grpc.ResponseFuture<$0.ActionStatus> pauseProcess(
    $0.ProcessId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pauseProcess, request, options: options);
  }

  /// Resume a specific process by PID (SIGCONT)
  $grpc.ResponseFuture<$0.ActionStatus> resumeProcess(
    $0.ProcessId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resumeProcess, request, options: options);
  }

  /// List all systemd services
  $grpc.ResponseFuture<$0.ServiceList> listServices(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listServices, request, options: options);
  }

  /// Control a systemd service (start/stop/restart/enable/disable)
  $grpc.ResponseFuture<$0.ActionStatus> manageService(
    $0.ServiceCommand request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$manageService, request, options: options);
  }

  /// Stream system logs in real-time
  $grpc.ResponseStream<$0.LogEntry> streamLogs(
    $0.LogFilter request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamLogs, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get disk usage information
  $grpc.ResponseFuture<$0.DiskInfo> getDiskInfo(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDiskInfo, request, options: options);
  }

  /// Get network interface information
  $grpc.ResponseFuture<$0.NetworkInfo> getNetworkInfo(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNetworkInfo, request, options: options);
  }

  /// Get active network connections
  $grpc.ResponseFuture<$0.NetworkConnectionList> getNetworkConnections(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNetworkConnections, request, options: options);
  }

  /// List installed packages (optionally filter)
  $grpc.ResponseFuture<$0.PackageList> listPackages(
    $0.PackageFilter request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPackages, request, options: options);
  }

  /// Install a package
  $grpc.ResponseFuture<$0.ActionStatus> installPackage(
    $0.PackageCommand request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$installPackage, request, options: options);
  }

  /// Remove a package
  $grpc.ResponseFuture<$0.ActionStatus> removePackage(
    $0.PackageCommand request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removePackage, request, options: options);
  }

  /// Update a specific package
  $grpc.ResponseFuture<$0.ActionStatus> updatePackage(
    $0.PackageCommand request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updatePackage, request, options: options);
  }

  /// Update package list (apt update)
  $grpc.ResponseFuture<$0.ActionStatus> updatePackageList(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updatePackageList, request, options: options);
  }

  /// Upgrade packages (apt upgrade)
  $grpc.ResponseFuture<$0.ActionStatus> upgradePackages(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$upgradePackages, request, options: options);
  }

  /// Get agent version
  $grpc.ResponseFuture<$0.VersionInfo> getVersion(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getVersion, request, options: options);
  }

  /// Get detailed package information
  $grpc.ResponseFuture<$0.PackageDetails> getPackageDetails(
    $0.PackageDetailsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPackageDetails, request, options: options);
  }

  /// Get package dependencies
  $grpc.ResponseFuture<$0.PackageDependencies> getPackageDependencies(
    $0.PackageDetailsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPackageDependencies, request,
        options: options);
  }

  /// Stream package operation logs (install/remove/update)
  $grpc.ResponseStream<$0.PackageOperationLog> streamPackageOperation(
    $0.PackageCommand request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamPackageOperation, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Network Tools
  /// Ping a host and stream results
  $grpc.ResponseStream<$0.PingResponse> pingHost(
    $0.PingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$pingHost, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Scan ports on a target host
  $grpc.ResponseStream<$0.PortScanResponse> scanPorts(
    $0.PortScanRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$scanPorts, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// DNS lookup
  $grpc.ResponseFuture<$0.DNSResponse> dNSLookup(
    $0.DNSRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$dNSLookup, request, options: options);
  }

  /// Traceroute to a host
  $grpc.ResponseStream<$0.TracerouteResponse> traceroute(
    $0.TracerouteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$traceroute, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get WiFi information
  $grpc.ResponseFuture<$0.WifiInfo> getWifiInfo(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getWifiInfo, request, options: options);
  }

  /// Test network speed (download/upload)
  $grpc.ResponseStream<$0.SpeedTestResponse> testNetworkSpeed(
    $0.SpeedTestRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$testNetworkSpeed, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// File Transfer
  /// Upload a file using streaming chunks
  $grpc.ResponseFuture<$0.FileUploadResponse> uploadFile(
    $async.Stream<$0.FileChunk> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$uploadFile, request, options: options).single;
  }

  /// Download a file as streaming chunks
  $grpc.ResponseStream<$0.FileChunk> downloadFile(
    $0.FileDownloadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$downloadFile, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Delete a file or directory
  $grpc.ResponseFuture<$0.FileDeleteResponse> deleteFile(
    $0.FileDeleteRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteFile, request, options: options);
  }

  /// System Updates
  /// Get system update status (OS info, kernel, upgradable packages)
  $grpc.ResponseFuture<$0.SystemUpdateStatus> getSystemUpdateStatus(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSystemUpdateStatus, request, options: options);
  }

  /// Stream system upgrade progress (apt update + apt upgrade)
  $grpc.ResponseStream<$0.UpgradeProgress> streamSystemUpgrade(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamSystemUpgrade, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$streamStats = $grpc.ClientMethod<$0.Empty, $0.LiveStats>(
      '/picontrol.SystemMonitor/StreamStats',
      ($0.Empty value) => value.writeToBuffer(),
      $0.LiveStats.fromBuffer);
  static final _$listProcesses = $grpc.ClientMethod<$0.Empty, $0.ProcessList>(
      '/picontrol.SystemMonitor/ListProcesses',
      ($0.Empty value) => value.writeToBuffer(),
      $0.ProcessList.fromBuffer);
  static final _$killProcess =
      $grpc.ClientMethod<$0.ProcessId, $0.ActionStatus>(
          '/picontrol.SystemMonitor/KillProcess',
          ($0.ProcessId value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$pauseProcess =
      $grpc.ClientMethod<$0.ProcessId, $0.ActionStatus>(
          '/picontrol.SystemMonitor/PauseProcess',
          ($0.ProcessId value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$resumeProcess =
      $grpc.ClientMethod<$0.ProcessId, $0.ActionStatus>(
          '/picontrol.SystemMonitor/ResumeProcess',
          ($0.ProcessId value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$listServices = $grpc.ClientMethod<$0.Empty, $0.ServiceList>(
      '/picontrol.SystemMonitor/ListServices',
      ($0.Empty value) => value.writeToBuffer(),
      $0.ServiceList.fromBuffer);
  static final _$manageService =
      $grpc.ClientMethod<$0.ServiceCommand, $0.ActionStatus>(
          '/picontrol.SystemMonitor/ManageService',
          ($0.ServiceCommand value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$streamLogs = $grpc.ClientMethod<$0.LogFilter, $0.LogEntry>(
      '/picontrol.SystemMonitor/StreamLogs',
      ($0.LogFilter value) => value.writeToBuffer(),
      $0.LogEntry.fromBuffer);
  static final _$getDiskInfo = $grpc.ClientMethod<$0.Empty, $0.DiskInfo>(
      '/picontrol.SystemMonitor/GetDiskInfo',
      ($0.Empty value) => value.writeToBuffer(),
      $0.DiskInfo.fromBuffer);
  static final _$getNetworkInfo = $grpc.ClientMethod<$0.Empty, $0.NetworkInfo>(
      '/picontrol.SystemMonitor/GetNetworkInfo',
      ($0.Empty value) => value.writeToBuffer(),
      $0.NetworkInfo.fromBuffer);
  static final _$getNetworkConnections =
      $grpc.ClientMethod<$0.Empty, $0.NetworkConnectionList>(
          '/picontrol.SystemMonitor/GetNetworkConnections',
          ($0.Empty value) => value.writeToBuffer(),
          $0.NetworkConnectionList.fromBuffer);
  static final _$listPackages =
      $grpc.ClientMethod<$0.PackageFilter, $0.PackageList>(
          '/picontrol.SystemMonitor/ListPackages',
          ($0.PackageFilter value) => value.writeToBuffer(),
          $0.PackageList.fromBuffer);
  static final _$installPackage =
      $grpc.ClientMethod<$0.PackageCommand, $0.ActionStatus>(
          '/picontrol.SystemMonitor/InstallPackage',
          ($0.PackageCommand value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$removePackage =
      $grpc.ClientMethod<$0.PackageCommand, $0.ActionStatus>(
          '/picontrol.SystemMonitor/RemovePackage',
          ($0.PackageCommand value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$updatePackage =
      $grpc.ClientMethod<$0.PackageCommand, $0.ActionStatus>(
          '/picontrol.SystemMonitor/UpdatePackage',
          ($0.PackageCommand value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$updatePackageList =
      $grpc.ClientMethod<$0.Empty, $0.ActionStatus>(
          '/picontrol.SystemMonitor/UpdatePackageList',
          ($0.Empty value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$upgradePackages =
      $grpc.ClientMethod<$0.Empty, $0.ActionStatus>(
          '/picontrol.SystemMonitor/UpgradePackages',
          ($0.Empty value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$getVersion = $grpc.ClientMethod<$0.Empty, $0.VersionInfo>(
      '/picontrol.SystemMonitor/GetVersion',
      ($0.Empty value) => value.writeToBuffer(),
      $0.VersionInfo.fromBuffer);
  static final _$getPackageDetails =
      $grpc.ClientMethod<$0.PackageDetailsRequest, $0.PackageDetails>(
          '/picontrol.SystemMonitor/GetPackageDetails',
          ($0.PackageDetailsRequest value) => value.writeToBuffer(),
          $0.PackageDetails.fromBuffer);
  static final _$getPackageDependencies =
      $grpc.ClientMethod<$0.PackageDetailsRequest, $0.PackageDependencies>(
          '/picontrol.SystemMonitor/GetPackageDependencies',
          ($0.PackageDetailsRequest value) => value.writeToBuffer(),
          $0.PackageDependencies.fromBuffer);
  static final _$streamPackageOperation =
      $grpc.ClientMethod<$0.PackageCommand, $0.PackageOperationLog>(
          '/picontrol.SystemMonitor/StreamPackageOperation',
          ($0.PackageCommand value) => value.writeToBuffer(),
          $0.PackageOperationLog.fromBuffer);
  static final _$pingHost = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/picontrol.SystemMonitor/PingHost',
      ($0.PingRequest value) => value.writeToBuffer(),
      $0.PingResponse.fromBuffer);
  static final _$scanPorts =
      $grpc.ClientMethod<$0.PortScanRequest, $0.PortScanResponse>(
          '/picontrol.SystemMonitor/ScanPorts',
          ($0.PortScanRequest value) => value.writeToBuffer(),
          $0.PortScanResponse.fromBuffer);
  static final _$dNSLookup = $grpc.ClientMethod<$0.DNSRequest, $0.DNSResponse>(
      '/picontrol.SystemMonitor/DNSLookup',
      ($0.DNSRequest value) => value.writeToBuffer(),
      $0.DNSResponse.fromBuffer);
  static final _$traceroute =
      $grpc.ClientMethod<$0.TracerouteRequest, $0.TracerouteResponse>(
          '/picontrol.SystemMonitor/Traceroute',
          ($0.TracerouteRequest value) => value.writeToBuffer(),
          $0.TracerouteResponse.fromBuffer);
  static final _$getWifiInfo = $grpc.ClientMethod<$0.Empty, $0.WifiInfo>(
      '/picontrol.SystemMonitor/GetWifiInfo',
      ($0.Empty value) => value.writeToBuffer(),
      $0.WifiInfo.fromBuffer);
  static final _$testNetworkSpeed =
      $grpc.ClientMethod<$0.SpeedTestRequest, $0.SpeedTestResponse>(
          '/picontrol.SystemMonitor/TestNetworkSpeed',
          ($0.SpeedTestRequest value) => value.writeToBuffer(),
          $0.SpeedTestResponse.fromBuffer);
  static final _$uploadFile =
      $grpc.ClientMethod<$0.FileChunk, $0.FileUploadResponse>(
          '/picontrol.SystemMonitor/UploadFile',
          ($0.FileChunk value) => value.writeToBuffer(),
          $0.FileUploadResponse.fromBuffer);
  static final _$downloadFile =
      $grpc.ClientMethod<$0.FileDownloadRequest, $0.FileChunk>(
          '/picontrol.SystemMonitor/DownloadFile',
          ($0.FileDownloadRequest value) => value.writeToBuffer(),
          $0.FileChunk.fromBuffer);
  static final _$deleteFile =
      $grpc.ClientMethod<$0.FileDeleteRequest, $0.FileDeleteResponse>(
          '/picontrol.SystemMonitor/DeleteFile',
          ($0.FileDeleteRequest value) => value.writeToBuffer(),
          $0.FileDeleteResponse.fromBuffer);
  static final _$getSystemUpdateStatus =
      $grpc.ClientMethod<$0.Empty, $0.SystemUpdateStatus>(
          '/picontrol.SystemMonitor/GetSystemUpdateStatus',
          ($0.Empty value) => value.writeToBuffer(),
          $0.SystemUpdateStatus.fromBuffer);
  static final _$streamSystemUpgrade =
      $grpc.ClientMethod<$0.Empty, $0.UpgradeProgress>(
          '/picontrol.SystemMonitor/StreamSystemUpgrade',
          ($0.Empty value) => value.writeToBuffer(),
          $0.UpgradeProgress.fromBuffer);
}

@$pb.GrpcServiceName('picontrol.SystemMonitor')
abstract class SystemMonitorServiceBase extends $grpc.Service {
  $core.String get $name => 'picontrol.SystemMonitor';

  SystemMonitorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.LiveStats>(
        'StreamStats',
        streamStats_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.LiveStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ProcessList>(
        'ListProcesses',
        listProcesses_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ProcessList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProcessId, $0.ActionStatus>(
        'KillProcess',
        killProcess_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ProcessId.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProcessId, $0.ActionStatus>(
        'PauseProcess',
        pauseProcess_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ProcessId.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProcessId, $0.ActionStatus>(
        'ResumeProcess',
        resumeProcess_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ProcessId.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ServiceList>(
        'ListServices',
        listServices_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ServiceList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ServiceCommand, $0.ActionStatus>(
        'ManageService',
        manageService_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ServiceCommand.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogFilter, $0.LogEntry>(
        'StreamLogs',
        streamLogs_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.LogFilter.fromBuffer(value),
        ($0.LogEntry value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DiskInfo>(
        'GetDiskInfo',
        getDiskInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DiskInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.NetworkInfo>(
        'GetNetworkInfo',
        getNetworkInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.NetworkInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.NetworkConnectionList>(
        'GetNetworkConnections',
        getNetworkConnections_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.NetworkConnectionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PackageFilter, $0.PackageList>(
        'ListPackages',
        listPackages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PackageFilter.fromBuffer(value),
        ($0.PackageList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PackageCommand, $0.ActionStatus>(
        'InstallPackage',
        installPackage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PackageCommand.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PackageCommand, $0.ActionStatus>(
        'RemovePackage',
        removePackage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PackageCommand.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PackageCommand, $0.ActionStatus>(
        'UpdatePackage',
        updatePackage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PackageCommand.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ActionStatus>(
        'UpdatePackageList',
        updatePackageList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ActionStatus>(
        'UpgradePackages',
        upgradePackages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.VersionInfo>(
        'GetVersion',
        getVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.VersionInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PackageDetailsRequest, $0.PackageDetails>(
        'GetPackageDetails',
        getPackageDetails_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PackageDetailsRequest.fromBuffer(value),
        ($0.PackageDetails value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PackageDetailsRequest, $0.PackageDependencies>(
            'GetPackageDependencies',
            getPackageDependencies_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PackageDetailsRequest.fromBuffer(value),
            ($0.PackageDependencies value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PackageCommand, $0.PackageOperationLog>(
        'StreamPackageOperation',
        streamPackageOperation_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.PackageCommand.fromBuffer(value),
        ($0.PackageOperationLog value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'PingHost',
        pingHost_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PortScanRequest, $0.PortScanResponse>(
        'ScanPorts',
        scanPorts_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.PortScanRequest.fromBuffer(value),
        ($0.PortScanResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DNSRequest, $0.DNSResponse>(
        'DNSLookup',
        dNSLookup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DNSRequest.fromBuffer(value),
        ($0.DNSResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TracerouteRequest, $0.TracerouteResponse>(
        'Traceroute',
        traceroute_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.TracerouteRequest.fromBuffer(value),
        ($0.TracerouteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.WifiInfo>(
        'GetWifiInfo',
        getWifiInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.WifiInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpeedTestRequest, $0.SpeedTestResponse>(
        'TestNetworkSpeed',
        testNetworkSpeed_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SpeedTestRequest.fromBuffer(value),
        ($0.SpeedTestResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FileChunk, $0.FileUploadResponse>(
        'UploadFile',
        uploadFile,
        true,
        false,
        ($core.List<$core.int> value) => $0.FileChunk.fromBuffer(value),
        ($0.FileUploadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FileDownloadRequest, $0.FileChunk>(
        'DownloadFile',
        downloadFile_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.FileDownloadRequest.fromBuffer(value),
        ($0.FileChunk value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FileDeleteRequest, $0.FileDeleteResponse>(
        'DeleteFile',
        deleteFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FileDeleteRequest.fromBuffer(value),
        ($0.FileDeleteResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.SystemUpdateStatus>(
        'GetSystemUpdateStatus',
        getSystemUpdateStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.SystemUpdateStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.UpgradeProgress>(
        'StreamSystemUpgrade',
        streamSystemUpgrade_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.UpgradeProgress value) => value.writeToBuffer()));
  }

  $async.Stream<$0.LiveStats> streamStats_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* streamStats($call, await $request);
  }

  $async.Stream<$0.LiveStats> streamStats(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ProcessList> listProcesses_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listProcesses($call, await $request);
  }

  $async.Future<$0.ProcessList> listProcesses(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ActionStatus> killProcess_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ProcessId> $request) async {
    return killProcess($call, await $request);
  }

  $async.Future<$0.ActionStatus> killProcess(
      $grpc.ServiceCall call, $0.ProcessId request);

  $async.Future<$0.ActionStatus> pauseProcess_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ProcessId> $request) async {
    return pauseProcess($call, await $request);
  }

  $async.Future<$0.ActionStatus> pauseProcess(
      $grpc.ServiceCall call, $0.ProcessId request);

  $async.Future<$0.ActionStatus> resumeProcess_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ProcessId> $request) async {
    return resumeProcess($call, await $request);
  }

  $async.Future<$0.ActionStatus> resumeProcess(
      $grpc.ServiceCall call, $0.ProcessId request);

  $async.Future<$0.ServiceList> listServices_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listServices($call, await $request);
  }

  $async.Future<$0.ServiceList> listServices(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ActionStatus> manageService_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ServiceCommand> $request) async {
    return manageService($call, await $request);
  }

  $async.Future<$0.ActionStatus> manageService(
      $grpc.ServiceCall call, $0.ServiceCommand request);

  $async.Stream<$0.LogEntry> streamLogs_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogFilter> $request) async* {
    yield* streamLogs($call, await $request);
  }

  $async.Stream<$0.LogEntry> streamLogs(
      $grpc.ServiceCall call, $0.LogFilter request);

  $async.Future<$0.DiskInfo> getDiskInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getDiskInfo($call, await $request);
  }

  $async.Future<$0.DiskInfo> getDiskInfo(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.NetworkInfo> getNetworkInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getNetworkInfo($call, await $request);
  }

  $async.Future<$0.NetworkInfo> getNetworkInfo(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.NetworkConnectionList> getNetworkConnections_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getNetworkConnections($call, await $request);
  }

  $async.Future<$0.NetworkConnectionList> getNetworkConnections(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.PackageList> listPackages_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PackageFilter> $request) async {
    return listPackages($call, await $request);
  }

  $async.Future<$0.PackageList> listPackages(
      $grpc.ServiceCall call, $0.PackageFilter request);

  $async.Future<$0.ActionStatus> installPackage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PackageCommand> $request) async {
    return installPackage($call, await $request);
  }

  $async.Future<$0.ActionStatus> installPackage(
      $grpc.ServiceCall call, $0.PackageCommand request);

  $async.Future<$0.ActionStatus> removePackage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PackageCommand> $request) async {
    return removePackage($call, await $request);
  }

  $async.Future<$0.ActionStatus> removePackage(
      $grpc.ServiceCall call, $0.PackageCommand request);

  $async.Future<$0.ActionStatus> updatePackage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PackageCommand> $request) async {
    return updatePackage($call, await $request);
  }

  $async.Future<$0.ActionStatus> updatePackage(
      $grpc.ServiceCall call, $0.PackageCommand request);

  $async.Future<$0.ActionStatus> updatePackageList_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return updatePackageList($call, await $request);
  }

  $async.Future<$0.ActionStatus> updatePackageList(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ActionStatus> upgradePackages_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return upgradePackages($call, await $request);
  }

  $async.Future<$0.ActionStatus> upgradePackages(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.VersionInfo> getVersion_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getVersion($call, await $request);
  }

  $async.Future<$0.VersionInfo> getVersion(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.PackageDetails> getPackageDetails_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PackageDetailsRequest> $request) async {
    return getPackageDetails($call, await $request);
  }

  $async.Future<$0.PackageDetails> getPackageDetails(
      $grpc.ServiceCall call, $0.PackageDetailsRequest request);

  $async.Future<$0.PackageDependencies> getPackageDependencies_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PackageDetailsRequest> $request) async {
    return getPackageDependencies($call, await $request);
  }

  $async.Future<$0.PackageDependencies> getPackageDependencies(
      $grpc.ServiceCall call, $0.PackageDetailsRequest request);

  $async.Stream<$0.PackageOperationLog> streamPackageOperation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PackageCommand> $request) async* {
    yield* streamPackageOperation($call, await $request);
  }

  $async.Stream<$0.PackageOperationLog> streamPackageOperation(
      $grpc.ServiceCall call, $0.PackageCommand request);

  $async.Stream<$0.PingResponse> pingHost_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PingRequest> $request) async* {
    yield* pingHost($call, await $request);
  }

  $async.Stream<$0.PingResponse> pingHost(
      $grpc.ServiceCall call, $0.PingRequest request);

  $async.Stream<$0.PortScanResponse> scanPorts_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PortScanRequest> $request) async* {
    yield* scanPorts($call, await $request);
  }

  $async.Stream<$0.PortScanResponse> scanPorts(
      $grpc.ServiceCall call, $0.PortScanRequest request);

  $async.Future<$0.DNSResponse> dNSLookup_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DNSRequest> $request) async {
    return dNSLookup($call, await $request);
  }

  $async.Future<$0.DNSResponse> dNSLookup(
      $grpc.ServiceCall call, $0.DNSRequest request);

  $async.Stream<$0.TracerouteResponse> traceroute_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TracerouteRequest> $request) async* {
    yield* traceroute($call, await $request);
  }

  $async.Stream<$0.TracerouteResponse> traceroute(
      $grpc.ServiceCall call, $0.TracerouteRequest request);

  $async.Future<$0.WifiInfo> getWifiInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getWifiInfo($call, await $request);
  }

  $async.Future<$0.WifiInfo> getWifiInfo(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Stream<$0.SpeedTestResponse> testNetworkSpeed_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SpeedTestRequest> $request) async* {
    yield* testNetworkSpeed($call, await $request);
  }

  $async.Stream<$0.SpeedTestResponse> testNetworkSpeed(
      $grpc.ServiceCall call, $0.SpeedTestRequest request);

  $async.Future<$0.FileUploadResponse> uploadFile(
      $grpc.ServiceCall call, $async.Stream<$0.FileChunk> request);

  $async.Stream<$0.FileChunk> downloadFile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FileDownloadRequest> $request) async* {
    yield* downloadFile($call, await $request);
  }

  $async.Stream<$0.FileChunk> downloadFile(
      $grpc.ServiceCall call, $0.FileDownloadRequest request);

  $async.Future<$0.FileDeleteResponse> deleteFile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FileDeleteRequest> $request) async {
    return deleteFile($call, await $request);
  }

  $async.Future<$0.FileDeleteResponse> deleteFile(
      $grpc.ServiceCall call, $0.FileDeleteRequest request);

  $async.Future<$0.SystemUpdateStatus> getSystemUpdateStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getSystemUpdateStatus($call, await $request);
  }

  $async.Future<$0.SystemUpdateStatus> getSystemUpdateStatus(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Stream<$0.UpgradeProgress> streamSystemUpgrade_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* streamSystemUpgrade($call, await $request);
  }

  $async.Stream<$0.UpgradeProgress> streamSystemUpgrade(
      $grpc.ServiceCall call, $0.Empty request);
}

@$pb.GrpcServiceName('picontrol.DockerService')
class DockerServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DockerServiceClient(super.channel, {super.options, super.interceptors});

  /// List containers
  $grpc.ResponseFuture<$0.ContainerList> listContainers(
    $0.DockerFilter request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listContainers, request, options: options);
  }

  /// Start a container
  $grpc.ResponseFuture<$0.ActionStatus> startContainer(
    $0.ContainerId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$startContainer, request, options: options);
  }

  /// Stop a container
  $grpc.ResponseFuture<$0.ActionStatus> stopContainer(
    $0.ContainerId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stopContainer, request, options: options);
  }

  /// Restart a container
  $grpc.ResponseFuture<$0.ActionStatus> restartContainer(
    $0.ContainerId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restartContainer, request, options: options);
  }

  /// Get container logs
  $grpc.ResponseStream<$0.LogEntry> getContainerLogs(
    $0.LogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$getContainerLogs, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Engine version and counts; fails when Docker is missing or not reachable
  $grpc.ResponseFuture<$0.DockerInfo> getDockerInfo(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDockerInfo, request, options: options);
  }

  /// Pause, unpause, kill or remove a container
  $grpc.ResponseFuture<$0.ActionStatus> containerAction(
    $0.ContainerActionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$containerAction, request, options: options);
  }

  /// Configuration and state of one container
  $grpc.ResponseFuture<$0.ContainerDetails> inspectContainer(
    $0.ContainerId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$inspectContainer, request, options: options);
  }

  /// One sample of a running container's resource usage
  $grpc.ResponseFuture<$0.ContainerStats> getContainerStats(
    $0.ContainerId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getContainerStats, request, options: options);
  }

  /// Images
  $grpc.ResponseFuture<$0.ImageList> listImages(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listImages, request, options: options);
  }

  $grpc.ResponseFuture<$0.ActionStatus> removeImage(
    $0.ImageRemoveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeImage, request, options: options);
  }

  /// Delete unused containers, images, volumes, networks or build cache
  $grpc.ResponseFuture<$0.PruneResult> prune(
    $0.PruneRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$prune, request, options: options);
  }

  // method descriptors

  static final _$listContainers =
      $grpc.ClientMethod<$0.DockerFilter, $0.ContainerList>(
          '/picontrol.DockerService/ListContainers',
          ($0.DockerFilter value) => value.writeToBuffer(),
          $0.ContainerList.fromBuffer);
  static final _$startContainer =
      $grpc.ClientMethod<$0.ContainerId, $0.ActionStatus>(
          '/picontrol.DockerService/StartContainer',
          ($0.ContainerId value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$stopContainer =
      $grpc.ClientMethod<$0.ContainerId, $0.ActionStatus>(
          '/picontrol.DockerService/StopContainer',
          ($0.ContainerId value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$restartContainer =
      $grpc.ClientMethod<$0.ContainerId, $0.ActionStatus>(
          '/picontrol.DockerService/RestartContainer',
          ($0.ContainerId value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$getContainerLogs =
      $grpc.ClientMethod<$0.LogRequest, $0.LogEntry>(
          '/picontrol.DockerService/GetContainerLogs',
          ($0.LogRequest value) => value.writeToBuffer(),
          $0.LogEntry.fromBuffer);
  static final _$getDockerInfo = $grpc.ClientMethod<$0.Empty, $0.DockerInfo>(
      '/picontrol.DockerService/GetDockerInfo',
      ($0.Empty value) => value.writeToBuffer(),
      $0.DockerInfo.fromBuffer);
  static final _$containerAction =
      $grpc.ClientMethod<$0.ContainerActionRequest, $0.ActionStatus>(
          '/picontrol.DockerService/ContainerAction',
          ($0.ContainerActionRequest value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$inspectContainer =
      $grpc.ClientMethod<$0.ContainerId, $0.ContainerDetails>(
          '/picontrol.DockerService/InspectContainer',
          ($0.ContainerId value) => value.writeToBuffer(),
          $0.ContainerDetails.fromBuffer);
  static final _$getContainerStats =
      $grpc.ClientMethod<$0.ContainerId, $0.ContainerStats>(
          '/picontrol.DockerService/GetContainerStats',
          ($0.ContainerId value) => value.writeToBuffer(),
          $0.ContainerStats.fromBuffer);
  static final _$listImages = $grpc.ClientMethod<$0.Empty, $0.ImageList>(
      '/picontrol.DockerService/ListImages',
      ($0.Empty value) => value.writeToBuffer(),
      $0.ImageList.fromBuffer);
  static final _$removeImage =
      $grpc.ClientMethod<$0.ImageRemoveRequest, $0.ActionStatus>(
          '/picontrol.DockerService/RemoveImage',
          ($0.ImageRemoveRequest value) => value.writeToBuffer(),
          $0.ActionStatus.fromBuffer);
  static final _$prune = $grpc.ClientMethod<$0.PruneRequest, $0.PruneResult>(
      '/picontrol.DockerService/Prune',
      ($0.PruneRequest value) => value.writeToBuffer(),
      $0.PruneResult.fromBuffer);
}

@$pb.GrpcServiceName('picontrol.DockerService')
abstract class DockerServiceBase extends $grpc.Service {
  $core.String get $name => 'picontrol.DockerService';

  DockerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.DockerFilter, $0.ContainerList>(
        'ListContainers',
        listContainers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DockerFilter.fromBuffer(value),
        ($0.ContainerList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ContainerId, $0.ActionStatus>(
        'StartContainer',
        startContainer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ContainerId.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ContainerId, $0.ActionStatus>(
        'StopContainer',
        stopContainer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ContainerId.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ContainerId, $0.ActionStatus>(
        'RestartContainer',
        restartContainer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ContainerId.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LogRequest, $0.LogEntry>(
        'GetContainerLogs',
        getContainerLogs_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.LogRequest.fromBuffer(value),
        ($0.LogEntry value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.DockerInfo>(
        'GetDockerInfo',
        getDockerInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.DockerInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ContainerActionRequest, $0.ActionStatus>(
        'ContainerAction',
        containerAction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ContainerActionRequest.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ContainerId, $0.ContainerDetails>(
        'InspectContainer',
        inspectContainer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ContainerId.fromBuffer(value),
        ($0.ContainerDetails value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ContainerId, $0.ContainerStats>(
        'GetContainerStats',
        getContainerStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ContainerId.fromBuffer(value),
        ($0.ContainerStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ImageList>(
        'ListImages',
        listImages_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ImageList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImageRemoveRequest, $0.ActionStatus>(
        'RemoveImage',
        removeImage_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ImageRemoveRequest.fromBuffer(value),
        ($0.ActionStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PruneRequest, $0.PruneResult>(
        'Prune',
        prune_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PruneRequest.fromBuffer(value),
        ($0.PruneResult value) => value.writeToBuffer()));
  }

  $async.Future<$0.ContainerList> listContainers_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DockerFilter> $request) async {
    return listContainers($call, await $request);
  }

  $async.Future<$0.ContainerList> listContainers(
      $grpc.ServiceCall call, $0.DockerFilter request);

  $async.Future<$0.ActionStatus> startContainer_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ContainerId> $request) async {
    return startContainer($call, await $request);
  }

  $async.Future<$0.ActionStatus> startContainer(
      $grpc.ServiceCall call, $0.ContainerId request);

  $async.Future<$0.ActionStatus> stopContainer_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ContainerId> $request) async {
    return stopContainer($call, await $request);
  }

  $async.Future<$0.ActionStatus> stopContainer(
      $grpc.ServiceCall call, $0.ContainerId request);

  $async.Future<$0.ActionStatus> restartContainer_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ContainerId> $request) async {
    return restartContainer($call, await $request);
  }

  $async.Future<$0.ActionStatus> restartContainer(
      $grpc.ServiceCall call, $0.ContainerId request);

  $async.Stream<$0.LogEntry> getContainerLogs_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LogRequest> $request) async* {
    yield* getContainerLogs($call, await $request);
  }

  $async.Stream<$0.LogEntry> getContainerLogs(
      $grpc.ServiceCall call, $0.LogRequest request);

  $async.Future<$0.DockerInfo> getDockerInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getDockerInfo($call, await $request);
  }

  $async.Future<$0.DockerInfo> getDockerInfo(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ActionStatus> containerAction_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ContainerActionRequest> $request) async {
    return containerAction($call, await $request);
  }

  $async.Future<$0.ActionStatus> containerAction(
      $grpc.ServiceCall call, $0.ContainerActionRequest request);

  $async.Future<$0.ContainerDetails> inspectContainer_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ContainerId> $request) async {
    return inspectContainer($call, await $request);
  }

  $async.Future<$0.ContainerDetails> inspectContainer(
      $grpc.ServiceCall call, $0.ContainerId request);

  $async.Future<$0.ContainerStats> getContainerStats_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ContainerId> $request) async {
    return getContainerStats($call, await $request);
  }

  $async.Future<$0.ContainerStats> getContainerStats(
      $grpc.ServiceCall call, $0.ContainerId request);

  $async.Future<$0.ImageList> listImages_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listImages($call, await $request);
  }

  $async.Future<$0.ImageList> listImages(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.ActionStatus> removeImage_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ImageRemoveRequest> $request) async {
    return removeImage($call, await $request);
  }

  $async.Future<$0.ActionStatus> removeImage(
      $grpc.ServiceCall call, $0.ImageRemoveRequest request);

  $async.Future<$0.PruneResult> prune_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PruneRequest> $request) async {
    return prune($call, await $request);
  }

  $async.Future<$0.PruneResult> prune(
      $grpc.ServiceCall call, $0.PruneRequest request);
}

/// PM2 is per-user: the agent runs PM2 as the user that started the agent
/// via sudo (SUDO_USER), so the app sees the same processes as `pm2 ls` over SSH.
@$pb.GrpcServiceName('picontrol.Pm2Service')
class Pm2ServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  Pm2ServiceClient(super.channel, {super.options, super.interceptors});

  /// PM2 installation, daemon, startup and dump status
  $grpc.ResponseFuture<$0.Pm2Info> getPm2Info(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPm2Info, request, options: options);
  }

  /// List all processes and modules (pm2 jlist)
  $grpc.ResponseFuture<$0.Pm2ProcessList> listPm2Processes(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listPm2Processes, request, options: options);
  }

  /// Full details of one process incl. environment (pm2 describe / pm2 env)
  $grpc.ResponseFuture<$0.Pm2ProcessDetails> describePm2Process(
    $0.Pm2Target request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$describePm2Process, request, options: options);
  }

  /// Start a script/binary, an ecosystem file or a static file server
  $grpc.ResponseFuture<$0.Pm2CommandResult> startPm2Process(
    $0.Pm2StartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$startPm2Process, request, options: options);
  }

  /// Act on existing process(es): restart, reload, stop, delete, scale, ...
  $grpc.ResponseFuture<$0.Pm2CommandResult> controlPm2Process(
    $0.Pm2ControlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$controlPm2Process, request, options: options);
  }

  /// Stream process log files (pm2 logs)
  $grpc.ResponseStream<$0.Pm2LogLine> streamPm2Logs(
    $0.Pm2LogRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamPm2Logs, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Daemon, persistence, startup, modules, config, deploy and diagnostics.
  /// Streams the command output, the last message has done = true.
  $grpc.ResponseStream<$0.Pm2OutputLine> runPm2Operation(
    $0.Pm2OperationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$runPm2Operation, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$getPm2Info = $grpc.ClientMethod<$0.Empty, $0.Pm2Info>(
      '/picontrol.Pm2Service/GetPm2Info',
      ($0.Empty value) => value.writeToBuffer(),
      $0.Pm2Info.fromBuffer);
  static final _$listPm2Processes =
      $grpc.ClientMethod<$0.Empty, $0.Pm2ProcessList>(
          '/picontrol.Pm2Service/ListPm2Processes',
          ($0.Empty value) => value.writeToBuffer(),
          $0.Pm2ProcessList.fromBuffer);
  static final _$describePm2Process =
      $grpc.ClientMethod<$0.Pm2Target, $0.Pm2ProcessDetails>(
          '/picontrol.Pm2Service/DescribePm2Process',
          ($0.Pm2Target value) => value.writeToBuffer(),
          $0.Pm2ProcessDetails.fromBuffer);
  static final _$startPm2Process =
      $grpc.ClientMethod<$0.Pm2StartRequest, $0.Pm2CommandResult>(
          '/picontrol.Pm2Service/StartPm2Process',
          ($0.Pm2StartRequest value) => value.writeToBuffer(),
          $0.Pm2CommandResult.fromBuffer);
  static final _$controlPm2Process =
      $grpc.ClientMethod<$0.Pm2ControlRequest, $0.Pm2CommandResult>(
          '/picontrol.Pm2Service/ControlPm2Process',
          ($0.Pm2ControlRequest value) => value.writeToBuffer(),
          $0.Pm2CommandResult.fromBuffer);
  static final _$streamPm2Logs =
      $grpc.ClientMethod<$0.Pm2LogRequest, $0.Pm2LogLine>(
          '/picontrol.Pm2Service/StreamPm2Logs',
          ($0.Pm2LogRequest value) => value.writeToBuffer(),
          $0.Pm2LogLine.fromBuffer);
  static final _$runPm2Operation =
      $grpc.ClientMethod<$0.Pm2OperationRequest, $0.Pm2OutputLine>(
          '/picontrol.Pm2Service/RunPm2Operation',
          ($0.Pm2OperationRequest value) => value.writeToBuffer(),
          $0.Pm2OutputLine.fromBuffer);
}

@$pb.GrpcServiceName('picontrol.Pm2Service')
abstract class Pm2ServiceBase extends $grpc.Service {
  $core.String get $name => 'picontrol.Pm2Service';

  Pm2ServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Pm2Info>(
        'GetPm2Info',
        getPm2Info_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Pm2Info value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Pm2ProcessList>(
        'ListPm2Processes',
        listPm2Processes_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Pm2ProcessList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Pm2Target, $0.Pm2ProcessDetails>(
        'DescribePm2Process',
        describePm2Process_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Pm2Target.fromBuffer(value),
        ($0.Pm2ProcessDetails value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Pm2StartRequest, $0.Pm2CommandResult>(
        'StartPm2Process',
        startPm2Process_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Pm2StartRequest.fromBuffer(value),
        ($0.Pm2CommandResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Pm2ControlRequest, $0.Pm2CommandResult>(
        'ControlPm2Process',
        controlPm2Process_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Pm2ControlRequest.fromBuffer(value),
        ($0.Pm2CommandResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Pm2LogRequest, $0.Pm2LogLine>(
        'StreamPm2Logs',
        streamPm2Logs_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Pm2LogRequest.fromBuffer(value),
        ($0.Pm2LogLine value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Pm2OperationRequest, $0.Pm2OutputLine>(
        'RunPm2Operation',
        runPm2Operation_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.Pm2OperationRequest.fromBuffer(value),
        ($0.Pm2OutputLine value) => value.writeToBuffer()));
  }

  $async.Future<$0.Pm2Info> getPm2Info_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getPm2Info($call, await $request);
  }

  $async.Future<$0.Pm2Info> getPm2Info(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Pm2ProcessList> listPm2Processes_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listPm2Processes($call, await $request);
  }

  $async.Future<$0.Pm2ProcessList> listPm2Processes(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Pm2ProcessDetails> describePm2Process_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Pm2Target> $request) async {
    return describePm2Process($call, await $request);
  }

  $async.Future<$0.Pm2ProcessDetails> describePm2Process(
      $grpc.ServiceCall call, $0.Pm2Target request);

  $async.Future<$0.Pm2CommandResult> startPm2Process_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.Pm2StartRequest> $request) async {
    return startPm2Process($call, await $request);
  }

  $async.Future<$0.Pm2CommandResult> startPm2Process(
      $grpc.ServiceCall call, $0.Pm2StartRequest request);

  $async.Future<$0.Pm2CommandResult> controlPm2Process_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.Pm2ControlRequest> $request) async {
    return controlPm2Process($call, await $request);
  }

  $async.Future<$0.Pm2CommandResult> controlPm2Process(
      $grpc.ServiceCall call, $0.Pm2ControlRequest request);

  $async.Stream<$0.Pm2LogLine> streamPm2Logs_Pre($grpc.ServiceCall $call,
      $async.Future<$0.Pm2LogRequest> $request) async* {
    yield* streamPm2Logs($call, await $request);
  }

  $async.Stream<$0.Pm2LogLine> streamPm2Logs(
      $grpc.ServiceCall call, $0.Pm2LogRequest request);

  $async.Stream<$0.Pm2OutputLine> runPm2Operation_Pre($grpc.ServiceCall $call,
      $async.Future<$0.Pm2OperationRequest> $request) async* {
    yield* runPm2Operation($call, await $request);
  }

  $async.Stream<$0.Pm2OutputLine> runPm2Operation(
      $grpc.ServiceCall call, $0.Pm2OperationRequest request);
}

@$pb.GrpcServiceName('picontrol.SystemAdmin')
class SystemAdminClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  SystemAdminClient(super.channel, {super.options, super.interceptors});

  /// Cron jobs of a user plus the system cron files (read only)
  $grpc.ResponseFuture<$0.Crontab> getCrontab(
    $0.CrontabRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCrontab, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommandOutput> setCrontab(
    $0.Crontab request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCrontab, request, options: options);
  }

  /// Runs a command once as a user (e.g. to test a cron job)
  $grpc.ResponseFuture<$0.CommandOutput> runAsUser(
    $0.RunAsUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$runAsUser, request, options: options);
  }

  /// Firewall (ufw)
  $grpc.ResponseFuture<$0.FirewallStatus> getFirewall(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFirewall, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommandOutput> firewallAction(
    $0.FirewallRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$firewallAction, request, options: options);
  }

  /// Users and groups
  $grpc.ResponseFuture<$0.UserList> listUsers(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listUsers, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommandOutput> userAction(
    $0.UserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$userAction, request, options: options);
  }

  /// Hardware and GPIO
  $grpc.ResponseFuture<$0.HardwareInfo> getHardwareInfo(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHardwareInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GpioState> getGpio(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getGpio, request, options: options);
  }

  $grpc.ResponseFuture<$0.CommandOutput> setGpio(
    $0.GpioRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setGpio, request, options: options);
  }

  /// Reboot / shutdown
  $grpc.ResponseFuture<$0.CommandOutput> power(
    $0.PowerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$power, request, options: options);
  }

  // method descriptors

  static final _$getCrontab = $grpc.ClientMethod<$0.CrontabRequest, $0.Crontab>(
      '/picontrol.SystemAdmin/GetCrontab',
      ($0.CrontabRequest value) => value.writeToBuffer(),
      $0.Crontab.fromBuffer);
  static final _$setCrontab = $grpc.ClientMethod<$0.Crontab, $0.CommandOutput>(
      '/picontrol.SystemAdmin/SetCrontab',
      ($0.Crontab value) => value.writeToBuffer(),
      $0.CommandOutput.fromBuffer);
  static final _$runAsUser =
      $grpc.ClientMethod<$0.RunAsUserRequest, $0.CommandOutput>(
          '/picontrol.SystemAdmin/RunAsUser',
          ($0.RunAsUserRequest value) => value.writeToBuffer(),
          $0.CommandOutput.fromBuffer);
  static final _$getFirewall = $grpc.ClientMethod<$0.Empty, $0.FirewallStatus>(
      '/picontrol.SystemAdmin/GetFirewall',
      ($0.Empty value) => value.writeToBuffer(),
      $0.FirewallStatus.fromBuffer);
  static final _$firewallAction =
      $grpc.ClientMethod<$0.FirewallRequest, $0.CommandOutput>(
          '/picontrol.SystemAdmin/FirewallAction',
          ($0.FirewallRequest value) => value.writeToBuffer(),
          $0.CommandOutput.fromBuffer);
  static final _$listUsers = $grpc.ClientMethod<$0.Empty, $0.UserList>(
      '/picontrol.SystemAdmin/ListUsers',
      ($0.Empty value) => value.writeToBuffer(),
      $0.UserList.fromBuffer);
  static final _$userAction =
      $grpc.ClientMethod<$0.UserRequest, $0.CommandOutput>(
          '/picontrol.SystemAdmin/UserAction',
          ($0.UserRequest value) => value.writeToBuffer(),
          $0.CommandOutput.fromBuffer);
  static final _$getHardwareInfo =
      $grpc.ClientMethod<$0.Empty, $0.HardwareInfo>(
          '/picontrol.SystemAdmin/GetHardwareInfo',
          ($0.Empty value) => value.writeToBuffer(),
          $0.HardwareInfo.fromBuffer);
  static final _$getGpio = $grpc.ClientMethod<$0.Empty, $0.GpioState>(
      '/picontrol.SystemAdmin/GetGpio',
      ($0.Empty value) => value.writeToBuffer(),
      $0.GpioState.fromBuffer);
  static final _$setGpio = $grpc.ClientMethod<$0.GpioRequest, $0.CommandOutput>(
      '/picontrol.SystemAdmin/SetGpio',
      ($0.GpioRequest value) => value.writeToBuffer(),
      $0.CommandOutput.fromBuffer);
  static final _$power = $grpc.ClientMethod<$0.PowerRequest, $0.CommandOutput>(
      '/picontrol.SystemAdmin/Power',
      ($0.PowerRequest value) => value.writeToBuffer(),
      $0.CommandOutput.fromBuffer);
}

@$pb.GrpcServiceName('picontrol.SystemAdmin')
abstract class SystemAdminServiceBase extends $grpc.Service {
  $core.String get $name => 'picontrol.SystemAdmin';

  SystemAdminServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CrontabRequest, $0.Crontab>(
        'GetCrontab',
        getCrontab_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CrontabRequest.fromBuffer(value),
        ($0.Crontab value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Crontab, $0.CommandOutput>(
        'SetCrontab',
        setCrontab_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Crontab.fromBuffer(value),
        ($0.CommandOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RunAsUserRequest, $0.CommandOutput>(
        'RunAsUser',
        runAsUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RunAsUserRequest.fromBuffer(value),
        ($0.CommandOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.FirewallStatus>(
        'GetFirewall',
        getFirewall_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.FirewallStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FirewallRequest, $0.CommandOutput>(
        'FirewallAction',
        firewallAction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FirewallRequest.fromBuffer(value),
        ($0.CommandOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.UserList>(
        'ListUsers',
        listUsers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.UserList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserRequest, $0.CommandOutput>(
        'UserAction',
        userAction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UserRequest.fromBuffer(value),
        ($0.CommandOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.HardwareInfo>(
        'GetHardwareInfo',
        getHardwareInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.HardwareInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.GpioState>(
        'GetGpio',
        getGpio_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.GpioState value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GpioRequest, $0.CommandOutput>(
        'SetGpio',
        setGpio_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GpioRequest.fromBuffer(value),
        ($0.CommandOutput value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PowerRequest, $0.CommandOutput>(
        'Power',
        power_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PowerRequest.fromBuffer(value),
        ($0.CommandOutput value) => value.writeToBuffer()));
  }

  $async.Future<$0.Crontab> getCrontab_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CrontabRequest> $request) async {
    return getCrontab($call, await $request);
  }

  $async.Future<$0.Crontab> getCrontab(
      $grpc.ServiceCall call, $0.CrontabRequest request);

  $async.Future<$0.CommandOutput> setCrontab_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Crontab> $request) async {
    return setCrontab($call, await $request);
  }

  $async.Future<$0.CommandOutput> setCrontab(
      $grpc.ServiceCall call, $0.Crontab request);

  $async.Future<$0.CommandOutput> runAsUser_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RunAsUserRequest> $request) async {
    return runAsUser($call, await $request);
  }

  $async.Future<$0.CommandOutput> runAsUser(
      $grpc.ServiceCall call, $0.RunAsUserRequest request);

  $async.Future<$0.FirewallStatus> getFirewall_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getFirewall($call, await $request);
  }

  $async.Future<$0.FirewallStatus> getFirewall(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.CommandOutput> firewallAction_Pre($grpc.ServiceCall $call,
      $async.Future<$0.FirewallRequest> $request) async {
    return firewallAction($call, await $request);
  }

  $async.Future<$0.CommandOutput> firewallAction(
      $grpc.ServiceCall call, $0.FirewallRequest request);

  $async.Future<$0.UserList> listUsers_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return listUsers($call, await $request);
  }

  $async.Future<$0.UserList> listUsers(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.CommandOutput> userAction_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UserRequest> $request) async {
    return userAction($call, await $request);
  }

  $async.Future<$0.CommandOutput> userAction(
      $grpc.ServiceCall call, $0.UserRequest request);

  $async.Future<$0.HardwareInfo> getHardwareInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getHardwareInfo($call, await $request);
  }

  $async.Future<$0.HardwareInfo> getHardwareInfo(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.GpioState> getGpio_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getGpio($call, await $request);
  }

  $async.Future<$0.GpioState> getGpio($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.CommandOutput> setGpio_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GpioRequest> $request) async {
    return setGpio($call, await $request);
  }

  $async.Future<$0.CommandOutput> setGpio(
      $grpc.ServiceCall call, $0.GpioRequest request);

  $async.Future<$0.CommandOutput> power_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.PowerRequest> $request) async {
    return power($call, await $request);
  }

  $async.Future<$0.CommandOutput> power(
      $grpc.ServiceCall call, $0.PowerRequest request);
}
