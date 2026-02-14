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

/// Ping request
class PingRequest extends $pb.GeneratedMessage {
  factory PingRequest({
    $core.String? host,
    $core.int? count,
    $core.int? timeout,
    $core.int? packetSize,
  }) {
    final result = create();
    if (host != null) result.host = host;
    if (count != null) result.count = count;
    if (timeout != null) result.timeout = timeout;
    if (packetSize != null) result.packetSize = packetSize;
    return result;
  }

  PingRequest._();

  factory PingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'host')
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..aI(3, _omitFieldNames ? '' : 'timeout')
    ..aI(4, _omitFieldNames ? '' : 'packetSize')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingRequest copyWith(void Function(PingRequest) updates) =>
      super.copyWith((message) => updates(message as PingRequest))
          as PingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingRequest create() => PingRequest._();
  @$core.override
  PingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingRequest>(create);
  static PingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get host => $_getSZ(0);
  @$pb.TagNumber(1)
  set host($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHost() => $_has(0);
  @$pb.TagNumber(1)
  void clearHost() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get timeout => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeout() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeout() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get packetSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set packetSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPacketSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPacketSize() => $_clearField(4);
}

/// Ping response (streamed)
class PingResponse extends $pb.GeneratedMessage {
  factory PingResponse({
    $core.bool? success,
    $core.String? host,
    $core.String? ip,
    $core.double? latency,
    $core.int? sequence,
    $core.int? ttl,
    $core.String? error,
    $core.bool? finished,
    PingStats? statistics,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (host != null) result.host = host;
    if (ip != null) result.ip = ip;
    if (latency != null) result.latency = latency;
    if (sequence != null) result.sequence = sequence;
    if (ttl != null) result.ttl = ttl;
    if (error != null) result.error = error;
    if (finished != null) result.finished = finished;
    if (statistics != null) result.statistics = statistics;
    return result;
  }

  PingResponse._();

  factory PingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'host')
    ..aOS(3, _omitFieldNames ? '' : 'ip')
    ..aD(4, _omitFieldNames ? '' : 'latency')
    ..aI(5, _omitFieldNames ? '' : 'sequence')
    ..aI(6, _omitFieldNames ? '' : 'ttl')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..aOB(8, _omitFieldNames ? '' : 'finished')
    ..aOM<PingStats>(9, _omitFieldNames ? '' : 'statistics',
        subBuilder: PingStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingResponse copyWith(void Function(PingResponse) updates) =>
      super.copyWith((message) => updates(message as PingResponse))
          as PingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingResponse create() => PingResponse._();
  @$core.override
  PingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingResponse>(create);
  static PingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get host => $_getSZ(1);
  @$pb.TagNumber(2)
  set host($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHost() => $_has(1);
  @$pb.TagNumber(2)
  void clearHost() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get ip => $_getSZ(2);
  @$pb.TagNumber(3)
  set ip($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIp() => $_has(2);
  @$pb.TagNumber(3)
  void clearIp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get latency => $_getN(3);
  @$pb.TagNumber(4)
  set latency($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLatency() => $_has(3);
  @$pb.TagNumber(4)
  void clearLatency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sequence => $_getIZ(4);
  @$pb.TagNumber(5)
  set sequence($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ttl => $_getIZ(5);
  @$pb.TagNumber(6)
  set ttl($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTtl() => $_has(5);
  @$pb.TagNumber(6)
  void clearTtl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get finished => $_getBF(7);
  @$pb.TagNumber(8)
  set finished($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFinished() => $_has(7);
  @$pb.TagNumber(8)
  void clearFinished() => $_clearField(8);

  @$pb.TagNumber(9)
  PingStats get statistics => $_getN(8);
  @$pb.TagNumber(9)
  set statistics(PingStats value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatistics() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatistics() => $_clearField(9);
  @$pb.TagNumber(9)
  PingStats ensureStatistics() => $_ensure(8);
}

/// Ping statistics
class PingStats extends $pb.GeneratedMessage {
  factory PingStats({
    $core.int? packetsSent,
    $core.int? packetsReceived,
    $core.double? packetLoss,
    $core.double? minLatency,
    $core.double? maxLatency,
    $core.double? avgLatency,
  }) {
    final result = create();
    if (packetsSent != null) result.packetsSent = packetsSent;
    if (packetsReceived != null) result.packetsReceived = packetsReceived;
    if (packetLoss != null) result.packetLoss = packetLoss;
    if (minLatency != null) result.minLatency = minLatency;
    if (maxLatency != null) result.maxLatency = maxLatency;
    if (avgLatency != null) result.avgLatency = avgLatency;
    return result;
  }

  PingStats._();

  factory PingStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PingStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'packetsSent')
    ..aI(2, _omitFieldNames ? '' : 'packetsReceived')
    ..aD(3, _omitFieldNames ? '' : 'packetLoss')
    ..aD(4, _omitFieldNames ? '' : 'minLatency')
    ..aD(5, _omitFieldNames ? '' : 'maxLatency')
    ..aD(6, _omitFieldNames ? '' : 'avgLatency')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PingStats copyWith(void Function(PingStats) updates) =>
      super.copyWith((message) => updates(message as PingStats)) as PingStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingStats create() => PingStats._();
  @$core.override
  PingStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PingStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingStats>(create);
  static PingStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get packetsSent => $_getIZ(0);
  @$pb.TagNumber(1)
  set packetsSent($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPacketsSent() => $_has(0);
  @$pb.TagNumber(1)
  void clearPacketsSent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get packetsReceived => $_getIZ(1);
  @$pb.TagNumber(2)
  set packetsReceived($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPacketsReceived() => $_has(1);
  @$pb.TagNumber(2)
  void clearPacketsReceived() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get packetLoss => $_getN(2);
  @$pb.TagNumber(3)
  set packetLoss($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPacketLoss() => $_has(2);
  @$pb.TagNumber(3)
  void clearPacketLoss() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get minLatency => $_getN(3);
  @$pb.TagNumber(4)
  set minLatency($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMinLatency() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinLatency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get maxLatency => $_getN(4);
  @$pb.TagNumber(5)
  set maxLatency($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxLatency() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxLatency() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get avgLatency => $_getN(5);
  @$pb.TagNumber(6)
  set avgLatency($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvgLatency() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvgLatency() => $_clearField(6);
}

/// Port scan request
class PortScanRequest extends $pb.GeneratedMessage {
  factory PortScanRequest({
    $core.String? host,
    $core.Iterable<$core.int>? ports,
    $core.int? startPort,
    $core.int? endPort,
    $core.int? timeout,
  }) {
    final result = create();
    if (host != null) result.host = host;
    if (ports != null) result.ports.addAll(ports);
    if (startPort != null) result.startPort = startPort;
    if (endPort != null) result.endPort = endPort;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  PortScanRequest._();

  factory PortScanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PortScanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortScanRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'host')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'ports', $pb.PbFieldType.K3)
    ..aI(3, _omitFieldNames ? '' : 'startPort')
    ..aI(4, _omitFieldNames ? '' : 'endPort')
    ..aI(5, _omitFieldNames ? '' : 'timeout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortScanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortScanRequest copyWith(void Function(PortScanRequest) updates) =>
      super.copyWith((message) => updates(message as PortScanRequest))
          as PortScanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortScanRequest create() => PortScanRequest._();
  @$core.override
  PortScanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PortScanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PortScanRequest>(create);
  static PortScanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get host => $_getSZ(0);
  @$pb.TagNumber(1)
  set host($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHost() => $_has(0);
  @$pb.TagNumber(1)
  void clearHost() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get ports => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get startPort => $_getIZ(2);
  @$pb.TagNumber(3)
  set startPort($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartPort() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartPort() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get endPort => $_getIZ(3);
  @$pb.TagNumber(4)
  set endPort($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEndPort() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndPort() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get timeout => $_getIZ(4);
  @$pb.TagNumber(5)
  set timeout($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimeout() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeout() => $_clearField(5);
}

/// Port scan response (streamed)
class PortScanResponse extends $pb.GeneratedMessage {
  factory PortScanResponse({
    $core.int? port,
    $core.bool? open,
    $core.String? service,
    $core.String? error,
    $core.bool? finished,
    $core.int? progress,
  }) {
    final result = create();
    if (port != null) result.port = port;
    if (open != null) result.open = open;
    if (service != null) result.service = service;
    if (error != null) result.error = error;
    if (finished != null) result.finished = finished;
    if (progress != null) result.progress = progress;
    return result;
  }

  PortScanResponse._();

  factory PortScanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PortScanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortScanResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'port')
    ..aOB(2, _omitFieldNames ? '' : 'open')
    ..aOS(3, _omitFieldNames ? '' : 'service')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aOB(5, _omitFieldNames ? '' : 'finished')
    ..aI(6, _omitFieldNames ? '' : 'progress')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortScanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PortScanResponse copyWith(void Function(PortScanResponse) updates) =>
      super.copyWith((message) => updates(message as PortScanResponse))
          as PortScanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PortScanResponse create() => PortScanResponse._();
  @$core.override
  PortScanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PortScanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PortScanResponse>(create);
  static PortScanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get port => $_getIZ(0);
  @$pb.TagNumber(1)
  set port($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPort() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get open => $_getBF(1);
  @$pb.TagNumber(2)
  set open($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOpen() => $_has(1);
  @$pb.TagNumber(2)
  void clearOpen() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get service => $_getSZ(2);
  @$pb.TagNumber(3)
  set service($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasService() => $_has(2);
  @$pb.TagNumber(3)
  void clearService() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get finished => $_getBF(4);
  @$pb.TagNumber(5)
  set finished($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFinished() => $_has(4);
  @$pb.TagNumber(5)
  void clearFinished() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get progress => $_getIZ(5);
  @$pb.TagNumber(6)
  set progress($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearProgress() => $_clearField(6);
}

/// DNS lookup request
class DNSRequest extends $pb.GeneratedMessage {
  factory DNSRequest({
    $core.String? hostname,
    $core.String? recordType,
  }) {
    final result = create();
    if (hostname != null) result.hostname = hostname;
    if (recordType != null) result.recordType = recordType;
    return result;
  }

  DNSRequest._();

  factory DNSRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DNSRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DNSRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hostname')
    ..aOS(2, _omitFieldNames ? '' : 'recordType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DNSRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DNSRequest copyWith(void Function(DNSRequest) updates) =>
      super.copyWith((message) => updates(message as DNSRequest)) as DNSRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DNSRequest create() => DNSRequest._();
  @$core.override
  DNSRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DNSRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DNSRequest>(create);
  static DNSRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hostname => $_getSZ(0);
  @$pb.TagNumber(1)
  set hostname($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHostname() => $_has(0);
  @$pb.TagNumber(1)
  void clearHostname() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recordType => $_getSZ(1);
  @$pb.TagNumber(2)
  set recordType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecordType() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecordType() => $_clearField(2);
}

/// DNS lookup response
class DNSResponse extends $pb.GeneratedMessage {
  factory DNSResponse({
    $core.bool? success,
    $core.String? hostname,
    $core.Iterable<$core.String>? addresses,
    $core.Iterable<DNSRecord>? records,
    $core.double? queryTime,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (hostname != null) result.hostname = hostname;
    if (addresses != null) result.addresses.addAll(addresses);
    if (records != null) result.records.addAll(records);
    if (queryTime != null) result.queryTime = queryTime;
    if (error != null) result.error = error;
    return result;
  }

  DNSResponse._();

  factory DNSResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DNSResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DNSResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'hostname')
    ..pPS(3, _omitFieldNames ? '' : 'addresses')
    ..pPM<DNSRecord>(4, _omitFieldNames ? '' : 'records',
        subBuilder: DNSRecord.create)
    ..aD(5, _omitFieldNames ? '' : 'queryTime')
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DNSResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DNSResponse copyWith(void Function(DNSResponse) updates) =>
      super.copyWith((message) => updates(message as DNSResponse))
          as DNSResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DNSResponse create() => DNSResponse._();
  @$core.override
  DNSResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DNSResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DNSResponse>(create);
  static DNSResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get hostname => $_getSZ(1);
  @$pb.TagNumber(2)
  set hostname($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHostname() => $_has(1);
  @$pb.TagNumber(2)
  void clearHostname() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get addresses => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<DNSRecord> get records => $_getList(3);

  @$pb.TagNumber(5)
  $core.double get queryTime => $_getN(4);
  @$pb.TagNumber(5)
  set queryTime($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQueryTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearQueryTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => $_clearField(6);
}

/// DNS record details
class DNSRecord extends $pb.GeneratedMessage {
  factory DNSRecord({
    $core.String? type,
    $core.String? value,
    $core.int? ttl,
    $core.int? priority,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    if (ttl != null) result.ttl = ttl;
    if (priority != null) result.priority = priority;
    return result;
  }

  DNSRecord._();

  factory DNSRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DNSRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DNSRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aI(3, _omitFieldNames ? '' : 'ttl')
    ..aI(4, _omitFieldNames ? '' : 'priority')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DNSRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DNSRecord copyWith(void Function(DNSRecord) updates) =>
      super.copyWith((message) => updates(message as DNSRecord)) as DNSRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DNSRecord create() => DNSRecord._();
  @$core.override
  DNSRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DNSRecord getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DNSRecord>(create);
  static DNSRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get ttl => $_getIZ(2);
  @$pb.TagNumber(3)
  set ttl($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTtl() => $_has(2);
  @$pb.TagNumber(3)
  void clearTtl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get priority => $_getIZ(3);
  @$pb.TagNumber(4)
  set priority($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPriority() => $_has(3);
  @$pb.TagNumber(4)
  void clearPriority() => $_clearField(4);
}

/// Traceroute request
class TracerouteRequest extends $pb.GeneratedMessage {
  factory TracerouteRequest({
    $core.String? host,
    $core.int? maxHops,
    $core.int? timeout,
  }) {
    final result = create();
    if (host != null) result.host = host;
    if (maxHops != null) result.maxHops = maxHops;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  TracerouteRequest._();

  factory TracerouteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TracerouteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TracerouteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'host')
    ..aI(2, _omitFieldNames ? '' : 'maxHops')
    ..aI(3, _omitFieldNames ? '' : 'timeout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TracerouteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TracerouteRequest copyWith(void Function(TracerouteRequest) updates) =>
      super.copyWith((message) => updates(message as TracerouteRequest))
          as TracerouteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TracerouteRequest create() => TracerouteRequest._();
  @$core.override
  TracerouteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TracerouteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TracerouteRequest>(create);
  static TracerouteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get host => $_getSZ(0);
  @$pb.TagNumber(1)
  set host($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHost() => $_has(0);
  @$pb.TagNumber(1)
  void clearHost() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxHops => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxHops($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxHops() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxHops() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get timeout => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeout() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeout() => $_clearField(3);
}

/// Traceroute response (streamed)
class TracerouteResponse extends $pb.GeneratedMessage {
  factory TracerouteResponse({
    $core.int? hop,
    $core.String? ip,
    $core.String? hostname,
    $core.double? latency,
    $core.bool? timeout,
    $core.bool? finished,
    $core.String? error,
  }) {
    final result = create();
    if (hop != null) result.hop = hop;
    if (ip != null) result.ip = ip;
    if (hostname != null) result.hostname = hostname;
    if (latency != null) result.latency = latency;
    if (timeout != null) result.timeout = timeout;
    if (finished != null) result.finished = finished;
    if (error != null) result.error = error;
    return result;
  }

  TracerouteResponse._();

  factory TracerouteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TracerouteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TracerouteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'hop')
    ..aOS(2, _omitFieldNames ? '' : 'ip')
    ..aOS(3, _omitFieldNames ? '' : 'hostname')
    ..aD(4, _omitFieldNames ? '' : 'latency')
    ..aOB(5, _omitFieldNames ? '' : 'timeout')
    ..aOB(6, _omitFieldNames ? '' : 'finished')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TracerouteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TracerouteResponse copyWith(void Function(TracerouteResponse) updates) =>
      super.copyWith((message) => updates(message as TracerouteResponse))
          as TracerouteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TracerouteResponse create() => TracerouteResponse._();
  @$core.override
  TracerouteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TracerouteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TracerouteResponse>(create);
  static TracerouteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get hop => $_getIZ(0);
  @$pb.TagNumber(1)
  set hop($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHop() => $_has(0);
  @$pb.TagNumber(1)
  void clearHop() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ip => $_getSZ(1);
  @$pb.TagNumber(2)
  set ip($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIp() => $_has(1);
  @$pb.TagNumber(2)
  void clearIp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get hostname => $_getSZ(2);
  @$pb.TagNumber(3)
  set hostname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHostname() => $_has(2);
  @$pb.TagNumber(3)
  void clearHostname() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get latency => $_getN(3);
  @$pb.TagNumber(4)
  set latency($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLatency() => $_has(3);
  @$pb.TagNumber(4)
  void clearLatency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get timeout => $_getBF(4);
  @$pb.TagNumber(5)
  set timeout($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimeout() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimeout() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get finished => $_getBF(5);
  @$pb.TagNumber(6)
  set finished($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFinished() => $_has(5);
  @$pb.TagNumber(6)
  void clearFinished() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => $_clearField(7);
}

/// WiFi information
class WifiInfo extends $pb.GeneratedMessage {
  factory WifiInfo({
    $core.bool? connected,
    $core.String? ssid,
    $core.String? bssid,
    $core.int? signalStrength,
    $core.int? signalQuality,
    $core.double? frequency,
    $core.String? security,
    $core.double? linkSpeed,
    $core.String? ipAddress,
    $core.Iterable<WifiNetwork>? availableNetworks,
  }) {
    final result = create();
    if (connected != null) result.connected = connected;
    if (ssid != null) result.ssid = ssid;
    if (bssid != null) result.bssid = bssid;
    if (signalStrength != null) result.signalStrength = signalStrength;
    if (signalQuality != null) result.signalQuality = signalQuality;
    if (frequency != null) result.frequency = frequency;
    if (security != null) result.security = security;
    if (linkSpeed != null) result.linkSpeed = linkSpeed;
    if (ipAddress != null) result.ipAddress = ipAddress;
    if (availableNetworks != null)
      result.availableNetworks.addAll(availableNetworks);
    return result;
  }

  WifiInfo._();

  factory WifiInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WifiInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WifiInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'connected')
    ..aOS(2, _omitFieldNames ? '' : 'ssid')
    ..aOS(3, _omitFieldNames ? '' : 'bssid')
    ..aI(4, _omitFieldNames ? '' : 'signalStrength')
    ..aI(5, _omitFieldNames ? '' : 'signalQuality')
    ..aD(6, _omitFieldNames ? '' : 'frequency')
    ..aOS(7, _omitFieldNames ? '' : 'security')
    ..aD(8, _omitFieldNames ? '' : 'linkSpeed')
    ..aOS(9, _omitFieldNames ? '' : 'ipAddress')
    ..pPM<WifiNetwork>(10, _omitFieldNames ? '' : 'availableNetworks',
        subBuilder: WifiNetwork.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiInfo copyWith(void Function(WifiInfo) updates) =>
      super.copyWith((message) => updates(message as WifiInfo)) as WifiInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WifiInfo create() => WifiInfo._();
  @$core.override
  WifiInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WifiInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WifiInfo>(create);
  static WifiInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get connected => $_getBF(0);
  @$pb.TagNumber(1)
  set connected($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnected() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnected() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ssid => $_getSZ(1);
  @$pb.TagNumber(2)
  set ssid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSsid() => $_has(1);
  @$pb.TagNumber(2)
  void clearSsid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get bssid => $_getSZ(2);
  @$pb.TagNumber(3)
  set bssid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBssid() => $_has(2);
  @$pb.TagNumber(3)
  void clearBssid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get signalStrength => $_getIZ(3);
  @$pb.TagNumber(4)
  set signalStrength($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSignalStrength() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignalStrength() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get signalQuality => $_getIZ(4);
  @$pb.TagNumber(5)
  set signalQuality($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSignalQuality() => $_has(4);
  @$pb.TagNumber(5)
  void clearSignalQuality() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get frequency => $_getN(5);
  @$pb.TagNumber(6)
  set frequency($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFrequency() => $_has(5);
  @$pb.TagNumber(6)
  void clearFrequency() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get security => $_getSZ(6);
  @$pb.TagNumber(7)
  set security($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSecurity() => $_has(6);
  @$pb.TagNumber(7)
  void clearSecurity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get linkSpeed => $_getN(7);
  @$pb.TagNumber(8)
  set linkSpeed($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLinkSpeed() => $_has(7);
  @$pb.TagNumber(8)
  void clearLinkSpeed() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get ipAddress => $_getSZ(8);
  @$pb.TagNumber(9)
  set ipAddress($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIpAddress() => $_has(8);
  @$pb.TagNumber(9)
  void clearIpAddress() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<WifiNetwork> get availableNetworks => $_getList(9);
}

/// Available WiFi network
class WifiNetwork extends $pb.GeneratedMessage {
  factory WifiNetwork({
    $core.String? ssid,
    $core.String? bssid,
    $core.int? signalStrength,
    $core.int? signalQuality,
    $core.double? frequency,
    $core.String? security,
  }) {
    final result = create();
    if (ssid != null) result.ssid = ssid;
    if (bssid != null) result.bssid = bssid;
    if (signalStrength != null) result.signalStrength = signalStrength;
    if (signalQuality != null) result.signalQuality = signalQuality;
    if (frequency != null) result.frequency = frequency;
    if (security != null) result.security = security;
    return result;
  }

  WifiNetwork._();

  factory WifiNetwork.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WifiNetwork.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WifiNetwork',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ssid')
    ..aOS(2, _omitFieldNames ? '' : 'bssid')
    ..aI(3, _omitFieldNames ? '' : 'signalStrength')
    ..aI(4, _omitFieldNames ? '' : 'signalQuality')
    ..aD(5, _omitFieldNames ? '' : 'frequency')
    ..aOS(6, _omitFieldNames ? '' : 'security')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiNetwork clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiNetwork copyWith(void Function(WifiNetwork) updates) =>
      super.copyWith((message) => updates(message as WifiNetwork))
          as WifiNetwork;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WifiNetwork create() => WifiNetwork._();
  @$core.override
  WifiNetwork createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WifiNetwork getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WifiNetwork>(create);
  static WifiNetwork? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ssid => $_getSZ(0);
  @$pb.TagNumber(1)
  set ssid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSsid() => $_has(0);
  @$pb.TagNumber(1)
  void clearSsid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get bssid => $_getSZ(1);
  @$pb.TagNumber(2)
  set bssid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBssid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBssid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get signalStrength => $_getIZ(2);
  @$pb.TagNumber(3)
  set signalStrength($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSignalStrength() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignalStrength() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get signalQuality => $_getIZ(3);
  @$pb.TagNumber(4)
  set signalQuality($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSignalQuality() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignalQuality() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get frequency => $_getN(4);
  @$pb.TagNumber(5)
  set frequency($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFrequency() => $_has(4);
  @$pb.TagNumber(5)
  void clearFrequency() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get security => $_getSZ(5);
  @$pb.TagNumber(6)
  set security($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSecurity() => $_has(5);
  @$pb.TagNumber(6)
  void clearSecurity() => $_clearField(6);
}

/// Speed test request
class SpeedTestRequest extends $pb.GeneratedMessage {
  factory SpeedTestRequest({
    $core.bool? testDownload,
    $core.bool? testUpload,
    $core.int? duration,
  }) {
    final result = create();
    if (testDownload != null) result.testDownload = testDownload;
    if (testUpload != null) result.testUpload = testUpload;
    if (duration != null) result.duration = duration;
    return result;
  }

  SpeedTestRequest._();

  factory SpeedTestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpeedTestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpeedTestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'testDownload')
    ..aOB(2, _omitFieldNames ? '' : 'testUpload')
    ..aI(3, _omitFieldNames ? '' : 'duration')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedTestRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedTestRequest copyWith(void Function(SpeedTestRequest) updates) =>
      super.copyWith((message) => updates(message as SpeedTestRequest))
          as SpeedTestRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpeedTestRequest create() => SpeedTestRequest._();
  @$core.override
  SpeedTestRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpeedTestRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpeedTestRequest>(create);
  static SpeedTestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get testDownload => $_getBF(0);
  @$pb.TagNumber(1)
  set testDownload($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTestDownload() => $_has(0);
  @$pb.TagNumber(1)
  void clearTestDownload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get testUpload => $_getBF(1);
  @$pb.TagNumber(2)
  set testUpload($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTestUpload() => $_has(1);
  @$pb.TagNumber(2)
  void clearTestUpload() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get duration => $_getIZ(2);
  @$pb.TagNumber(3)
  set duration($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDuration() => $_has(2);
  @$pb.TagNumber(3)
  void clearDuration() => $_clearField(3);
}

/// Speed test response (streamed)
class SpeedTestResponse extends $pb.GeneratedMessage {
  factory SpeedTestResponse({
    $core.String? phase,
    $core.double? downloadSpeed,
    $core.double? uploadSpeed,
    $core.double? progress,
    $core.double? latency,
    $core.String? server,
    $core.bool? finished,
    $core.String? error,
  }) {
    final result = create();
    if (phase != null) result.phase = phase;
    if (downloadSpeed != null) result.downloadSpeed = downloadSpeed;
    if (uploadSpeed != null) result.uploadSpeed = uploadSpeed;
    if (progress != null) result.progress = progress;
    if (latency != null) result.latency = latency;
    if (server != null) result.server = server;
    if (finished != null) result.finished = finished;
    if (error != null) result.error = error;
    return result;
  }

  SpeedTestResponse._();

  factory SpeedTestResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpeedTestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpeedTestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'phase')
    ..aD(2, _omitFieldNames ? '' : 'downloadSpeed')
    ..aD(3, _omitFieldNames ? '' : 'uploadSpeed')
    ..aD(4, _omitFieldNames ? '' : 'progress')
    ..aD(5, _omitFieldNames ? '' : 'latency')
    ..aOS(6, _omitFieldNames ? '' : 'server')
    ..aOB(7, _omitFieldNames ? '' : 'finished')
    ..aOS(8, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedTestResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpeedTestResponse copyWith(void Function(SpeedTestResponse) updates) =>
      super.copyWith((message) => updates(message as SpeedTestResponse))
          as SpeedTestResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpeedTestResponse create() => SpeedTestResponse._();
  @$core.override
  SpeedTestResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpeedTestResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpeedTestResponse>(create);
  static SpeedTestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get phase => $_getSZ(0);
  @$pb.TagNumber(1)
  set phase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPhase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPhase() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get downloadSpeed => $_getN(1);
  @$pb.TagNumber(2)
  set downloadSpeed($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDownloadSpeed() => $_has(1);
  @$pb.TagNumber(2)
  void clearDownloadSpeed() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get uploadSpeed => $_getN(2);
  @$pb.TagNumber(3)
  set uploadSpeed($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUploadSpeed() => $_has(2);
  @$pb.TagNumber(3)
  void clearUploadSpeed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get progress => $_getN(3);
  @$pb.TagNumber(4)
  set progress($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProgress() => $_has(3);
  @$pb.TagNumber(4)
  void clearProgress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get latency => $_getN(4);
  @$pb.TagNumber(5)
  set latency($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLatency() => $_has(4);
  @$pb.TagNumber(5)
  void clearLatency() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get server => $_getSZ(5);
  @$pb.TagNumber(6)
  set server($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasServer() => $_has(5);
  @$pb.TagNumber(6)
  void clearServer() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get finished => $_getBF(6);
  @$pb.TagNumber(7)
  set finished($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFinished() => $_has(6);
  @$pb.TagNumber(7)
  void clearFinished() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get error => $_getSZ(7);
  @$pb.TagNumber(8)
  set error($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => $_clearField(8);
}

/// File chunk for streaming transfers
class FileChunk extends $pb.GeneratedMessage {
  factory FileChunk({
    $core.String? path,
    $core.List<$core.int>? data,
    $fixnum.Int64? offset,
    $fixnum.Int64? totalSize,
    $core.bool? isFinal,
    $core.String? error,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (data != null) result.data = data;
    if (offset != null) result.offset = offset;
    if (totalSize != null) result.totalSize = totalSize;
    if (isFinal != null) result.isFinal = isFinal;
    if (error != null) result.error = error;
    return result;
  }

  FileChunk._();

  factory FileChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'offset')
    ..aInt64(4, _omitFieldNames ? '' : 'totalSize')
    ..aOB(5, _omitFieldNames ? '' : 'isFinal')
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileChunk copyWith(void Function(FileChunk) updates) =>
      super.copyWith((message) => updates(message as FileChunk)) as FileChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileChunk create() => FileChunk._();
  @$core.override
  FileChunk createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileChunk>(create);
  static FileChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get offset => $_getI64(2);
  @$pb.TagNumber(3)
  set offset($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalSize => $_getI64(3);
  @$pb.TagNumber(4)
  set totalSize($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isFinal => $_getBF(4);
  @$pb.TagNumber(5)
  set isFinal($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsFinal() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsFinal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => $_clearField(6);
}

/// Upload response (after all chunks received)
class FileUploadResponse extends $pb.GeneratedMessage {
  factory FileUploadResponse({
    $core.bool? success,
    $core.String? path,
    $fixnum.Int64? bytesWritten,
    $core.String? error,
    $core.double? duration,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (path != null) result.path = path;
    if (bytesWritten != null) result.bytesWritten = bytesWritten;
    if (error != null) result.error = error;
    if (duration != null) result.duration = duration;
    return result;
  }

  FileUploadResponse._();

  factory FileUploadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileUploadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileUploadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'path')
    ..aInt64(3, _omitFieldNames ? '' : 'bytesWritten')
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..aD(5, _omitFieldNames ? '' : 'duration')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileUploadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileUploadResponse copyWith(void Function(FileUploadResponse) updates) =>
      super.copyWith((message) => updates(message as FileUploadResponse))
          as FileUploadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileUploadResponse create() => FileUploadResponse._();
  @$core.override
  FileUploadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileUploadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileUploadResponse>(create);
  static FileUploadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get path => $_getSZ(1);
  @$pb.TagNumber(2)
  set path($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get bytesWritten => $_getI64(2);
  @$pb.TagNumber(3)
  set bytesWritten($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBytesWritten() => $_has(2);
  @$pb.TagNumber(3)
  void clearBytesWritten() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get duration => $_getN(4);
  @$pb.TagNumber(5)
  set duration($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDuration() => $_has(4);
  @$pb.TagNumber(5)
  void clearDuration() => $_clearField(5);
}

/// Download request
class FileDownloadRequest extends $pb.GeneratedMessage {
  factory FileDownloadRequest({
    $core.String? path,
    $fixnum.Int64? offset,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (offset != null) result.offset = offset;
    return result;
  }

  FileDownloadRequest._();

  factory FileDownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileDownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileDownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aInt64(2, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileDownloadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileDownloadRequest copyWith(void Function(FileDownloadRequest) updates) =>
      super.copyWith((message) => updates(message as FileDownloadRequest))
          as FileDownloadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileDownloadRequest create() => FileDownloadRequest._();
  @$core.override
  FileDownloadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileDownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileDownloadRequest>(create);
  static FileDownloadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(2)
  set offset($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);
}

/// Delete request
class FileDeleteRequest extends $pb.GeneratedMessage {
  factory FileDeleteRequest({
    $core.String? path,
    $core.bool? isDirectory,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (isDirectory != null) result.isDirectory = isDirectory;
    return result;
  }

  FileDeleteRequest._();

  factory FileDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOB(2, _omitFieldNames ? '' : 'isDirectory')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileDeleteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileDeleteRequest copyWith(void Function(FileDeleteRequest) updates) =>
      super.copyWith((message) => updates(message as FileDeleteRequest))
          as FileDeleteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileDeleteRequest create() => FileDeleteRequest._();
  @$core.override
  FileDeleteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileDeleteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileDeleteRequest>(create);
  static FileDeleteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isDirectory => $_getBF(1);
  @$pb.TagNumber(2)
  set isDirectory($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsDirectory() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsDirectory() => $_clearField(2);
}

/// Delete response
class FileDeleteResponse extends $pb.GeneratedMessage {
  factory FileDeleteResponse({
    $core.bool? success,
    $core.String? path,
    $core.String? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (path != null) result.path = path;
    if (error != null) result.error = error;
    return result;
  }

  FileDeleteResponse._();

  factory FileDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'path')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileDeleteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileDeleteResponse copyWith(void Function(FileDeleteResponse) updates) =>
      super.copyWith((message) => updates(message as FileDeleteResponse))
          as FileDeleteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileDeleteResponse create() => FileDeleteResponse._();
  @$core.override
  FileDeleteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileDeleteResponse>(create);
  static FileDeleteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get path => $_getSZ(1);
  @$pb.TagNumber(2)
  set path($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
}

class DockerFilter extends $pb.GeneratedMessage {
  factory DockerFilter({
    $core.bool? all,
  }) {
    final result = create();
    if (all != null) result.all = all;
    return result;
  }

  DockerFilter._();

  factory DockerFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DockerFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DockerFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'all')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DockerFilter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DockerFilter copyWith(void Function(DockerFilter) updates) =>
      super.copyWith((message) => updates(message as DockerFilter))
          as DockerFilter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DockerFilter create() => DockerFilter._();
  @$core.override
  DockerFilter createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DockerFilter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DockerFilter>(create);
  static DockerFilter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get all => $_getBF(0);
  @$pb.TagNumber(1)
  set all($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAll() => $_has(0);
  @$pb.TagNumber(1)
  void clearAll() => $_clearField(1);
}

class ContainerId extends $pb.GeneratedMessage {
  factory ContainerId({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  ContainerId._();

  factory ContainerId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ContainerId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerId copyWith(void Function(ContainerId) updates) =>
      super.copyWith((message) => updates(message as ContainerId))
          as ContainerId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContainerId create() => ContainerId._();
  @$core.override
  ContainerId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ContainerId getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ContainerId>(create);
  static ContainerId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ContainerList extends $pb.GeneratedMessage {
  factory ContainerList({
    $core.Iterable<ContainerInfo>? containers,
  }) {
    final result = create();
    if (containers != null) result.containers.addAll(containers);
    return result;
  }

  ContainerList._();

  factory ContainerList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ContainerList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..pPM<ContainerInfo>(1, _omitFieldNames ? '' : 'containers',
        subBuilder: ContainerInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerList copyWith(void Function(ContainerList) updates) =>
      super.copyWith((message) => updates(message as ContainerList))
          as ContainerList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContainerList create() => ContainerList._();
  @$core.override
  ContainerList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ContainerList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ContainerList>(create);
  static ContainerList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ContainerInfo> get containers => $_getList(0);
}

class ContainerInfo extends $pb.GeneratedMessage {
  factory ContainerInfo({
    $core.String? id,
    $core.Iterable<$core.String>? names,
    $core.String? image,
    $core.String? state,
    $core.String? status,
    $fixnum.Int64? created,
    $core.Iterable<$core.String>? ports,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (names != null) result.names.addAll(names);
    if (image != null) result.image = image;
    if (state != null) result.state = state;
    if (status != null) result.status = status;
    if (created != null) result.created = created;
    if (ports != null) result.ports.addAll(ports);
    return result;
  }

  ContainerInfo._();

  factory ContainerInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ContainerInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..pPS(2, _omitFieldNames ? '' : 'names')
    ..aOS(3, _omitFieldNames ? '' : 'image')
    ..aOS(4, _omitFieldNames ? '' : 'state')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aInt64(6, _omitFieldNames ? '' : 'created')
    ..pPS(7, _omitFieldNames ? '' : 'ports')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerInfo copyWith(void Function(ContainerInfo) updates) =>
      super.copyWith((message) => updates(message as ContainerInfo))
          as ContainerInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContainerInfo create() => ContainerInfo._();
  @$core.override
  ContainerInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ContainerInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ContainerInfo>(create);
  static ContainerInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get names => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get image => $_getSZ(2);
  @$pb.TagNumber(3)
  set image($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImage() => $_has(2);
  @$pb.TagNumber(3)
  void clearImage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get state => $_getSZ(3);
  @$pb.TagNumber(4)
  set state($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasState() => $_has(3);
  @$pb.TagNumber(4)
  void clearState() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get created => $_getI64(5);
  @$pb.TagNumber(6)
  set created($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreated() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreated() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get ports => $_getList(6);
}

class LogRequest extends $pb.GeneratedMessage {
  factory LogRequest({
    $core.String? containerId,
    $core.bool? follow,
    $core.int? tail,
  }) {
    final result = create();
    if (containerId != null) result.containerId = containerId;
    if (follow != null) result.follow = follow;
    if (tail != null) result.tail = tail;
    return result;
  }

  LogRequest._();

  factory LogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'containerId')
    ..aOB(2, _omitFieldNames ? '' : 'follow')
    ..aI(3, _omitFieldNames ? '' : 'tail')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogRequest copyWith(void Function(LogRequest) updates) =>
      super.copyWith((message) => updates(message as LogRequest)) as LogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogRequest create() => LogRequest._();
  @$core.override
  LogRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogRequest>(create);
  static LogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get containerId => $_getSZ(0);
  @$pb.TagNumber(1)
  set containerId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContainerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearContainerId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get follow => $_getBF(1);
  @$pb.TagNumber(2)
  set follow($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFollow() => $_has(1);
  @$pb.TagNumber(2)
  void clearFollow() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get tail => $_getIZ(2);
  @$pb.TagNumber(3)
  set tail($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTail() => $_has(2);
  @$pb.TagNumber(3)
  void clearTail() => $_clearField(3);
}

class SystemUpdateStatus extends $pb.GeneratedMessage {
  factory SystemUpdateStatus({
    $core.String? osName,
    $core.String? kernelVersion,
    $core.String? architecture,
    $core.int? upgradableCount,
    $core.Iterable<UpgradablePackage>? upgradablePackages,
    $core.String? lastUpdate,
    $core.String? uptime,
  }) {
    final result = create();
    if (osName != null) result.osName = osName;
    if (kernelVersion != null) result.kernelVersion = kernelVersion;
    if (architecture != null) result.architecture = architecture;
    if (upgradableCount != null) result.upgradableCount = upgradableCount;
    if (upgradablePackages != null)
      result.upgradablePackages.addAll(upgradablePackages);
    if (lastUpdate != null) result.lastUpdate = lastUpdate;
    if (uptime != null) result.uptime = uptime;
    return result;
  }

  SystemUpdateStatus._();

  factory SystemUpdateStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SystemUpdateStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemUpdateStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'osName')
    ..aOS(2, _omitFieldNames ? '' : 'kernelVersion')
    ..aOS(3, _omitFieldNames ? '' : 'architecture')
    ..aI(4, _omitFieldNames ? '' : 'upgradableCount')
    ..pPM<UpgradablePackage>(5, _omitFieldNames ? '' : 'upgradablePackages',
        subBuilder: UpgradablePackage.create)
    ..aOS(6, _omitFieldNames ? '' : 'lastUpdate')
    ..aOS(7, _omitFieldNames ? '' : 'uptime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemUpdateStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemUpdateStatus copyWith(void Function(SystemUpdateStatus) updates) =>
      super.copyWith((message) => updates(message as SystemUpdateStatus))
          as SystemUpdateStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemUpdateStatus create() => SystemUpdateStatus._();
  @$core.override
  SystemUpdateStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SystemUpdateStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemUpdateStatus>(create);
  static SystemUpdateStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get osName => $_getSZ(0);
  @$pb.TagNumber(1)
  set osName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOsName() => $_has(0);
  @$pb.TagNumber(1)
  void clearOsName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get kernelVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set kernelVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKernelVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearKernelVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get architecture => $_getSZ(2);
  @$pb.TagNumber(3)
  set architecture($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasArchitecture() => $_has(2);
  @$pb.TagNumber(3)
  void clearArchitecture() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get upgradableCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set upgradableCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUpgradableCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearUpgradableCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<UpgradablePackage> get upgradablePackages => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get lastUpdate => $_getSZ(5);
  @$pb.TagNumber(6)
  set lastUpdate($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastUpdate() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastUpdate() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get uptime => $_getSZ(6);
  @$pb.TagNumber(7)
  set uptime($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUptime() => $_has(6);
  @$pb.TagNumber(7)
  void clearUptime() => $_clearField(7);
}

class UpgradablePackage extends $pb.GeneratedMessage {
  factory UpgradablePackage({
    $core.String? name,
    $core.String? currentVersion,
    $core.String? newVersion,
    $core.String? architecture,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (currentVersion != null) result.currentVersion = currentVersion;
    if (newVersion != null) result.newVersion = newVersion;
    if (architecture != null) result.architecture = architecture;
    return result;
  }

  UpgradablePackage._();

  factory UpgradablePackage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpgradablePackage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpgradablePackage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'currentVersion')
    ..aOS(3, _omitFieldNames ? '' : 'newVersion')
    ..aOS(4, _omitFieldNames ? '' : 'architecture')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpgradablePackage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpgradablePackage copyWith(void Function(UpgradablePackage) updates) =>
      super.copyWith((message) => updates(message as UpgradablePackage))
          as UpgradablePackage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpgradablePackage create() => UpgradablePackage._();
  @$core.override
  UpgradablePackage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpgradablePackage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpgradablePackage>(create);
  static UpgradablePackage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get currentVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set currentVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get newVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set newVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get architecture => $_getSZ(3);
  @$pb.TagNumber(4)
  set architecture($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasArchitecture() => $_has(3);
  @$pb.TagNumber(4)
  void clearArchitecture() => $_clearField(4);
}

class UpgradeProgress extends $pb.GeneratedMessage {
  factory UpgradeProgress({
    $core.String? line,
    $core.String? phase,
    $core.int? percent,
    $core.bool? isComplete,
    $core.bool? success,
  }) {
    final result = create();
    if (line != null) result.line = line;
    if (phase != null) result.phase = phase;
    if (percent != null) result.percent = percent;
    if (isComplete != null) result.isComplete = isComplete;
    if (success != null) result.success = success;
    return result;
  }

  UpgradeProgress._();

  factory UpgradeProgress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpgradeProgress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpgradeProgress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'line')
    ..aOS(2, _omitFieldNames ? '' : 'phase')
    ..aI(3, _omitFieldNames ? '' : 'percent')
    ..aOB(4, _omitFieldNames ? '' : 'isComplete')
    ..aOB(5, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpgradeProgress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpgradeProgress copyWith(void Function(UpgradeProgress) updates) =>
      super.copyWith((message) => updates(message as UpgradeProgress))
          as UpgradeProgress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpgradeProgress create() => UpgradeProgress._();
  @$core.override
  UpgradeProgress createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpgradeProgress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpgradeProgress>(create);
  static UpgradeProgress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get line => $_getSZ(0);
  @$pb.TagNumber(1)
  set line($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLine() => $_has(0);
  @$pb.TagNumber(1)
  void clearLine() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get phase => $_getSZ(1);
  @$pb.TagNumber(2)
  set phase($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPhase() => $_has(1);
  @$pb.TagNumber(2)
  void clearPhase() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get percent => $_getIZ(2);
  @$pb.TagNumber(3)
  set percent($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPercent() => $_has(2);
  @$pb.TagNumber(3)
  void clearPercent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isComplete => $_getBF(3);
  @$pb.TagNumber(4)
  set isComplete($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsComplete() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsComplete() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get success => $_getBF(4);
  @$pb.TagNumber(5)
  set success($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSuccess() => $_has(4);
  @$pb.TagNumber(5)
  void clearSuccess() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
