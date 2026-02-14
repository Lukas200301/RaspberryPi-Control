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
}
