// This is a generated file - do not edit.
//
// Generated from pi_control.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'pi_control.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'pi_control.pbenum.dart';

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @$core.override
  Empty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

/// Real-time system statistics
class LiveStats extends $pb.GeneratedMessage {
  factory LiveStats({
    $core.double? cpuUsage,
    $core.Iterable<$core.double>? cpuPerCore,
    $fixnum.Int64? ramUsed,
    $fixnum.Int64? ramTotal,
    $fixnum.Int64? ramFree,
    $fixnum.Int64? ramCached,
    $fixnum.Int64? swapUsed,
    $fixnum.Int64? swapTotal,
    $core.double? cpuTemp,
    $core.double? gpuTemp,
    $fixnum.Int64? uptime,
    $core.double? load1min,
    $core.double? load5min,
    $core.double? load15min,
    $fixnum.Int64? netBytesSent,
    $fixnum.Int64? netBytesRecv,
    $core.Iterable<ProcessInfo>? topProcesses,
    $fixnum.Int64? timestamp,
    $core.Iterable<DiskIOStat>? diskIo,
  }) {
    final result = create();
    if (cpuUsage != null) result.cpuUsage = cpuUsage;
    if (cpuPerCore != null) result.cpuPerCore.addAll(cpuPerCore);
    if (ramUsed != null) result.ramUsed = ramUsed;
    if (ramTotal != null) result.ramTotal = ramTotal;
    if (ramFree != null) result.ramFree = ramFree;
    if (ramCached != null) result.ramCached = ramCached;
    if (swapUsed != null) result.swapUsed = swapUsed;
    if (swapTotal != null) result.swapTotal = swapTotal;
    if (cpuTemp != null) result.cpuTemp = cpuTemp;
    if (gpuTemp != null) result.gpuTemp = gpuTemp;
    if (uptime != null) result.uptime = uptime;
    if (load1min != null) result.load1min = load1min;
    if (load5min != null) result.load5min = load5min;
    if (load15min != null) result.load15min = load15min;
    if (netBytesSent != null) result.netBytesSent = netBytesSent;
    if (netBytesRecv != null) result.netBytesRecv = netBytesRecv;
    if (topProcesses != null) result.topProcesses.addAll(topProcesses);
    if (timestamp != null) result.timestamp = timestamp;
    if (diskIo != null) result.diskIo.addAll(diskIo);
    return result;
  }

  LiveStats._();

  factory LiveStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LiveStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LiveStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'cpuUsage')
    ..p<$core.double>(
        2, _omitFieldNames ? '' : 'cpuPerCore', $pb.PbFieldType.KD)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'ramUsed', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'ramTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'ramFree', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'ramCached', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'swapUsed', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'swapTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(9, _omitFieldNames ? '' : 'cpuTemp')
    ..aD(10, _omitFieldNames ? '' : 'gpuTemp')
    ..a<$fixnum.Int64>(11, _omitFieldNames ? '' : 'uptime', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(12, _omitFieldNames ? '' : 'load1min', protoName: 'load_1min')
    ..aD(13, _omitFieldNames ? '' : 'load5min', protoName: 'load_5min')
    ..aD(14, _omitFieldNames ? '' : 'load15min', protoName: 'load_15min')
    ..a<$fixnum.Int64>(
        15, _omitFieldNames ? '' : 'netBytesSent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        16, _omitFieldNames ? '' : 'netBytesRecv', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<ProcessInfo>(17, _omitFieldNames ? '' : 'topProcesses',
        subBuilder: ProcessInfo.create)
    ..aInt64(18, _omitFieldNames ? '' : 'timestamp')
    ..pPM<DiskIOStat>(19, _omitFieldNames ? '' : 'diskIo',
        subBuilder: DiskIOStat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveStats copyWith(void Function(LiveStats) updates) =>
      super.copyWith((message) => updates(message as LiveStats)) as LiveStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LiveStats create() => LiveStats._();
  @$core.override
  LiveStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LiveStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LiveStats>(create);
  static LiveStats? _defaultInstance;

  /// CPU usage percentage (0-100)
  @$pb.TagNumber(1)
  $core.double get cpuUsage => $_getN(0);
  @$pb.TagNumber(1)
  set cpuUsage($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCpuUsage() => $_has(0);
  @$pb.TagNumber(1)
  void clearCpuUsage() => $_clearField(1);

  /// Per-core CPU usage
  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get cpuPerCore => $_getList(1);

  /// RAM usage in bytes
  @$pb.TagNumber(3)
  $fixnum.Int64 get ramUsed => $_getI64(2);
  @$pb.TagNumber(3)
  set ramUsed($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRamUsed() => $_has(2);
  @$pb.TagNumber(3)
  void clearRamUsed() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get ramTotal => $_getI64(3);
  @$pb.TagNumber(4)
  set ramTotal($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRamTotal() => $_has(3);
  @$pb.TagNumber(4)
  void clearRamTotal() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get ramFree => $_getI64(4);
  @$pb.TagNumber(5)
  set ramFree($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRamFree() => $_has(4);
  @$pb.TagNumber(5)
  void clearRamFree() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get ramCached => $_getI64(5);
  @$pb.TagNumber(6)
  set ramCached($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRamCached() => $_has(5);
  @$pb.TagNumber(6)
  void clearRamCached() => $_clearField(6);

  /// Swap usage in bytes
  @$pb.TagNumber(7)
  $fixnum.Int64 get swapUsed => $_getI64(6);
  @$pb.TagNumber(7)
  set swapUsed($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSwapUsed() => $_has(6);
  @$pb.TagNumber(7)
  void clearSwapUsed() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get swapTotal => $_getI64(7);
  @$pb.TagNumber(8)
  set swapTotal($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSwapTotal() => $_has(7);
  @$pb.TagNumber(8)
  void clearSwapTotal() => $_clearField(8);

  /// CPU temperature in Celsius
  @$pb.TagNumber(9)
  $core.double get cpuTemp => $_getN(8);
  @$pb.TagNumber(9)
  set cpuTemp($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCpuTemp() => $_has(8);
  @$pb.TagNumber(9)
  void clearCpuTemp() => $_clearField(9);

  /// GPU temperature in Celsius (if available)
  @$pb.TagNumber(10)
  $core.double get gpuTemp => $_getN(9);
  @$pb.TagNumber(10)
  set gpuTemp($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasGpuTemp() => $_has(9);
  @$pb.TagNumber(10)
  void clearGpuTemp() => $_clearField(10);

  /// System uptime in seconds
  @$pb.TagNumber(11)
  $fixnum.Int64 get uptime => $_getI64(10);
  @$pb.TagNumber(11)
  set uptime($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUptime() => $_has(10);
  @$pb.TagNumber(11)
  void clearUptime() => $_clearField(11);

  /// Load averages
  @$pb.TagNumber(12)
  $core.double get load1min => $_getN(11);
  @$pb.TagNumber(12)
  set load1min($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLoad1min() => $_has(11);
  @$pb.TagNumber(12)
  void clearLoad1min() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get load5min => $_getN(12);
  @$pb.TagNumber(13)
  set load5min($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLoad5min() => $_has(12);
  @$pb.TagNumber(13)
  void clearLoad5min() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get load15min => $_getN(13);
  @$pb.TagNumber(14)
  set load15min($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasLoad15min() => $_has(13);
  @$pb.TagNumber(14)
  void clearLoad15min() => $_clearField(14);

  /// Network stats (bytes per second)
  @$pb.TagNumber(15)
  $fixnum.Int64 get netBytesSent => $_getI64(14);
  @$pb.TagNumber(15)
  set netBytesSent($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNetBytesSent() => $_has(14);
  @$pb.TagNumber(15)
  void clearNetBytesSent() => $_clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get netBytesRecv => $_getI64(15);
  @$pb.TagNumber(16)
  set netBytesRecv($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasNetBytesRecv() => $_has(15);
  @$pb.TagNumber(16)
  void clearNetBytesRecv() => $_clearField(16);

  /// Top processes by CPU usage
  @$pb.TagNumber(17)
  $pb.PbList<ProcessInfo> get topProcesses => $_getList(16);

  /// Timestamp of this stat snapshot
  @$pb.TagNumber(18)
  $fixnum.Int64 get timestamp => $_getI64(17);
  @$pb.TagNumber(18)
  set timestamp($fixnum.Int64 value) => $_setInt64(17, value);
  @$pb.TagNumber(18)
  $core.bool hasTimestamp() => $_has(17);
  @$pb.TagNumber(18)
  void clearTimestamp() => $_clearField(18);

  /// Disk I/O stats (bytes per second)
  @$pb.TagNumber(19)
  $pb.PbList<DiskIOStat> get diskIo => $_getList(18);
}

/// Process information
class ProcessInfo extends $pb.GeneratedMessage {
  factory ProcessInfo({
    $core.int? pid,
    $core.String? name,
    $core.double? cpuPercent,
    $core.double? memoryPercent,
    $fixnum.Int64? memoryBytes,
    $core.String? status,
    $core.String? username,
    $core.String? cmdline,
  }) {
    final result = create();
    if (pid != null) result.pid = pid;
    if (name != null) result.name = name;
    if (cpuPercent != null) result.cpuPercent = cpuPercent;
    if (memoryPercent != null) result.memoryPercent = memoryPercent;
    if (memoryBytes != null) result.memoryBytes = memoryBytes;
    if (status != null) result.status = status;
    if (username != null) result.username = username;
    if (cmdline != null) result.cmdline = cmdline;
    return result;
  }

  ProcessInfo._();

  factory ProcessInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pid')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aD(3, _omitFieldNames ? '' : 'cpuPercent')
    ..aD(4, _omitFieldNames ? '' : 'memoryPercent')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'memoryBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aOS(7, _omitFieldNames ? '' : 'username')
    ..aOS(8, _omitFieldNames ? '' : 'cmdline')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessInfo copyWith(void Function(ProcessInfo) updates) =>
      super.copyWith((message) => updates(message as ProcessInfo))
          as ProcessInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessInfo create() => ProcessInfo._();
  @$core.override
  ProcessInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessInfo>(create);
  static ProcessInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pid => $_getIZ(0);
  @$pb.TagNumber(1)
  set pid($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPid() => $_has(0);
  @$pb.TagNumber(1)
  void clearPid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get cpuPercent => $_getN(2);
  @$pb.TagNumber(3)
  set cpuPercent($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCpuPercent() => $_has(2);
  @$pb.TagNumber(3)
  void clearCpuPercent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get memoryPercent => $_getN(3);
  @$pb.TagNumber(4)
  set memoryPercent($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMemoryPercent() => $_has(3);
  @$pb.TagNumber(4)
  void clearMemoryPercent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get memoryBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set memoryBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMemoryBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearMemoryBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get username => $_getSZ(6);
  @$pb.TagNumber(7)
  set username($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUsername() => $_has(6);
  @$pb.TagNumber(7)
  void clearUsername() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get cmdline => $_getSZ(7);
  @$pb.TagNumber(8)
  set cmdline($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCmdline() => $_has(7);
  @$pb.TagNumber(8)
  void clearCmdline() => $_clearField(8);
}

/// List of all processes
class ProcessList extends $pb.GeneratedMessage {
  factory ProcessList({
    $core.Iterable<ProcessInfo>? processes,
  }) {
    final result = create();
    if (processes != null) result.processes.addAll(processes);
    return result;
  }

  ProcessList._();

  factory ProcessList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<ProcessInfo>(1, _omitFieldNames ? '' : 'processes',
        subBuilder: ProcessInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessList copyWith(void Function(ProcessList) updates) =>
      super.copyWith((message) => updates(message as ProcessList))
          as ProcessList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessList create() => ProcessList._();
  @$core.override
  ProcessList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessList>(create);
  static ProcessList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProcessInfo> get processes => $_getList(0);
}

/// Process ID for kill operations
class ProcessId extends $pb.GeneratedMessage {
  factory ProcessId({
    $core.int? pid,
  }) {
    final result = create();
    if (pid != null) result.pid = pid;
    return result;
  }

  ProcessId._();

  factory ProcessId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessId copyWith(void Function(ProcessId) updates) =>
      super.copyWith((message) => updates(message as ProcessId)) as ProcessId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessId create() => ProcessId._();
  @$core.override
  ProcessId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessId getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessId>(create);
  static ProcessId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pid => $_getIZ(0);
  @$pb.TagNumber(1)
  set pid($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPid() => $_has(0);
  @$pb.TagNumber(1)
  void clearPid() => $_clearField(1);
}

/// Service information
class ServiceInfo extends $pb.GeneratedMessage {
  factory ServiceInfo({
    $core.String? name,
    $core.String? status,
    $core.String? description,
    $core.bool? enabled,
    $core.String? subState,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (status != null) result.status = status;
    if (description != null) result.description = description;
    if (enabled != null) result.enabled = enabled;
    if (subState != null) result.subState = subState;
    return result;
  }

  ServiceInfo._();

  factory ServiceInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServiceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOB(4, _omitFieldNames ? '' : 'enabled')
    ..aOS(5, _omitFieldNames ? '' : 'subState')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceInfo copyWith(void Function(ServiceInfo) updates) =>
      super.copyWith((message) => updates(message as ServiceInfo))
          as ServiceInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServiceInfo create() => ServiceInfo._();
  @$core.override
  ServiceInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServiceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServiceInfo>(create);
  static ServiceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enabled => $_getBF(3);
  @$pb.TagNumber(4)
  set enabled($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnabled() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnabled() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get subState => $_getSZ(4);
  @$pb.TagNumber(5)
  set subState($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSubState() => $_has(4);
  @$pb.TagNumber(5)
  void clearSubState() => $_clearField(5);
}

/// List of all services
class ServiceList extends $pb.GeneratedMessage {
  factory ServiceList({
    $core.Iterable<ServiceInfo>? services,
  }) {
    final result = create();
    if (services != null) result.services.addAll(services);
    return result;
  }

  ServiceList._();

  factory ServiceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServiceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<ServiceInfo>(1, _omitFieldNames ? '' : 'services',
        subBuilder: ServiceInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceList copyWith(void Function(ServiceList) updates) =>
      super.copyWith((message) => updates(message as ServiceList))
          as ServiceList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServiceList create() => ServiceList._();
  @$core.override
  ServiceList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServiceList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServiceList>(create);
  static ServiceList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ServiceInfo> get services => $_getList(0);
}

/// Service control command
class ServiceCommand extends $pb.GeneratedMessage {
  factory ServiceCommand({
    $core.String? serviceName,
    ServiceAction? action,
  }) {
    final result = create();
    if (serviceName != null) result.serviceName = serviceName;
    if (action != null) result.action = action;
    return result;
  }

  ServiceCommand._();

  factory ServiceCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServiceCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serviceName')
    ..aE<ServiceAction>(2, _omitFieldNames ? '' : 'action',
        enumValues: ServiceAction.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServiceCommand copyWith(void Function(ServiceCommand) updates) =>
      super.copyWith((message) => updates(message as ServiceCommand))
          as ServiceCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServiceCommand create() => ServiceCommand._();
  @$core.override
  ServiceCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ServiceCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServiceCommand>(create);
  static ServiceCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serviceName => $_getSZ(0);
  @$pb.TagNumber(1)
  set serviceName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServiceName() => $_has(0);
  @$pb.TagNumber(1)
  void clearServiceName() => $_clearField(1);

  @$pb.TagNumber(2)
  ServiceAction get action => $_getN(1);
  @$pb.TagNumber(2)
  set action(ServiceAction value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);
}

/// Generic action status response
class ActionStatus extends $pb.GeneratedMessage {
  factory ActionStatus({
    $core.bool? success,
    $core.String? message,
    $core.int? errorCode,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (errorCode != null) result.errorCode = errorCode;
    return result;
  }

  ActionStatus._();

  factory ActionStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActionStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aI(3, _omitFieldNames ? '' : 'errorCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionStatus copyWith(void Function(ActionStatus) updates) =>
      super.copyWith((message) => updates(message as ActionStatus))
          as ActionStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActionStatus create() => ActionStatus._();
  @$core.override
  ActionStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActionStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionStatus>(create);
  static ActionStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get errorCode => $_getIZ(2);
  @$pb.TagNumber(3)
  set errorCode($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorCode() => $_clearField(3);
}

/// Log filter options
class LogFilter extends $pb.GeneratedMessage {
  factory LogFilter({
    $core.Iterable<$core.String>? levels,
    $core.String? service,
    $core.int? tailLines,
  }) {
    final result = create();
    if (levels != null) result.levels.addAll(levels);
    if (service != null) result.service = service;
    if (tailLines != null) result.tailLines = tailLines;
    return result;
  }

  LogFilter._();

  factory LogFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'levels')
    ..aOS(2, _omitFieldNames ? '' : 'service')
    ..aI(3, _omitFieldNames ? '' : 'tailLines')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogFilter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogFilter copyWith(void Function(LogFilter) updates) =>
      super.copyWith((message) => updates(message as LogFilter)) as LogFilter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogFilter create() => LogFilter._();
  @$core.override
  LogFilter createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogFilter getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogFilter>(create);
  static LogFilter? _defaultInstance;

  /// Filter by log level (empty = all)
  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get levels => $_getList(0);

  /// Filter by service name (empty = all)
  @$pb.TagNumber(2)
  $core.String get service => $_getSZ(1);
  @$pb.TagNumber(2)
  set service($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasService() => $_has(1);
  @$pb.TagNumber(2)
  void clearService() => $_clearField(2);

  /// Number of past lines to include (0 = only new)
  @$pb.TagNumber(3)
  $core.int get tailLines => $_getIZ(2);
  @$pb.TagNumber(3)
  set tailLines($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTailLines() => $_has(2);
  @$pb.TagNumber(3)
  void clearTailLines() => $_clearField(3);
}

/// Single log entry
class LogEntry extends $pb.GeneratedMessage {
  factory LogEntry({
    $fixnum.Int64? timestamp,
    $core.String? level,
    $core.String? service,
    $core.String? message,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (level != null) result.level = level;
    if (service != null) result.service = service;
    if (message != null) result.message = message;
    return result;
  }

  LogEntry._();

  factory LogEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestamp')
    ..aOS(2, _omitFieldNames ? '' : 'level')
    ..aOS(3, _omitFieldNames ? '' : 'service')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogEntry copyWith(void Function(LogEntry) updates) =>
      super.copyWith((message) => updates(message as LogEntry)) as LogEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogEntry create() => LogEntry._();
  @$core.override
  LogEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LogEntry>(create);
  static LogEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get level => $_getSZ(1);
  @$pb.TagNumber(2)
  set level($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLevel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLevel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get service => $_getSZ(2);
  @$pb.TagNumber(3)
  set service($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasService() => $_has(2);
  @$pb.TagNumber(3)
  void clearService() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);
}

/// Disk usage information
class DiskInfo extends $pb.GeneratedMessage {
  factory DiskInfo({
    $core.Iterable<DiskPartition>? partitions,
  }) {
    final result = create();
    if (partitions != null) result.partitions.addAll(partitions);
    return result;
  }

  DiskInfo._();

  factory DiskInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiskInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiskInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<DiskPartition>(1, _omitFieldNames ? '' : 'partitions',
        subBuilder: DiskPartition.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskInfo copyWith(void Function(DiskInfo) updates) =>
      super.copyWith((message) => updates(message as DiskInfo)) as DiskInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiskInfo create() => DiskInfo._();
  @$core.override
  DiskInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiskInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiskInfo>(create);
  static DiskInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DiskPartition> get partitions => $_getList(0);
}

class DiskPartition extends $pb.GeneratedMessage {
  factory DiskPartition({
    $core.String? device,
    $core.String? mountPoint,
    $core.String? filesystem,
    $fixnum.Int64? totalBytes,
    $fixnum.Int64? usedBytes,
    $fixnum.Int64? freeBytes,
    $core.double? usagePercent,
  }) {
    final result = create();
    if (device != null) result.device = device;
    if (mountPoint != null) result.mountPoint = mountPoint;
    if (filesystem != null) result.filesystem = filesystem;
    if (totalBytes != null) result.totalBytes = totalBytes;
    if (usedBytes != null) result.usedBytes = usedBytes;
    if (freeBytes != null) result.freeBytes = freeBytes;
    if (usagePercent != null) result.usagePercent = usagePercent;
    return result;
  }

  DiskPartition._();

  factory DiskPartition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiskPartition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiskPartition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'device')
    ..aOS(2, _omitFieldNames ? '' : 'mountPoint')
    ..aOS(3, _omitFieldNames ? '' : 'filesystem')
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'totalBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'usedBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'freeBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(7, _omitFieldNames ? '' : 'usagePercent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskPartition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskPartition copyWith(void Function(DiskPartition) updates) =>
      super.copyWith((message) => updates(message as DiskPartition))
          as DiskPartition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiskPartition create() => DiskPartition._();
  @$core.override
  DiskPartition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiskPartition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiskPartition>(create);
  static DiskPartition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get device => $_getSZ(0);
  @$pb.TagNumber(1)
  set device($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mountPoint => $_getSZ(1);
  @$pb.TagNumber(2)
  set mountPoint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMountPoint() => $_has(1);
  @$pb.TagNumber(2)
  void clearMountPoint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filesystem => $_getSZ(2);
  @$pb.TagNumber(3)
  set filesystem($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilesystem() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilesystem() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set totalBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get usedBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set usedBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUsedBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearUsedBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get freeBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set freeBytes($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFreeBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearFreeBytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get usagePercent => $_getN(6);
  @$pb.TagNumber(7)
  set usagePercent($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUsagePercent() => $_has(6);
  @$pb.TagNumber(7)
  void clearUsagePercent() => $_clearField(7);
}

/// Network interface information
class NetworkInfo extends $pb.GeneratedMessage {
  factory NetworkInfo({
    $core.Iterable<NetworkInterface>? interfaces,
  }) {
    final result = create();
    if (interfaces != null) result.interfaces.addAll(interfaces);
    return result;
  }

  NetworkInfo._();

  factory NetworkInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetworkInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<NetworkInterface>(1, _omitFieldNames ? '' : 'interfaces',
        subBuilder: NetworkInterface.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkInfo copyWith(void Function(NetworkInfo) updates) =>
      super.copyWith((message) => updates(message as NetworkInfo))
          as NetworkInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkInfo create() => NetworkInfo._();
  @$core.override
  NetworkInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetworkInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkInfo>(create);
  static NetworkInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NetworkInterface> get interfaces => $_getList(0);
}

class NetworkInterface extends $pb.GeneratedMessage {
  factory NetworkInterface({
    $core.String? name,
    $core.Iterable<$core.String>? addresses,
    $core.String? macAddress,
    $core.bool? isUp,
    $fixnum.Int64? bytesSent,
    $fixnum.Int64? bytesRecv,
    $fixnum.Int64? packetsSent,
    $fixnum.Int64? packetsRecv,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (addresses != null) result.addresses.addAll(addresses);
    if (macAddress != null) result.macAddress = macAddress;
    if (isUp != null) result.isUp = isUp;
    if (bytesSent != null) result.bytesSent = bytesSent;
    if (bytesRecv != null) result.bytesRecv = bytesRecv;
    if (packetsSent != null) result.packetsSent = packetsSent;
    if (packetsRecv != null) result.packetsRecv = packetsRecv;
    return result;
  }

  NetworkInterface._();

  factory NetworkInterface.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetworkInterface.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkInterface',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pPS(2, _omitFieldNames ? '' : 'addresses')
    ..aOS(3, _omitFieldNames ? '' : 'macAddress')
    ..aOB(4, _omitFieldNames ? '' : 'isUp')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'bytesSent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'bytesRecv', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'packetsSent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'packetsRecv', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkInterface clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkInterface copyWith(void Function(NetworkInterface) updates) =>
      super.copyWith((message) => updates(message as NetworkInterface))
          as NetworkInterface;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkInterface create() => NetworkInterface._();
  @$core.override
  NetworkInterface createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetworkInterface getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkInterface>(create);
  static NetworkInterface? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get addresses => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get macAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set macAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMacAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearMacAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isUp => $_getBF(3);
  @$pb.TagNumber(4)
  set isUp($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsUp() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsUp() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get bytesSent => $_getI64(4);
  @$pb.TagNumber(5)
  set bytesSent($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBytesSent() => $_has(4);
  @$pb.TagNumber(5)
  void clearBytesSent() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get bytesRecv => $_getI64(5);
  @$pb.TagNumber(6)
  set bytesRecv($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBytesRecv() => $_has(5);
  @$pb.TagNumber(6)
  void clearBytesRecv() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get packetsSent => $_getI64(6);
  @$pb.TagNumber(7)
  set packetsSent($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPacketsSent() => $_has(6);
  @$pb.TagNumber(7)
  void clearPacketsSent() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get packetsRecv => $_getI64(7);
  @$pb.TagNumber(8)
  set packetsRecv($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPacketsRecv() => $_has(7);
  @$pb.TagNumber(8)
  void clearPacketsRecv() => $_clearField(8);
}

/// Network connection information
class NetworkConnectionList extends $pb.GeneratedMessage {
  factory NetworkConnectionList({
    $core.Iterable<NetworkConnection>? connections,
  }) {
    final result = create();
    if (connections != null) result.connections.addAll(connections);
    return result;
  }

  NetworkConnectionList._();

  factory NetworkConnectionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetworkConnectionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkConnectionList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<NetworkConnection>(1, _omitFieldNames ? '' : 'connections',
        subBuilder: NetworkConnection.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConnectionList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConnectionList copyWith(
          void Function(NetworkConnectionList) updates) =>
      super.copyWith((message) => updates(message as NetworkConnectionList))
          as NetworkConnectionList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkConnectionList create() => NetworkConnectionList._();
  @$core.override
  NetworkConnectionList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetworkConnectionList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkConnectionList>(create);
  static NetworkConnectionList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NetworkConnection> get connections => $_getList(0);
}

class NetworkConnection extends $pb.GeneratedMessage {
  factory NetworkConnection({
    $core.String? protocol,
    $core.String? localAddress,
    $core.int? localPort,
    $core.String? remoteAddress,
    $core.int? remotePort,
    $core.String? status,
    $core.int? pid,
    $core.String? processName,
  }) {
    final result = create();
    if (protocol != null) result.protocol = protocol;
    if (localAddress != null) result.localAddress = localAddress;
    if (localPort != null) result.localPort = localPort;
    if (remoteAddress != null) result.remoteAddress = remoteAddress;
    if (remotePort != null) result.remotePort = remotePort;
    if (status != null) result.status = status;
    if (pid != null) result.pid = pid;
    if (processName != null) result.processName = processName;
    return result;
  }

  NetworkConnection._();

  factory NetworkConnection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NetworkConnection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkConnection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'protocol')
    ..aOS(2, _omitFieldNames ? '' : 'localAddress')
    ..aI(3, _omitFieldNames ? '' : 'localPort')
    ..aOS(4, _omitFieldNames ? '' : 'remoteAddress')
    ..aI(5, _omitFieldNames ? '' : 'remotePort')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aI(7, _omitFieldNames ? '' : 'pid')
    ..aOS(8, _omitFieldNames ? '' : 'processName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConnection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NetworkConnection copyWith(void Function(NetworkConnection) updates) =>
      super.copyWith((message) => updates(message as NetworkConnection))
          as NetworkConnection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NetworkConnection create() => NetworkConnection._();
  @$core.override
  NetworkConnection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NetworkConnection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkConnection>(create);
  static NetworkConnection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get protocol => $_getSZ(0);
  @$pb.TagNumber(1)
  set protocol($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProtocol() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocol() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get localAddress => $_getSZ(1);
  @$pb.TagNumber(2)
  set localAddress($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLocalAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocalAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get localPort => $_getIZ(2);
  @$pb.TagNumber(3)
  set localPort($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLocalPort() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocalPort() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get remoteAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set remoteAddress($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRemoteAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemoteAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get remotePort => $_getIZ(4);
  @$pb.TagNumber(5)
  set remotePort($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRemotePort() => $_has(4);
  @$pb.TagNumber(5)
  void clearRemotePort() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pid => $_getIZ(6);
  @$pb.TagNumber(7)
  set pid($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPid() => $_has(6);
  @$pb.TagNumber(7)
  void clearPid() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get processName => $_getSZ(7);
  @$pb.TagNumber(8)
  set processName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProcessName() => $_has(7);
  @$pb.TagNumber(8)
  void clearProcessName() => $_clearField(8);
}

/// Package management
class PackageFilter extends $pb.GeneratedMessage {
  factory PackageFilter({
    $core.String? searchTerm,
    $core.bool? installedOnly,
  }) {
    final result = create();
    if (searchTerm != null) result.searchTerm = searchTerm;
    if (installedOnly != null) result.installedOnly = installedOnly;
    return result;
  }

  PackageFilter._();

  factory PackageFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'searchTerm')
    ..aOB(2, _omitFieldNames ? '' : 'installedOnly')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageFilter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageFilter copyWith(void Function(PackageFilter) updates) =>
      super.copyWith((message) => updates(message as PackageFilter))
          as PackageFilter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageFilter create() => PackageFilter._();
  @$core.override
  PackageFilter createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageFilter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageFilter>(create);
  static PackageFilter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get searchTerm => $_getSZ(0);
  @$pb.TagNumber(1)
  set searchTerm($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSearchTerm() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearchTerm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get installedOnly => $_getBF(1);
  @$pb.TagNumber(2)
  set installedOnly($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInstalledOnly() => $_has(1);
  @$pb.TagNumber(2)
  void clearInstalledOnly() => $_clearField(2);
}

class PackageInfo extends $pb.GeneratedMessage {
  factory PackageInfo({
    $core.String? name,
    $core.String? version,
    $core.String? architecture,
    $core.String? description,
    $core.bool? installed,
    $core.String? status,
    $fixnum.Int64? installedSize,
    $core.String? section,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (version != null) result.version = version;
    if (architecture != null) result.architecture = architecture;
    if (description != null) result.description = description;
    if (installed != null) result.installed = installed;
    if (status != null) result.status = status;
    if (installedSize != null) result.installedSize = installedSize;
    if (section != null) result.section = section;
    return result;
  }

  PackageInfo._();

  factory PackageInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'architecture')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOB(5, _omitFieldNames ? '' : 'installed')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'installedSize', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(8, _omitFieldNames ? '' : 'section')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageInfo copyWith(void Function(PackageInfo) updates) =>
      super.copyWith((message) => updates(message as PackageInfo))
          as PackageInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageInfo create() => PackageInfo._();
  @$core.override
  PackageInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageInfo>(create);
  static PackageInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get architecture => $_getSZ(2);
  @$pb.TagNumber(3)
  set architecture($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArchitecture() => $_has(2);
  @$pb.TagNumber(3)
  void clearArchitecture() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get installed => $_getBF(4);
  @$pb.TagNumber(5)
  set installed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInstalled() => $_has(4);
  @$pb.TagNumber(5)
  void clearInstalled() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get installedSize => $_getI64(6);
  @$pb.TagNumber(7)
  set installedSize($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInstalledSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearInstalledSize() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get section => $_getSZ(7);
  @$pb.TagNumber(8)
  set section($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSection() => $_has(7);
  @$pb.TagNumber(8)
  void clearSection() => $_clearField(8);
}

class PackageList extends $pb.GeneratedMessage {
  factory PackageList({
    $core.Iterable<PackageInfo>? packages,
  }) {
    final result = create();
    if (packages != null) result.packages.addAll(packages);
    return result;
  }

  PackageList._();

  factory PackageList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<PackageInfo>(1, _omitFieldNames ? '' : 'packages',
        subBuilder: PackageInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageList copyWith(void Function(PackageList) updates) =>
      super.copyWith((message) => updates(message as PackageList))
          as PackageList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageList create() => PackageList._();
  @$core.override
  PackageList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageList>(create);
  static PackageList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PackageInfo> get packages => $_getList(0);
}

class PackageCommand extends $pb.GeneratedMessage {
  factory PackageCommand({
    $core.String? packageName,
  }) {
    final result = create();
    if (packageName != null) result.packageName = packageName;
    return result;
  }

  PackageCommand._();

  factory PackageCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packageName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageCommand copyWith(void Function(PackageCommand) updates) =>
      super.copyWith((message) => updates(message as PackageCommand))
          as PackageCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageCommand create() => PackageCommand._();
  @$core.override
  PackageCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageCommand>(create);
  static PackageCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packageName => $_getSZ(0);
  @$pb.TagNumber(1)
  set packageName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackageName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackageName() => $_clearField(1);
}

/// Request for detailed package information
class PackageDetailsRequest extends $pb.GeneratedMessage {
  factory PackageDetailsRequest({
    $core.String? packageName,
  }) {
    final result = create();
    if (packageName != null) result.packageName = packageName;
    return result;
  }

  PackageDetailsRequest._();

  factory PackageDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packageName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageDetailsRequest copyWith(
          void Function(PackageDetailsRequest) updates) =>
      super.copyWith((message) => updates(message as PackageDetailsRequest))
          as PackageDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageDetailsRequest create() => PackageDetailsRequest._();
  @$core.override
  PackageDetailsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageDetailsRequest>(create);
  static PackageDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packageName => $_getSZ(0);
  @$pb.TagNumber(1)
  set packageName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackageName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackageName() => $_clearField(1);
}

/// Detailed package information
class PackageDetails extends $pb.GeneratedMessage {
  factory PackageDetails({
    $core.String? name,
    $core.String? version,
    $core.String? architecture,
    $core.String? description,
    $core.String? longDescription,
    $core.bool? installed,
    $core.String? status,
    $fixnum.Int64? installedSize,
    $core.String? maintainer,
    $core.String? homepage,
    $core.String? section,
    $fixnum.Int64? installDate,
    $core.Iterable<$core.String>? tags,
    $core.String? source,
    $core.int? priority,
    $core.String? license,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (version != null) result.version = version;
    if (architecture != null) result.architecture = architecture;
    if (description != null) result.description = description;
    if (longDescription != null) result.longDescription = longDescription;
    if (installed != null) result.installed = installed;
    if (status != null) result.status = status;
    if (installedSize != null) result.installedSize = installedSize;
    if (maintainer != null) result.maintainer = maintainer;
    if (homepage != null) result.homepage = homepage;
    if (section != null) result.section = section;
    if (installDate != null) result.installDate = installDate;
    if (tags != null) result.tags.addAll(tags);
    if (source != null) result.source = source;
    if (priority != null) result.priority = priority;
    if (license != null) result.license = license;
    return result;
  }

  PackageDetails._();

  factory PackageDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'architecture')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'longDescription')
    ..aOB(6, _omitFieldNames ? '' : 'installed')
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'installedSize', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(9, _omitFieldNames ? '' : 'maintainer')
    ..aOS(10, _omitFieldNames ? '' : 'homepage')
    ..aOS(11, _omitFieldNames ? '' : 'section')
    ..aInt64(12, _omitFieldNames ? '' : 'installDate')
    ..pPS(13, _omitFieldNames ? '' : 'tags')
    ..aOS(14, _omitFieldNames ? '' : 'source')
    ..aI(15, _omitFieldNames ? '' : 'priority')
    ..aOS(16, _omitFieldNames ? '' : 'license')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageDetails copyWith(void Function(PackageDetails) updates) =>
      super.copyWith((message) => updates(message as PackageDetails))
          as PackageDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageDetails create() => PackageDetails._();
  @$core.override
  PackageDetails createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageDetails>(create);
  static PackageDetails? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get architecture => $_getSZ(2);
  @$pb.TagNumber(3)
  set architecture($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArchitecture() => $_has(2);
  @$pb.TagNumber(3)
  void clearArchitecture() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get longDescription => $_getSZ(4);
  @$pb.TagNumber(5)
  set longDescription($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLongDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearLongDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get installed => $_getBF(5);
  @$pb.TagNumber(6)
  set installed($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInstalled() => $_has(5);
  @$pb.TagNumber(6)
  void clearInstalled() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get installedSize => $_getI64(7);
  @$pb.TagNumber(8)
  set installedSize($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasInstalledSize() => $_has(7);
  @$pb.TagNumber(8)
  void clearInstalledSize() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get maintainer => $_getSZ(8);
  @$pb.TagNumber(9)
  set maintainer($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaintainer() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaintainer() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get homepage => $_getSZ(9);
  @$pb.TagNumber(10)
  set homepage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHomepage() => $_has(9);
  @$pb.TagNumber(10)
  void clearHomepage() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get section => $_getSZ(10);
  @$pb.TagNumber(11)
  set section($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSection() => $_has(10);
  @$pb.TagNumber(11)
  void clearSection() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get installDate => $_getI64(11);
  @$pb.TagNumber(12)
  set installDate($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasInstallDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearInstallDate() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<$core.String> get tags => $_getList(12);

  @$pb.TagNumber(14)
  $core.String get source => $_getSZ(13);
  @$pb.TagNumber(14)
  set source($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSource() => $_has(13);
  @$pb.TagNumber(14)
  void clearSource() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get priority => $_getIZ(14);
  @$pb.TagNumber(15)
  set priority($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPriority() => $_has(14);
  @$pb.TagNumber(15)
  void clearPriority() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get license => $_getSZ(15);
  @$pb.TagNumber(16)
  set license($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasLicense() => $_has(15);
  @$pb.TagNumber(16)
  void clearLicense() => $_clearField(16);
}

/// Package dependency information
class PackageDependencies extends $pb.GeneratedMessage {
  factory PackageDependencies({
    $core.String? packageName,
    $core.Iterable<$core.String>? depends,
    $core.Iterable<$core.String>? requiredBy,
    $core.Iterable<$core.String>? recommends,
    $core.Iterable<$core.String>? suggests,
    $core.Iterable<$core.String>? conflicts,
  }) {
    final result = create();
    if (packageName != null) result.packageName = packageName;
    if (depends != null) result.depends.addAll(depends);
    if (requiredBy != null) result.requiredBy.addAll(requiredBy);
    if (recommends != null) result.recommends.addAll(recommends);
    if (suggests != null) result.suggests.addAll(suggests);
    if (conflicts != null) result.conflicts.addAll(conflicts);
    return result;
  }

  PackageDependencies._();

  factory PackageDependencies.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageDependencies.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageDependencies',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'packageName')
    ..pPS(2, _omitFieldNames ? '' : 'depends')
    ..pPS(3, _omitFieldNames ? '' : 'requiredBy')
    ..pPS(4, _omitFieldNames ? '' : 'recommends')
    ..pPS(5, _omitFieldNames ? '' : 'suggests')
    ..pPS(6, _omitFieldNames ? '' : 'conflicts')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageDependencies clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageDependencies copyWith(void Function(PackageDependencies) updates) =>
      super.copyWith((message) => updates(message as PackageDependencies))
          as PackageDependencies;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageDependencies create() => PackageDependencies._();
  @$core.override
  PackageDependencies createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageDependencies getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageDependencies>(create);
  static PackageDependencies? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get packageName => $_getSZ(0);
  @$pb.TagNumber(1)
  set packageName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPackageName() => $_has(0);
  @$pb.TagNumber(1)
  void clearPackageName() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get depends => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get requiredBy => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get recommends => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get suggests => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get conflicts => $_getList(5);
}

/// Log entry for package operations
class PackageOperationLog extends $pb.GeneratedMessage {
  factory PackageOperationLog({
    $fixnum.Int64? timestamp,
    $core.String? level,
    $core.String? message,
    $core.double? progress,
    $core.bool? completed,
    $core.bool? success,
  }) {
    final result = create();
    if (timestamp != null) result.timestamp = timestamp;
    if (level != null) result.level = level;
    if (message != null) result.message = message;
    if (progress != null) result.progress = progress;
    if (completed != null) result.completed = completed;
    if (success != null) result.success = success;
    return result;
  }

  PackageOperationLog._();

  factory PackageOperationLog.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PackageOperationLog.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageOperationLog',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'timestamp')
    ..aOS(2, _omitFieldNames ? '' : 'level')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aD(4, _omitFieldNames ? '' : 'progress')
    ..aOB(5, _omitFieldNames ? '' : 'completed')
    ..aOB(6, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageOperationLog clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PackageOperationLog copyWith(void Function(PackageOperationLog) updates) =>
      super.copyWith((message) => updates(message as PackageOperationLog))
          as PackageOperationLog;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PackageOperationLog create() => PackageOperationLog._();
  @$core.override
  PackageOperationLog createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PackageOperationLog getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageOperationLog>(create);
  static PackageOperationLog? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get level => $_getSZ(1);
  @$pb.TagNumber(2)
  set level($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLevel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLevel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get progress => $_getN(3);
  @$pb.TagNumber(4)
  set progress($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProgress() => $_has(3);
  @$pb.TagNumber(4)
  void clearProgress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get completed => $_getBF(4);
  @$pb.TagNumber(5)
  set completed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCompleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearCompleted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get success => $_getBF(5);
  @$pb.TagNumber(6)
  set success($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSuccess() => $_has(5);
  @$pb.TagNumber(6)
  void clearSuccess() => $_clearField(6);
}

/// Disk I/O statistics
class DiskIOStat extends $pb.GeneratedMessage {
  factory DiskIOStat({
    $core.String? device,
    $fixnum.Int64? readBytes,
    $fixnum.Int64? writeBytes,
    $fixnum.Int64? readCount,
    $fixnum.Int64? writeCount,
  }) {
    final result = create();
    if (device != null) result.device = device;
    if (readBytes != null) result.readBytes = readBytes;
    if (writeBytes != null) result.writeBytes = writeBytes;
    if (readCount != null) result.readCount = readCount;
    if (writeCount != null) result.writeCount = writeCount;
    return result;
  }

  DiskIOStat._();

  factory DiskIOStat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiskIOStat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiskIOStat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'device')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'readBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'writeBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'readCount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'writeCount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskIOStat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskIOStat copyWith(void Function(DiskIOStat) updates) =>
      super.copyWith((message) => updates(message as DiskIOStat)) as DiskIOStat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiskIOStat create() => DiskIOStat._();
  @$core.override
  DiskIOStat createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiskIOStat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiskIOStat>(create);
  static DiskIOStat? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get device => $_getSZ(0);
  @$pb.TagNumber(1)
  set device($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get readBytes => $_getI64(1);
  @$pb.TagNumber(2)
  set readBytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReadBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearReadBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get writeBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set writeBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWriteBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearWriteBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get readCount => $_getI64(3);
  @$pb.TagNumber(4)
  set readCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReadCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get writeCount => $_getI64(4);
  @$pb.TagNumber(5)
  set writeCount($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWriteCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearWriteCount() => $_clearField(5);
}

/// Version information
class VersionInfo extends $pb.GeneratedMessage {
  factory VersionInfo({
    $core.String? version,
    $core.bool? isRoot,
  }) {
    final result = create();
    if (version != null) result.version = version;
    if (isRoot != null) result.isRoot = isRoot;
    return result;
  }

  VersionInfo._();

  factory VersionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VersionInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VersionInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..aOB(2, _omitFieldNames ? '' : 'isRoot')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionInfo copyWith(void Function(VersionInfo) updates) =>
      super.copyWith((message) => updates(message as VersionInfo))
          as VersionInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionInfo create() => VersionInfo._();
  @$core.override
  VersionInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VersionInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VersionInfo>(create);
  static VersionInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isRoot => $_getBF(1);
  @$pb.TagNumber(2)
  set isRoot($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsRoot() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsRoot() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
