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
}
