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
  factory Empty() => Empty._();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Empty()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Empty.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Empty() / Empty.new instead')
  static Empty create() => Empty._();
  static $pb.GeneratedMessage $_createMessage() => Empty._();
  @$core.override
  Empty createEmptyInstance() => Empty._();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Empty>(Empty.$_createMessage);
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
    final result = LiveStats._();
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
      LiveStats()..mergeFromBuffer(data, registry);
  factory LiveStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LiveStats()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LiveStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: LiveStats.$_createMessage)
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
        subBuilder: ProcessInfo.$_createMessage)
    ..aInt64(18, _omitFieldNames ? '' : 'timestamp')
    ..pPM<DiskIOStat>(19, _omitFieldNames ? '' : 'diskIo',
        subBuilder: DiskIOStat.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LiveStats copyWith(void Function(LiveStats) updates) =>
      super.copyWith((message) => updates(message as LiveStats)) as LiveStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LiveStats() / LiveStats.new instead')
  static LiveStats create() => LiveStats._();
  static $pb.GeneratedMessage $_createMessage() => LiveStats._();
  @$core.override
  LiveStats createEmptyInstance() => LiveStats._();
  @$core.pragma('dart2js:noInline')
  static LiveStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LiveStats>(LiveStats.$_createMessage);
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
    $core.int? ppid,
  }) {
    final result = ProcessInfo._();
    if (pid != null) result.pid = pid;
    if (name != null) result.name = name;
    if (cpuPercent != null) result.cpuPercent = cpuPercent;
    if (memoryPercent != null) result.memoryPercent = memoryPercent;
    if (memoryBytes != null) result.memoryBytes = memoryBytes;
    if (status != null) result.status = status;
    if (username != null) result.username = username;
    if (cmdline != null) result.cmdline = cmdline;
    if (ppid != null) result.ppid = ppid;
    return result;
  }

  ProcessInfo._();

  factory ProcessInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessInfo()..mergeFromBuffer(data, registry);
  factory ProcessInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ProcessInfo.$_createMessage)
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
    ..aI(9, _omitFieldNames ? '' : 'ppid')
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
  @$core.Deprecated('Use ProcessInfo() / ProcessInfo.new instead')
  static ProcessInfo create() => ProcessInfo._();
  static $pb.GeneratedMessage $_createMessage() => ProcessInfo._();
  @$core.override
  ProcessInfo createEmptyInstance() => ProcessInfo._();
  @$core.pragma('dart2js:noInline')
  static ProcessInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessInfo>(
          ProcessInfo.$_createMessage);
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

  @$pb.TagNumber(9)
  $core.int get ppid => $_getIZ(8);
  @$pb.TagNumber(9)
  set ppid($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPpid() => $_has(8);
  @$pb.TagNumber(9)
  void clearPpid() => $_clearField(9);
}

/// List of all processes
class ProcessList extends $pb.GeneratedMessage {
  factory ProcessList({
    $core.Iterable<ProcessInfo>? processes,
  }) {
    final result = ProcessList._();
    if (processes != null) result.processes.addAll(processes);
    return result;
  }

  ProcessList._();

  factory ProcessList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessList()..mergeFromBuffer(data, registry);
  factory ProcessList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ProcessList.$_createMessage)
    ..pPM<ProcessInfo>(1, _omitFieldNames ? '' : 'processes',
        subBuilder: ProcessInfo.$_createMessage)
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
  @$core.Deprecated('Use ProcessList() / ProcessList.new instead')
  static ProcessList create() => ProcessList._();
  static $pb.GeneratedMessage $_createMessage() => ProcessList._();
  @$core.override
  ProcessList createEmptyInstance() => ProcessList._();
  @$core.pragma('dart2js:noInline')
  static ProcessList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessList>(
          ProcessList.$_createMessage);
  static ProcessList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProcessInfo> get processes => $_getList(0);
}

/// Process ID for kill operations
class ProcessId extends $pb.GeneratedMessage {
  factory ProcessId({
    $core.int? pid,
  }) {
    final result = ProcessId._();
    if (pid != null) result.pid = pid;
    return result;
  }

  ProcessId._();

  factory ProcessId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessId()..mergeFromBuffer(data, registry);
  factory ProcessId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessId()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ProcessId.$_createMessage)
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
  @$core.Deprecated('Use ProcessId() / ProcessId.new instead')
  static ProcessId create() => ProcessId._();
  static $pb.GeneratedMessage $_createMessage() => ProcessId._();
  @$core.override
  ProcessId createEmptyInstance() => ProcessId._();
  @$core.pragma('dart2js:noInline')
  static ProcessId getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessId>(ProcessId.$_createMessage);
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
    final result = ServiceInfo._();
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
      ServiceInfo()..mergeFromBuffer(data, registry);
  factory ServiceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServiceInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ServiceInfo.$_createMessage)
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
  @$core.Deprecated('Use ServiceInfo() / ServiceInfo.new instead')
  static ServiceInfo create() => ServiceInfo._();
  static $pb.GeneratedMessage $_createMessage() => ServiceInfo._();
  @$core.override
  ServiceInfo createEmptyInstance() => ServiceInfo._();
  @$core.pragma('dart2js:noInline')
  static ServiceInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServiceInfo>(
          ServiceInfo.$_createMessage);
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
    final result = ServiceList._();
    if (services != null) result.services.addAll(services);
    return result;
  }

  ServiceList._();

  factory ServiceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServiceList()..mergeFromBuffer(data, registry);
  factory ServiceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServiceList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ServiceList.$_createMessage)
    ..pPM<ServiceInfo>(1, _omitFieldNames ? '' : 'services',
        subBuilder: ServiceInfo.$_createMessage)
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
  @$core.Deprecated('Use ServiceList() / ServiceList.new instead')
  static ServiceList create() => ServiceList._();
  static $pb.GeneratedMessage $_createMessage() => ServiceList._();
  @$core.override
  ServiceList createEmptyInstance() => ServiceList._();
  @$core.pragma('dart2js:noInline')
  static ServiceList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServiceList>(
          ServiceList.$_createMessage);
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
    final result = ServiceCommand._();
    if (serviceName != null) result.serviceName = serviceName;
    if (action != null) result.action = action;
    return result;
  }

  ServiceCommand._();

  factory ServiceCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServiceCommand()..mergeFromBuffer(data, registry);
  factory ServiceCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ServiceCommand()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServiceCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ServiceCommand.$_createMessage)
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
  @$core.Deprecated('Use ServiceCommand() / ServiceCommand.new instead')
  static ServiceCommand create() => ServiceCommand._();
  static $pb.GeneratedMessage $_createMessage() => ServiceCommand._();
  @$core.override
  ServiceCommand createEmptyInstance() => ServiceCommand._();
  @$core.pragma('dart2js:noInline')
  static ServiceCommand getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ServiceCommand>(
          ServiceCommand.$_createMessage);
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
    final result = ActionStatus._();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (errorCode != null) result.errorCode = errorCode;
    return result;
  }

  ActionStatus._();

  factory ActionStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionStatus()..mergeFromBuffer(data, registry);
  factory ActionStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ActionStatus.$_createMessage)
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
  @$core.Deprecated('Use ActionStatus() / ActionStatus.new instead')
  static ActionStatus create() => ActionStatus._();
  static $pb.GeneratedMessage $_createMessage() => ActionStatus._();
  @$core.override
  ActionStatus createEmptyInstance() => ActionStatus._();
  @$core.pragma('dart2js:noInline')
  static ActionStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionStatus>(
          ActionStatus.$_createMessage);
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
    final result = LogFilter._();
    if (levels != null) result.levels.addAll(levels);
    if (service != null) result.service = service;
    if (tailLines != null) result.tailLines = tailLines;
    return result;
  }

  LogFilter._();

  factory LogFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogFilter()..mergeFromBuffer(data, registry);
  factory LogFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogFilter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: LogFilter.$_createMessage)
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
  @$core.Deprecated('Use LogFilter() / LogFilter.new instead')
  static LogFilter create() => LogFilter._();
  static $pb.GeneratedMessage $_createMessage() => LogFilter._();
  @$core.override
  LogFilter createEmptyInstance() => LogFilter._();
  @$core.pragma('dart2js:noInline')
  static LogFilter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogFilter>(LogFilter.$_createMessage);
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
    final result = LogEntry._();
    if (timestamp != null) result.timestamp = timestamp;
    if (level != null) result.level = level;
    if (service != null) result.service = service;
    if (message != null) result.message = message;
    return result;
  }

  LogEntry._();

  factory LogEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogEntry()..mergeFromBuffer(data, registry);
  factory LogEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: LogEntry.$_createMessage)
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
  @$core.Deprecated('Use LogEntry() / LogEntry.new instead')
  static LogEntry create() => LogEntry._();
  static $pb.GeneratedMessage $_createMessage() => LogEntry._();
  @$core.override
  LogEntry createEmptyInstance() => LogEntry._();
  @$core.pragma('dart2js:noInline')
  static LogEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogEntry>(LogEntry.$_createMessage);
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
    final result = DiskInfo._();
    if (partitions != null) result.partitions.addAll(partitions);
    return result;
  }

  DiskInfo._();

  factory DiskInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiskInfo()..mergeFromBuffer(data, registry);
  factory DiskInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiskInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiskInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DiskInfo.$_createMessage)
    ..pPM<DiskPartition>(1, _omitFieldNames ? '' : 'partitions',
        subBuilder: DiskPartition.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiskInfo copyWith(void Function(DiskInfo) updates) =>
      super.copyWith((message) => updates(message as DiskInfo)) as DiskInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DiskInfo() / DiskInfo.new instead')
  static DiskInfo create() => DiskInfo._();
  static $pb.GeneratedMessage $_createMessage() => DiskInfo._();
  @$core.override
  DiskInfo createEmptyInstance() => DiskInfo._();
  @$core.pragma('dart2js:noInline')
  static DiskInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiskInfo>(DiskInfo.$_createMessage);
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
    final result = DiskPartition._();
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
      DiskPartition()..mergeFromBuffer(data, registry);
  factory DiskPartition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiskPartition()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiskPartition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DiskPartition.$_createMessage)
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
  @$core.Deprecated('Use DiskPartition() / DiskPartition.new instead')
  static DiskPartition create() => DiskPartition._();
  static $pb.GeneratedMessage $_createMessage() => DiskPartition._();
  @$core.override
  DiskPartition createEmptyInstance() => DiskPartition._();
  @$core.pragma('dart2js:noInline')
  static DiskPartition getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiskPartition>(
          DiskPartition.$_createMessage);
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
    final result = NetworkInfo._();
    if (interfaces != null) result.interfaces.addAll(interfaces);
    return result;
  }

  NetworkInfo._();

  factory NetworkInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkInfo()..mergeFromBuffer(data, registry);
  factory NetworkInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: NetworkInfo.$_createMessage)
    ..pPM<NetworkInterface>(1, _omitFieldNames ? '' : 'interfaces',
        subBuilder: NetworkInterface.$_createMessage)
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
  @$core.Deprecated('Use NetworkInfo() / NetworkInfo.new instead')
  static NetworkInfo create() => NetworkInfo._();
  static $pb.GeneratedMessage $_createMessage() => NetworkInfo._();
  @$core.override
  NetworkInfo createEmptyInstance() => NetworkInfo._();
  @$core.pragma('dart2js:noInline')
  static NetworkInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkInfo>(
          NetworkInfo.$_createMessage);
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
    final result = NetworkInterface._();
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
      NetworkInterface()..mergeFromBuffer(data, registry);
  factory NetworkInterface.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkInterface()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkInterface',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: NetworkInterface.$_createMessage)
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
  @$core.Deprecated('Use NetworkInterface() / NetworkInterface.new instead')
  static NetworkInterface create() => NetworkInterface._();
  static $pb.GeneratedMessage $_createMessage() => NetworkInterface._();
  @$core.override
  NetworkInterface createEmptyInstance() => NetworkInterface._();
  @$core.pragma('dart2js:noInline')
  static NetworkInterface getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkInterface>(
          NetworkInterface.$_createMessage);
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
    final result = NetworkConnectionList._();
    if (connections != null) result.connections.addAll(connections);
    return result;
  }

  NetworkConnectionList._();

  factory NetworkConnectionList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkConnectionList()..mergeFromBuffer(data, registry);
  factory NetworkConnectionList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkConnectionList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkConnectionList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: NetworkConnectionList.$_createMessage)
    ..pPM<NetworkConnection>(1, _omitFieldNames ? '' : 'connections',
        subBuilder: NetworkConnection.$_createMessage)
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
  @$core.Deprecated(
      'Use NetworkConnectionList() / NetworkConnectionList.new instead')
  static NetworkConnectionList create() => NetworkConnectionList._();
  static $pb.GeneratedMessage $_createMessage() => NetworkConnectionList._();
  @$core.override
  NetworkConnectionList createEmptyInstance() => NetworkConnectionList._();
  @$core.pragma('dart2js:noInline')
  static NetworkConnectionList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NetworkConnectionList>(
          NetworkConnectionList.$_createMessage);
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
    final result = NetworkConnection._();
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
      NetworkConnection()..mergeFromBuffer(data, registry);
  factory NetworkConnection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NetworkConnection()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NetworkConnection',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: NetworkConnection.$_createMessage)
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
  @$core.Deprecated('Use NetworkConnection() / NetworkConnection.new instead')
  static NetworkConnection create() => NetworkConnection._();
  static $pb.GeneratedMessage $_createMessage() => NetworkConnection._();
  @$core.override
  NetworkConnection createEmptyInstance() => NetworkConnection._();
  @$core.pragma('dart2js:noInline')
  static NetworkConnection getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NetworkConnection>(
          NetworkConnection.$_createMessage);
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
    final result = PackageFilter._();
    if (searchTerm != null) result.searchTerm = searchTerm;
    if (installedOnly != null) result.installedOnly = installedOnly;
    return result;
  }

  PackageFilter._();

  factory PackageFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageFilter()..mergeFromBuffer(data, registry);
  factory PackageFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageFilter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageFilter.$_createMessage)
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
  @$core.Deprecated('Use PackageFilter() / PackageFilter.new instead')
  static PackageFilter create() => PackageFilter._();
  static $pb.GeneratedMessage $_createMessage() => PackageFilter._();
  @$core.override
  PackageFilter createEmptyInstance() => PackageFilter._();
  @$core.pragma('dart2js:noInline')
  static PackageFilter getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackageFilter>(
          PackageFilter.$_createMessage);
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
    final result = PackageInfo._();
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
      PackageInfo()..mergeFromBuffer(data, registry);
  factory PackageInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageInfo.$_createMessage)
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
  @$core.Deprecated('Use PackageInfo() / PackageInfo.new instead')
  static PackageInfo create() => PackageInfo._();
  static $pb.GeneratedMessage $_createMessage() => PackageInfo._();
  @$core.override
  PackageInfo createEmptyInstance() => PackageInfo._();
  @$core.pragma('dart2js:noInline')
  static PackageInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackageInfo>(
          PackageInfo.$_createMessage);
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
    final result = PackageList._();
    if (packages != null) result.packages.addAll(packages);
    return result;
  }

  PackageList._();

  factory PackageList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageList()..mergeFromBuffer(data, registry);
  factory PackageList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageList.$_createMessage)
    ..pPM<PackageInfo>(1, _omitFieldNames ? '' : 'packages',
        subBuilder: PackageInfo.$_createMessage)
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
  @$core.Deprecated('Use PackageList() / PackageList.new instead')
  static PackageList create() => PackageList._();
  static $pb.GeneratedMessage $_createMessage() => PackageList._();
  @$core.override
  PackageList createEmptyInstance() => PackageList._();
  @$core.pragma('dart2js:noInline')
  static PackageList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackageList>(
          PackageList.$_createMessage);
  static PackageList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PackageInfo> get packages => $_getList(0);
}

class PackageCommand extends $pb.GeneratedMessage {
  factory PackageCommand({
    $core.String? packageName,
  }) {
    final result = PackageCommand._();
    if (packageName != null) result.packageName = packageName;
    return result;
  }

  PackageCommand._();

  factory PackageCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageCommand()..mergeFromBuffer(data, registry);
  factory PackageCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageCommand()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageCommand.$_createMessage)
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
  @$core.Deprecated('Use PackageCommand() / PackageCommand.new instead')
  static PackageCommand create() => PackageCommand._();
  static $pb.GeneratedMessage $_createMessage() => PackageCommand._();
  @$core.override
  PackageCommand createEmptyInstance() => PackageCommand._();
  @$core.pragma('dart2js:noInline')
  static PackageCommand getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackageCommand>(
          PackageCommand.$_createMessage);
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
    final result = PackageDetailsRequest._();
    if (packageName != null) result.packageName = packageName;
    return result;
  }

  PackageDetailsRequest._();

  factory PackageDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageDetailsRequest()..mergeFromBuffer(data, registry);
  factory PackageDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageDetailsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageDetailsRequest.$_createMessage)
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
  @$core.Deprecated(
      'Use PackageDetailsRequest() / PackageDetailsRequest.new instead')
  static PackageDetailsRequest create() => PackageDetailsRequest._();
  static $pb.GeneratedMessage $_createMessage() => PackageDetailsRequest._();
  @$core.override
  PackageDetailsRequest createEmptyInstance() => PackageDetailsRequest._();
  @$core.pragma('dart2js:noInline')
  static PackageDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageDetailsRequest>(
          PackageDetailsRequest.$_createMessage);
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
    final result = PackageDetails._();
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
      PackageDetails()..mergeFromBuffer(data, registry);
  factory PackageDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageDetails()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageDetails.$_createMessage)
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
  @$core.Deprecated('Use PackageDetails() / PackageDetails.new instead')
  static PackageDetails create() => PackageDetails._();
  static $pb.GeneratedMessage $_createMessage() => PackageDetails._();
  @$core.override
  PackageDetails createEmptyInstance() => PackageDetails._();
  @$core.pragma('dart2js:noInline')
  static PackageDetails getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PackageDetails>(
          PackageDetails.$_createMessage);
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
    final result = PackageDependencies._();
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
      PackageDependencies()..mergeFromBuffer(data, registry);
  factory PackageDependencies.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageDependencies()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageDependencies',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageDependencies.$_createMessage)
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
  @$core
      .Deprecated('Use PackageDependencies() / PackageDependencies.new instead')
  static PackageDependencies create() => PackageDependencies._();
  static $pb.GeneratedMessage $_createMessage() => PackageDependencies._();
  @$core.override
  PackageDependencies createEmptyInstance() => PackageDependencies._();
  @$core.pragma('dart2js:noInline')
  static PackageDependencies getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageDependencies>(
          PackageDependencies.$_createMessage);
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
    final result = PackageOperationLog._();
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
      PackageOperationLog()..mergeFromBuffer(data, registry);
  factory PackageOperationLog.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PackageOperationLog()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageOperationLog',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PackageOperationLog.$_createMessage)
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
  @$core
      .Deprecated('Use PackageOperationLog() / PackageOperationLog.new instead')
  static PackageOperationLog create() => PackageOperationLog._();
  static $pb.GeneratedMessage $_createMessage() => PackageOperationLog._();
  @$core.override
  PackageOperationLog createEmptyInstance() => PackageOperationLog._();
  @$core.pragma('dart2js:noInline')
  static PackageOperationLog getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageOperationLog>(
          PackageOperationLog.$_createMessage);
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
    final result = DiskIOStat._();
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
      DiskIOStat()..mergeFromBuffer(data, registry);
  factory DiskIOStat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DiskIOStat()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiskIOStat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DiskIOStat.$_createMessage)
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
  @$core.Deprecated('Use DiskIOStat() / DiskIOStat.new instead')
  static DiskIOStat create() => DiskIOStat._();
  static $pb.GeneratedMessage $_createMessage() => DiskIOStat._();
  @$core.override
  DiskIOStat createEmptyInstance() => DiskIOStat._();
  @$core.pragma('dart2js:noInline')
  static DiskIOStat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiskIOStat>(DiskIOStat.$_createMessage);
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
    final result = VersionInfo._();
    if (version != null) result.version = version;
    if (isRoot != null) result.isRoot = isRoot;
    return result;
  }

  VersionInfo._();

  factory VersionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VersionInfo()..mergeFromBuffer(data, registry);
  factory VersionInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VersionInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VersionInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: VersionInfo.$_createMessage)
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
  @$core.Deprecated('Use VersionInfo() / VersionInfo.new instead')
  static VersionInfo create() => VersionInfo._();
  static $pb.GeneratedMessage $_createMessage() => VersionInfo._();
  @$core.override
  VersionInfo createEmptyInstance() => VersionInfo._();
  @$core.pragma('dart2js:noInline')
  static VersionInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionInfo>(
          VersionInfo.$_createMessage);
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
    final result = PingRequest._();
    if (host != null) result.host = host;
    if (count != null) result.count = count;
    if (timeout != null) result.timeout = timeout;
    if (packetSize != null) result.packetSize = packetSize;
    return result;
  }

  PingRequest._();

  factory PingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingRequest()..mergeFromBuffer(data, registry);
  factory PingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PingRequest.$_createMessage)
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
  @$core.Deprecated('Use PingRequest() / PingRequest.new instead')
  static PingRequest create() => PingRequest._();
  static $pb.GeneratedMessage $_createMessage() => PingRequest._();
  @$core.override
  PingRequest createEmptyInstance() => PingRequest._();
  @$core.pragma('dart2js:noInline')
  static PingRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingRequest>(
          PingRequest.$_createMessage);
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
    final result = PingResponse._();
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
      PingResponse()..mergeFromBuffer(data, registry);
  factory PingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PingResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'host')
    ..aOS(3, _omitFieldNames ? '' : 'ip')
    ..aD(4, _omitFieldNames ? '' : 'latency')
    ..aI(5, _omitFieldNames ? '' : 'sequence')
    ..aI(6, _omitFieldNames ? '' : 'ttl')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..aOB(8, _omitFieldNames ? '' : 'finished')
    ..aOM<PingStats>(9, _omitFieldNames ? '' : 'statistics',
        subBuilder: PingStats.$_createMessage)
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
  @$core.Deprecated('Use PingResponse() / PingResponse.new instead')
  static PingResponse create() => PingResponse._();
  static $pb.GeneratedMessage $_createMessage() => PingResponse._();
  @$core.override
  PingResponse createEmptyInstance() => PingResponse._();
  @$core.pragma('dart2js:noInline')
  static PingResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingResponse>(
          PingResponse.$_createMessage);
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
    final result = PingStats._();
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
      PingStats()..mergeFromBuffer(data, registry);
  factory PingStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PingStats()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PingStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PingStats.$_createMessage)
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
  @$core.Deprecated('Use PingStats() / PingStats.new instead')
  static PingStats create() => PingStats._();
  static $pb.GeneratedMessage $_createMessage() => PingStats._();
  @$core.override
  PingStats createEmptyInstance() => PingStats._();
  @$core.pragma('dart2js:noInline')
  static PingStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PingStats>(PingStats.$_createMessage);
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
    final result = PortScanRequest._();
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
      PortScanRequest()..mergeFromBuffer(data, registry);
  factory PortScanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortScanRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortScanRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PortScanRequest.$_createMessage)
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
  @$core.Deprecated('Use PortScanRequest() / PortScanRequest.new instead')
  static PortScanRequest create() => PortScanRequest._();
  static $pb.GeneratedMessage $_createMessage() => PortScanRequest._();
  @$core.override
  PortScanRequest createEmptyInstance() => PortScanRequest._();
  @$core.pragma('dart2js:noInline')
  static PortScanRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortScanRequest>(
          PortScanRequest.$_createMessage);
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
    final result = PortScanResponse._();
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
      PortScanResponse()..mergeFromBuffer(data, registry);
  factory PortScanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PortScanResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PortScanResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PortScanResponse.$_createMessage)
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
  @$core.Deprecated('Use PortScanResponse() / PortScanResponse.new instead')
  static PortScanResponse create() => PortScanResponse._();
  static $pb.GeneratedMessage $_createMessage() => PortScanResponse._();
  @$core.override
  PortScanResponse createEmptyInstance() => PortScanResponse._();
  @$core.pragma('dart2js:noInline')
  static PortScanResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PortScanResponse>(
          PortScanResponse.$_createMessage);
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
    final result = DNSRequest._();
    if (hostname != null) result.hostname = hostname;
    if (recordType != null) result.recordType = recordType;
    return result;
  }

  DNSRequest._();

  factory DNSRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DNSRequest()..mergeFromBuffer(data, registry);
  factory DNSRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DNSRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DNSRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DNSRequest.$_createMessage)
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
  @$core.Deprecated('Use DNSRequest() / DNSRequest.new instead')
  static DNSRequest create() => DNSRequest._();
  static $pb.GeneratedMessage $_createMessage() => DNSRequest._();
  @$core.override
  DNSRequest createEmptyInstance() => DNSRequest._();
  @$core.pragma('dart2js:noInline')
  static DNSRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DNSRequest>(DNSRequest.$_createMessage);
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
    final result = DNSResponse._();
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
      DNSResponse()..mergeFromBuffer(data, registry);
  factory DNSResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DNSResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DNSResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DNSResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'hostname')
    ..pPS(3, _omitFieldNames ? '' : 'addresses')
    ..pPM<DNSRecord>(4, _omitFieldNames ? '' : 'records',
        subBuilder: DNSRecord.$_createMessage)
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
  @$core.Deprecated('Use DNSResponse() / DNSResponse.new instead')
  static DNSResponse create() => DNSResponse._();
  static $pb.GeneratedMessage $_createMessage() => DNSResponse._();
  @$core.override
  DNSResponse createEmptyInstance() => DNSResponse._();
  @$core.pragma('dart2js:noInline')
  static DNSResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DNSResponse>(
          DNSResponse.$_createMessage);
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
    final result = DNSRecord._();
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    if (ttl != null) result.ttl = ttl;
    if (priority != null) result.priority = priority;
    return result;
  }

  DNSRecord._();

  factory DNSRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DNSRecord()..mergeFromBuffer(data, registry);
  factory DNSRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DNSRecord()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DNSRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DNSRecord.$_createMessage)
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
  @$core.Deprecated('Use DNSRecord() / DNSRecord.new instead')
  static DNSRecord create() => DNSRecord._();
  static $pb.GeneratedMessage $_createMessage() => DNSRecord._();
  @$core.override
  DNSRecord createEmptyInstance() => DNSRecord._();
  @$core.pragma('dart2js:noInline')
  static DNSRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DNSRecord>(DNSRecord.$_createMessage);
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
    final result = TracerouteRequest._();
    if (host != null) result.host = host;
    if (maxHops != null) result.maxHops = maxHops;
    if (timeout != null) result.timeout = timeout;
    return result;
  }

  TracerouteRequest._();

  factory TracerouteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TracerouteRequest()..mergeFromBuffer(data, registry);
  factory TracerouteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TracerouteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TracerouteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: TracerouteRequest.$_createMessage)
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
  @$core.Deprecated('Use TracerouteRequest() / TracerouteRequest.new instead')
  static TracerouteRequest create() => TracerouteRequest._();
  static $pb.GeneratedMessage $_createMessage() => TracerouteRequest._();
  @$core.override
  TracerouteRequest createEmptyInstance() => TracerouteRequest._();
  @$core.pragma('dart2js:noInline')
  static TracerouteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TracerouteRequest>(
          TracerouteRequest.$_createMessage);
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
    final result = TracerouteResponse._();
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
      TracerouteResponse()..mergeFromBuffer(data, registry);
  factory TracerouteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TracerouteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TracerouteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: TracerouteResponse.$_createMessage)
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
  @$core.Deprecated('Use TracerouteResponse() / TracerouteResponse.new instead')
  static TracerouteResponse create() => TracerouteResponse._();
  static $pb.GeneratedMessage $_createMessage() => TracerouteResponse._();
  @$core.override
  TracerouteResponse createEmptyInstance() => TracerouteResponse._();
  @$core.pragma('dart2js:noInline')
  static TracerouteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TracerouteResponse>(
          TracerouteResponse.$_createMessage);
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
    final result = WifiInfo._();
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
      WifiInfo()..mergeFromBuffer(data, registry);
  factory WifiInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WifiInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WifiInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: WifiInfo.$_createMessage)
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
        subBuilder: WifiNetwork.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WifiInfo copyWith(void Function(WifiInfo) updates) =>
      super.copyWith((message) => updates(message as WifiInfo)) as WifiInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WifiInfo() / WifiInfo.new instead')
  static WifiInfo create() => WifiInfo._();
  static $pb.GeneratedMessage $_createMessage() => WifiInfo._();
  @$core.override
  WifiInfo createEmptyInstance() => WifiInfo._();
  @$core.pragma('dart2js:noInline')
  static WifiInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WifiInfo>(WifiInfo.$_createMessage);
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
    final result = WifiNetwork._();
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
      WifiNetwork()..mergeFromBuffer(data, registry);
  factory WifiNetwork.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WifiNetwork()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WifiNetwork',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: WifiNetwork.$_createMessage)
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
  @$core.Deprecated('Use WifiNetwork() / WifiNetwork.new instead')
  static WifiNetwork create() => WifiNetwork._();
  static $pb.GeneratedMessage $_createMessage() => WifiNetwork._();
  @$core.override
  WifiNetwork createEmptyInstance() => WifiNetwork._();
  @$core.pragma('dart2js:noInline')
  static WifiNetwork getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WifiNetwork>(
          WifiNetwork.$_createMessage);
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
    final result = SpeedTestRequest._();
    if (testDownload != null) result.testDownload = testDownload;
    if (testUpload != null) result.testUpload = testUpload;
    if (duration != null) result.duration = duration;
    return result;
  }

  SpeedTestRequest._();

  factory SpeedTestRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpeedTestRequest()..mergeFromBuffer(data, registry);
  factory SpeedTestRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpeedTestRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpeedTestRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: SpeedTestRequest.$_createMessage)
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
  @$core.Deprecated('Use SpeedTestRequest() / SpeedTestRequest.new instead')
  static SpeedTestRequest create() => SpeedTestRequest._();
  static $pb.GeneratedMessage $_createMessage() => SpeedTestRequest._();
  @$core.override
  SpeedTestRequest createEmptyInstance() => SpeedTestRequest._();
  @$core.pragma('dart2js:noInline')
  static SpeedTestRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpeedTestRequest>(
          SpeedTestRequest.$_createMessage);
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
    final result = SpeedTestResponse._();
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
      SpeedTestResponse()..mergeFromBuffer(data, registry);
  factory SpeedTestResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpeedTestResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpeedTestResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: SpeedTestResponse.$_createMessage)
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
  @$core.Deprecated('Use SpeedTestResponse() / SpeedTestResponse.new instead')
  static SpeedTestResponse create() => SpeedTestResponse._();
  static $pb.GeneratedMessage $_createMessage() => SpeedTestResponse._();
  @$core.override
  SpeedTestResponse createEmptyInstance() => SpeedTestResponse._();
  @$core.pragma('dart2js:noInline')
  static SpeedTestResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpeedTestResponse>(
          SpeedTestResponse.$_createMessage);
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
    final result = FileChunk._();
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
      FileChunk()..mergeFromBuffer(data, registry);
  factory FileChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileChunk()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FileChunk.$_createMessage)
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
  @$core.Deprecated('Use FileChunk() / FileChunk.new instead')
  static FileChunk create() => FileChunk._();
  static $pb.GeneratedMessage $_createMessage() => FileChunk._();
  @$core.override
  FileChunk createEmptyInstance() => FileChunk._();
  @$core.pragma('dart2js:noInline')
  static FileChunk getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileChunk>(FileChunk.$_createMessage);
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
    final result = FileUploadResponse._();
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
      FileUploadResponse()..mergeFromBuffer(data, registry);
  factory FileUploadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileUploadResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileUploadResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FileUploadResponse.$_createMessage)
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
  @$core.Deprecated('Use FileUploadResponse() / FileUploadResponse.new instead')
  static FileUploadResponse create() => FileUploadResponse._();
  static $pb.GeneratedMessage $_createMessage() => FileUploadResponse._();
  @$core.override
  FileUploadResponse createEmptyInstance() => FileUploadResponse._();
  @$core.pragma('dart2js:noInline')
  static FileUploadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileUploadResponse>(
          FileUploadResponse.$_createMessage);
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
    final result = FileDownloadRequest._();
    if (path != null) result.path = path;
    if (offset != null) result.offset = offset;
    return result;
  }

  FileDownloadRequest._();

  factory FileDownloadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileDownloadRequest()..mergeFromBuffer(data, registry);
  factory FileDownloadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileDownloadRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileDownloadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FileDownloadRequest.$_createMessage)
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
  @$core
      .Deprecated('Use FileDownloadRequest() / FileDownloadRequest.new instead')
  static FileDownloadRequest create() => FileDownloadRequest._();
  static $pb.GeneratedMessage $_createMessage() => FileDownloadRequest._();
  @$core.override
  FileDownloadRequest createEmptyInstance() => FileDownloadRequest._();
  @$core.pragma('dart2js:noInline')
  static FileDownloadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileDownloadRequest>(
          FileDownloadRequest.$_createMessage);
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
    final result = FileDeleteRequest._();
    if (path != null) result.path = path;
    if (isDirectory != null) result.isDirectory = isDirectory;
    return result;
  }

  FileDeleteRequest._();

  factory FileDeleteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileDeleteRequest()..mergeFromBuffer(data, registry);
  factory FileDeleteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileDeleteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileDeleteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FileDeleteRequest.$_createMessage)
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
  @$core.Deprecated('Use FileDeleteRequest() / FileDeleteRequest.new instead')
  static FileDeleteRequest create() => FileDeleteRequest._();
  static $pb.GeneratedMessage $_createMessage() => FileDeleteRequest._();
  @$core.override
  FileDeleteRequest createEmptyInstance() => FileDeleteRequest._();
  @$core.pragma('dart2js:noInline')
  static FileDeleteRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileDeleteRequest>(
          FileDeleteRequest.$_createMessage);
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
    final result = FileDeleteResponse._();
    if (success != null) result.success = success;
    if (path != null) result.path = path;
    if (error != null) result.error = error;
    return result;
  }

  FileDeleteResponse._();

  factory FileDeleteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileDeleteResponse()..mergeFromBuffer(data, registry);
  factory FileDeleteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileDeleteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileDeleteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FileDeleteResponse.$_createMessage)
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
  @$core.Deprecated('Use FileDeleteResponse() / FileDeleteResponse.new instead')
  static FileDeleteResponse create() => FileDeleteResponse._();
  static $pb.GeneratedMessage $_createMessage() => FileDeleteResponse._();
  @$core.override
  FileDeleteResponse createEmptyInstance() => FileDeleteResponse._();
  @$core.pragma('dart2js:noInline')
  static FileDeleteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileDeleteResponse>(
          FileDeleteResponse.$_createMessage);
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
    final result = DockerFilter._();
    if (all != null) result.all = all;
    return result;
  }

  DockerFilter._();

  factory DockerFilter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DockerFilter()..mergeFromBuffer(data, registry);
  factory DockerFilter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DockerFilter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DockerFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DockerFilter.$_createMessage)
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
  @$core.Deprecated('Use DockerFilter() / DockerFilter.new instead')
  static DockerFilter create() => DockerFilter._();
  static $pb.GeneratedMessage $_createMessage() => DockerFilter._();
  @$core.override
  DockerFilter createEmptyInstance() => DockerFilter._();
  @$core.pragma('dart2js:noInline')
  static DockerFilter getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DockerFilter>(
          DockerFilter.$_createMessage);
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
    final result = ContainerId._();
    if (id != null) result.id = id;
    return result;
  }

  ContainerId._();

  factory ContainerId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerId()..mergeFromBuffer(data, registry);
  factory ContainerId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerId()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerId.$_createMessage)
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
  @$core.Deprecated('Use ContainerId() / ContainerId.new instead')
  static ContainerId create() => ContainerId._();
  static $pb.GeneratedMessage $_createMessage() => ContainerId._();
  @$core.override
  ContainerId createEmptyInstance() => ContainerId._();
  @$core.pragma('dart2js:noInline')
  static ContainerId getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContainerId>(
          ContainerId.$_createMessage);
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
    final result = ContainerList._();
    if (containers != null) result.containers.addAll(containers);
    return result;
  }

  ContainerList._();

  factory ContainerList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerList()..mergeFromBuffer(data, registry);
  factory ContainerList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerList.$_createMessage)
    ..pPM<ContainerInfo>(1, _omitFieldNames ? '' : 'containers',
        subBuilder: ContainerInfo.$_createMessage)
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
  @$core.Deprecated('Use ContainerList() / ContainerList.new instead')
  static ContainerList create() => ContainerList._();
  static $pb.GeneratedMessage $_createMessage() => ContainerList._();
  @$core.override
  ContainerList createEmptyInstance() => ContainerList._();
  @$core.pragma('dart2js:noInline')
  static ContainerList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContainerList>(
          ContainerList.$_createMessage);
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
    $core.String? composeProject,
    $core.String? composeService,
  }) {
    final result = ContainerInfo._();
    if (id != null) result.id = id;
    if (names != null) result.names.addAll(names);
    if (image != null) result.image = image;
    if (state != null) result.state = state;
    if (status != null) result.status = status;
    if (created != null) result.created = created;
    if (ports != null) result.ports.addAll(ports);
    if (composeProject != null) result.composeProject = composeProject;
    if (composeService != null) result.composeService = composeService;
    return result;
  }

  ContainerInfo._();

  factory ContainerInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerInfo()..mergeFromBuffer(data, registry);
  factory ContainerInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..pPS(2, _omitFieldNames ? '' : 'names')
    ..aOS(3, _omitFieldNames ? '' : 'image')
    ..aOS(4, _omitFieldNames ? '' : 'state')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aInt64(6, _omitFieldNames ? '' : 'created')
    ..pPS(7, _omitFieldNames ? '' : 'ports')
    ..aOS(8, _omitFieldNames ? '' : 'composeProject')
    ..aOS(9, _omitFieldNames ? '' : 'composeService')
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
  @$core.Deprecated('Use ContainerInfo() / ContainerInfo.new instead')
  static ContainerInfo create() => ContainerInfo._();
  static $pb.GeneratedMessage $_createMessage() => ContainerInfo._();
  @$core.override
  ContainerInfo createEmptyInstance() => ContainerInfo._();
  @$core.pragma('dart2js:noInline')
  static ContainerInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContainerInfo>(
          ContainerInfo.$_createMessage);
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

  @$pb.TagNumber(8)
  $core.String get composeProject => $_getSZ(7);
  @$pb.TagNumber(8)
  set composeProject($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasComposeProject() => $_has(7);
  @$pb.TagNumber(8)
  void clearComposeProject() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get composeService => $_getSZ(8);
  @$pb.TagNumber(9)
  set composeService($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasComposeService() => $_has(8);
  @$pb.TagNumber(9)
  void clearComposeService() => $_clearField(9);
}

class DockerInfo extends $pb.GeneratedMessage {
  factory DockerInfo({
    $core.String? serverVersion,
    $core.int? containers,
    $core.int? running,
    $core.int? paused,
    $core.int? stopped,
    $core.int? images,
    $core.String? storageDriver,
    $core.String? operatingSystem,
    $core.String? architecture,
    $fixnum.Int64? memoryTotal,
    $core.int? cpus,
  }) {
    final result = DockerInfo._();
    if (serverVersion != null) result.serverVersion = serverVersion;
    if (containers != null) result.containers = containers;
    if (running != null) result.running = running;
    if (paused != null) result.paused = paused;
    if (stopped != null) result.stopped = stopped;
    if (images != null) result.images = images;
    if (storageDriver != null) result.storageDriver = storageDriver;
    if (operatingSystem != null) result.operatingSystem = operatingSystem;
    if (architecture != null) result.architecture = architecture;
    if (memoryTotal != null) result.memoryTotal = memoryTotal;
    if (cpus != null) result.cpus = cpus;
    return result;
  }

  DockerInfo._();

  factory DockerInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DockerInfo()..mergeFromBuffer(data, registry);
  factory DockerInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DockerInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DockerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DockerInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'serverVersion')
    ..aI(2, _omitFieldNames ? '' : 'containers')
    ..aI(3, _omitFieldNames ? '' : 'running')
    ..aI(4, _omitFieldNames ? '' : 'paused')
    ..aI(5, _omitFieldNames ? '' : 'stopped')
    ..aI(6, _omitFieldNames ? '' : 'images')
    ..aOS(7, _omitFieldNames ? '' : 'storageDriver')
    ..aOS(8, _omitFieldNames ? '' : 'operatingSystem')
    ..aOS(9, _omitFieldNames ? '' : 'architecture')
    ..a<$fixnum.Int64>(
        10, _omitFieldNames ? '' : 'memoryTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(11, _omitFieldNames ? '' : 'cpus')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DockerInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DockerInfo copyWith(void Function(DockerInfo) updates) =>
      super.copyWith((message) => updates(message as DockerInfo)) as DockerInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DockerInfo() / DockerInfo.new instead')
  static DockerInfo create() => DockerInfo._();
  static $pb.GeneratedMessage $_createMessage() => DockerInfo._();
  @$core.override
  DockerInfo createEmptyInstance() => DockerInfo._();
  @$core.pragma('dart2js:noInline')
  static DockerInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DockerInfo>(DockerInfo.$_createMessage);
  static DockerInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverVersion($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasServerVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get containers => $_getIZ(1);
  @$pb.TagNumber(2)
  set containers($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContainers() => $_has(1);
  @$pb.TagNumber(2)
  void clearContainers() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get running => $_getIZ(2);
  @$pb.TagNumber(3)
  set running($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRunning() => $_has(2);
  @$pb.TagNumber(3)
  void clearRunning() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get paused => $_getIZ(3);
  @$pb.TagNumber(4)
  set paused($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPaused() => $_has(3);
  @$pb.TagNumber(4)
  void clearPaused() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get stopped => $_getIZ(4);
  @$pb.TagNumber(5)
  set stopped($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStopped() => $_has(4);
  @$pb.TagNumber(5)
  void clearStopped() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get images => $_getIZ(5);
  @$pb.TagNumber(6)
  set images($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasImages() => $_has(5);
  @$pb.TagNumber(6)
  void clearImages() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get storageDriver => $_getSZ(6);
  @$pb.TagNumber(7)
  set storageDriver($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStorageDriver() => $_has(6);
  @$pb.TagNumber(7)
  void clearStorageDriver() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get operatingSystem => $_getSZ(7);
  @$pb.TagNumber(8)
  set operatingSystem($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOperatingSystem() => $_has(7);
  @$pb.TagNumber(8)
  void clearOperatingSystem() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get architecture => $_getSZ(8);
  @$pb.TagNumber(9)
  set architecture($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasArchitecture() => $_has(8);
  @$pb.TagNumber(9)
  void clearArchitecture() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get memoryTotal => $_getI64(9);
  @$pb.TagNumber(10)
  set memoryTotal($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMemoryTotal() => $_has(9);
  @$pb.TagNumber(10)
  void clearMemoryTotal() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get cpus => $_getIZ(10);
  @$pb.TagNumber(11)
  set cpus($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCpus() => $_has(10);
  @$pb.TagNumber(11)
  void clearCpus() => $_clearField(11);
}

class ContainerActionRequest extends $pb.GeneratedMessage {
  factory ContainerActionRequest({
    $core.String? id,
    ContainerOp? op,
    $core.bool? force,
    $core.bool? removeVolumes,
  }) {
    final result = ContainerActionRequest._();
    if (id != null) result.id = id;
    if (op != null) result.op = op;
    if (force != null) result.force = force;
    if (removeVolumes != null) result.removeVolumes = removeVolumes;
    return result;
  }

  ContainerActionRequest._();

  factory ContainerActionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerActionRequest()..mergeFromBuffer(data, registry);
  factory ContainerActionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerActionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerActionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerActionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<ContainerOp>(2, _omitFieldNames ? '' : 'op',
        enumValues: ContainerOp.values)
    ..aOB(3, _omitFieldNames ? '' : 'force')
    ..aOB(4, _omitFieldNames ? '' : 'removeVolumes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerActionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerActionRequest copyWith(
          void Function(ContainerActionRequest) updates) =>
      super.copyWith((message) => updates(message as ContainerActionRequest))
          as ContainerActionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ContainerActionRequest() / ContainerActionRequest.new instead')
  static ContainerActionRequest create() => ContainerActionRequest._();
  static $pb.GeneratedMessage $_createMessage() => ContainerActionRequest._();
  @$core.override
  ContainerActionRequest createEmptyInstance() => ContainerActionRequest._();
  @$core.pragma('dart2js:noInline')
  static ContainerActionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ContainerActionRequest>(
          ContainerActionRequest.$_createMessage);
  static ContainerActionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  ContainerOp get op => $_getN(1);
  @$pb.TagNumber(2)
  set op(ContainerOp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOp() => $_has(1);
  @$pb.TagNumber(2)
  void clearOp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get force => $_getBF(2);
  @$pb.TagNumber(3)
  set force($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasForce() => $_has(2);
  @$pb.TagNumber(3)
  void clearForce() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get removeVolumes => $_getBF(3);
  @$pb.TagNumber(4)
  set removeVolumes($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRemoveVolumes() => $_has(3);
  @$pb.TagNumber(4)
  void clearRemoveVolumes() => $_clearField(4);
}

class ContainerMount extends $pb.GeneratedMessage {
  factory ContainerMount({
    $core.String? type,
    $core.String? source,
    $core.String? destination,
    $core.bool? readWrite,
    $core.String? name,
  }) {
    final result = ContainerMount._();
    if (type != null) result.type = type;
    if (source != null) result.source = source;
    if (destination != null) result.destination = destination;
    if (readWrite != null) result.readWrite = readWrite;
    if (name != null) result.name = name;
    return result;
  }

  ContainerMount._();

  factory ContainerMount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerMount()..mergeFromBuffer(data, registry);
  factory ContainerMount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerMount()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerMount',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerMount.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'source')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..aOB(4, _omitFieldNames ? '' : 'readWrite')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerMount clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerMount copyWith(void Function(ContainerMount) updates) =>
      super.copyWith((message) => updates(message as ContainerMount))
          as ContainerMount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ContainerMount() / ContainerMount.new instead')
  static ContainerMount create() => ContainerMount._();
  static $pb.GeneratedMessage $_createMessage() => ContainerMount._();
  @$core.override
  ContainerMount createEmptyInstance() => ContainerMount._();
  @$core.pragma('dart2js:noInline')
  static ContainerMount getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContainerMount>(
          ContainerMount.$_createMessage);
  static ContainerMount? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get source => $_getSZ(1);
  @$pb.TagNumber(2)
  set source($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSource() => $_has(1);
  @$pb.TagNumber(2)
  void clearSource() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get readWrite => $_getBF(3);
  @$pb.TagNumber(4)
  set readWrite($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReadWrite() => $_has(3);
  @$pb.TagNumber(4)
  void clearReadWrite() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);
}

class ContainerDetails extends $pb.GeneratedMessage {
  factory ContainerDetails({
    ContainerInfo? info,
    $core.String? command,
    $core.String? restartPolicy,
    $core.String? health,
    $core.int? exitCode,
    $fixnum.Int64? startedAt,
    $fixnum.Int64? finishedAt,
    $core.Iterable<$core.String>? networks,
    $core.Iterable<$core.String>? ipAddresses,
    $core.Iterable<ContainerMount>? mounts,
    $core.Iterable<$core.String>? env,
    $core.String? hostname,
    $core.int? restartCount,
    $core.bool? tty,
  }) {
    final result = ContainerDetails._();
    if (info != null) result.info = info;
    if (command != null) result.command = command;
    if (restartPolicy != null) result.restartPolicy = restartPolicy;
    if (health != null) result.health = health;
    if (exitCode != null) result.exitCode = exitCode;
    if (startedAt != null) result.startedAt = startedAt;
    if (finishedAt != null) result.finishedAt = finishedAt;
    if (networks != null) result.networks.addAll(networks);
    if (ipAddresses != null) result.ipAddresses.addAll(ipAddresses);
    if (mounts != null) result.mounts.addAll(mounts);
    if (env != null) result.env.addAll(env);
    if (hostname != null) result.hostname = hostname;
    if (restartCount != null) result.restartCount = restartCount;
    if (tty != null) result.tty = tty;
    return result;
  }

  ContainerDetails._();

  factory ContainerDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerDetails()..mergeFromBuffer(data, registry);
  factory ContainerDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerDetails()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerDetails.$_createMessage)
    ..aOM<ContainerInfo>(1, _omitFieldNames ? '' : 'info',
        subBuilder: ContainerInfo.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'command')
    ..aOS(3, _omitFieldNames ? '' : 'restartPolicy')
    ..aOS(4, _omitFieldNames ? '' : 'health')
    ..aI(5, _omitFieldNames ? '' : 'exitCode')
    ..aInt64(6, _omitFieldNames ? '' : 'startedAt')
    ..aInt64(7, _omitFieldNames ? '' : 'finishedAt')
    ..pPS(8, _omitFieldNames ? '' : 'networks')
    ..pPS(9, _omitFieldNames ? '' : 'ipAddresses')
    ..pPM<ContainerMount>(10, _omitFieldNames ? '' : 'mounts',
        subBuilder: ContainerMount.$_createMessage)
    ..pPS(11, _omitFieldNames ? '' : 'env')
    ..aOS(12, _omitFieldNames ? '' : 'hostname')
    ..aI(13, _omitFieldNames ? '' : 'restartCount')
    ..aOB(14, _omitFieldNames ? '' : 'tty')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerDetails copyWith(void Function(ContainerDetails) updates) =>
      super.copyWith((message) => updates(message as ContainerDetails))
          as ContainerDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ContainerDetails() / ContainerDetails.new instead')
  static ContainerDetails create() => ContainerDetails._();
  static $pb.GeneratedMessage $_createMessage() => ContainerDetails._();
  @$core.override
  ContainerDetails createEmptyInstance() => ContainerDetails._();
  @$core.pragma('dart2js:noInline')
  static ContainerDetails getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContainerDetails>(
          ContainerDetails.$_createMessage);
  static ContainerDetails? _defaultInstance;

  @$pb.TagNumber(1)
  ContainerInfo get info => $_getN(0);
  @$pb.TagNumber(1)
  set info(ContainerInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  ContainerInfo ensureInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get command => $_getSZ(1);
  @$pb.TagNumber(2)
  set command($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommand() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommand() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get restartPolicy => $_getSZ(2);
  @$pb.TagNumber(3)
  set restartPolicy($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRestartPolicy() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestartPolicy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get health => $_getSZ(3);
  @$pb.TagNumber(4)
  set health($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHealth() => $_has(3);
  @$pb.TagNumber(4)
  void clearHealth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get exitCode => $_getIZ(4);
  @$pb.TagNumber(5)
  set exitCode($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExitCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearExitCode() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get startedAt => $_getI64(5);
  @$pb.TagNumber(6)
  set startedAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStartedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearStartedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get finishedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set finishedAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFinishedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearFinishedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get networks => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get ipAddresses => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<ContainerMount> get mounts => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get env => $_getList(10);

  @$pb.TagNumber(12)
  $core.String get hostname => $_getSZ(11);
  @$pb.TagNumber(12)
  set hostname($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHostname() => $_has(11);
  @$pb.TagNumber(12)
  void clearHostname() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get restartCount => $_getIZ(12);
  @$pb.TagNumber(13)
  set restartCount($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRestartCount() => $_has(12);
  @$pb.TagNumber(13)
  void clearRestartCount() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get tty => $_getBF(13);
  @$pb.TagNumber(14)
  set tty($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasTty() => $_has(13);
  @$pb.TagNumber(14)
  void clearTty() => $_clearField(14);
}

class ContainerStats extends $pb.GeneratedMessage {
  factory ContainerStats({
    $core.double? cpuPercent,
    $fixnum.Int64? memoryUsage,
    $fixnum.Int64? memoryLimit,
    $fixnum.Int64? netRx,
    $fixnum.Int64? netTx,
    $fixnum.Int64? blockRead,
    $fixnum.Int64? blockWrite,
    $fixnum.Int64? pids,
  }) {
    final result = ContainerStats._();
    if (cpuPercent != null) result.cpuPercent = cpuPercent;
    if (memoryUsage != null) result.memoryUsage = memoryUsage;
    if (memoryLimit != null) result.memoryLimit = memoryLimit;
    if (netRx != null) result.netRx = netRx;
    if (netTx != null) result.netTx = netTx;
    if (blockRead != null) result.blockRead = blockRead;
    if (blockWrite != null) result.blockWrite = blockWrite;
    if (pids != null) result.pids = pids;
    return result;
  }

  ContainerStats._();

  factory ContainerStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerStats()..mergeFromBuffer(data, registry);
  factory ContainerStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ContainerStats()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ContainerStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ContainerStats.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'cpuPercent')
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'memoryUsage', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'memoryLimit', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'netRx', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'netTx', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'blockRead', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'blockWrite', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(8, _omitFieldNames ? '' : 'pids', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ContainerStats copyWith(void Function(ContainerStats) updates) =>
      super.copyWith((message) => updates(message as ContainerStats))
          as ContainerStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ContainerStats() / ContainerStats.new instead')
  static ContainerStats create() => ContainerStats._();
  static $pb.GeneratedMessage $_createMessage() => ContainerStats._();
  @$core.override
  ContainerStats createEmptyInstance() => ContainerStats._();
  @$core.pragma('dart2js:noInline')
  static ContainerStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContainerStats>(
          ContainerStats.$_createMessage);
  static ContainerStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get cpuPercent => $_getN(0);
  @$pb.TagNumber(1)
  set cpuPercent($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCpuPercent() => $_has(0);
  @$pb.TagNumber(1)
  void clearCpuPercent() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get memoryUsage => $_getI64(1);
  @$pb.TagNumber(2)
  set memoryUsage($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMemoryUsage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMemoryUsage() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get memoryLimit => $_getI64(2);
  @$pb.TagNumber(3)
  set memoryLimit($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMemoryLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearMemoryLimit() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get netRx => $_getI64(3);
  @$pb.TagNumber(4)
  set netRx($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNetRx() => $_has(3);
  @$pb.TagNumber(4)
  void clearNetRx() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get netTx => $_getI64(4);
  @$pb.TagNumber(5)
  set netTx($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNetTx() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetTx() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get blockRead => $_getI64(5);
  @$pb.TagNumber(6)
  set blockRead($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockRead() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockRead() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get blockWrite => $_getI64(6);
  @$pb.TagNumber(7)
  set blockWrite($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockWrite() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockWrite() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get pids => $_getI64(7);
  @$pb.TagNumber(8)
  set pids($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPids() => $_has(7);
  @$pb.TagNumber(8)
  void clearPids() => $_clearField(8);
}

class DockerImage extends $pb.GeneratedMessage {
  factory DockerImage({
    $core.String? id,
    $core.Iterable<$core.String>? tags,
    $fixnum.Int64? size,
    $fixnum.Int64? created,
    $core.int? containers,
  }) {
    final result = DockerImage._();
    if (id != null) result.id = id;
    if (tags != null) result.tags.addAll(tags);
    if (size != null) result.size = size;
    if (created != null) result.created = created;
    if (containers != null) result.containers = containers;
    return result;
  }

  DockerImage._();

  factory DockerImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DockerImage()..mergeFromBuffer(data, registry);
  factory DockerImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DockerImage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DockerImage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: DockerImage.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..pPS(2, _omitFieldNames ? '' : 'tags')
    ..aInt64(3, _omitFieldNames ? '' : 'size')
    ..aInt64(4, _omitFieldNames ? '' : 'created')
    ..aI(5, _omitFieldNames ? '' : 'containers')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DockerImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DockerImage copyWith(void Function(DockerImage) updates) =>
      super.copyWith((message) => updates(message as DockerImage))
          as DockerImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DockerImage() / DockerImage.new instead')
  static DockerImage create() => DockerImage._();
  static $pb.GeneratedMessage $_createMessage() => DockerImage._();
  @$core.override
  DockerImage createEmptyInstance() => DockerImage._();
  @$core.pragma('dart2js:noInline')
  static DockerImage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DockerImage>(
          DockerImage.$_createMessage);
  static DockerImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get tags => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get size => $_getI64(2);
  @$pb.TagNumber(3)
  set size($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get created => $_getI64(3);
  @$pb.TagNumber(4)
  set created($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreated() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreated() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get containers => $_getIZ(4);
  @$pb.TagNumber(5)
  set containers($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContainers() => $_has(4);
  @$pb.TagNumber(5)
  void clearContainers() => $_clearField(5);
}

class ImageList extends $pb.GeneratedMessage {
  factory ImageList({
    $core.Iterable<DockerImage>? images,
  }) {
    final result = ImageList._();
    if (images != null) result.images.addAll(images);
    return result;
  }

  ImageList._();

  factory ImageList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageList()..mergeFromBuffer(data, registry);
  factory ImageList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ImageList.$_createMessage)
    ..pPM<DockerImage>(1, _omitFieldNames ? '' : 'images',
        subBuilder: DockerImage.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageList copyWith(void Function(ImageList) updates) =>
      super.copyWith((message) => updates(message as ImageList)) as ImageList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImageList() / ImageList.new instead')
  static ImageList create() => ImageList._();
  static $pb.GeneratedMessage $_createMessage() => ImageList._();
  @$core.override
  ImageList createEmptyInstance() => ImageList._();
  @$core.pragma('dart2js:noInline')
  static ImageList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageList>(ImageList.$_createMessage);
  static ImageList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DockerImage> get images => $_getList(0);
}

class ImageRemoveRequest extends $pb.GeneratedMessage {
  factory ImageRemoveRequest({
    $core.String? id,
    $core.bool? force,
  }) {
    final result = ImageRemoveRequest._();
    if (id != null) result.id = id;
    if (force != null) result.force = force;
    return result;
  }

  ImageRemoveRequest._();

  factory ImageRemoveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageRemoveRequest()..mergeFromBuffer(data, registry);
  factory ImageRemoveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImageRemoveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageRemoveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: ImageRemoveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'force')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageRemoveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageRemoveRequest copyWith(void Function(ImageRemoveRequest) updates) =>
      super.copyWith((message) => updates(message as ImageRemoveRequest))
          as ImageRemoveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImageRemoveRequest() / ImageRemoveRequest.new instead')
  static ImageRemoveRequest create() => ImageRemoveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImageRemoveRequest._();
  @$core.override
  ImageRemoveRequest createEmptyInstance() => ImageRemoveRequest._();
  @$core.pragma('dart2js:noInline')
  static ImageRemoveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageRemoveRequest>(
          ImageRemoveRequest.$_createMessage);
  static ImageRemoveRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get force => $_getBF(1);
  @$pb.TagNumber(2)
  set force($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasForce() => $_has(1);
  @$pb.TagNumber(2)
  void clearForce() => $_clearField(2);
}

class PruneRequest extends $pb.GeneratedMessage {
  factory PruneRequest({
    PruneTarget? target,
  }) {
    final result = PruneRequest._();
    if (target != null) result.target = target;
    return result;
  }

  PruneRequest._();

  factory PruneRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PruneRequest()..mergeFromBuffer(data, registry);
  factory PruneRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PruneRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PruneRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PruneRequest.$_createMessage)
    ..aE<PruneTarget>(1, _omitFieldNames ? '' : 'target',
        enumValues: PruneTarget.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PruneRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PruneRequest copyWith(void Function(PruneRequest) updates) =>
      super.copyWith((message) => updates(message as PruneRequest))
          as PruneRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PruneRequest() / PruneRequest.new instead')
  static PruneRequest create() => PruneRequest._();
  static $pb.GeneratedMessage $_createMessage() => PruneRequest._();
  @$core.override
  PruneRequest createEmptyInstance() => PruneRequest._();
  @$core.pragma('dart2js:noInline')
  static PruneRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PruneRequest>(
          PruneRequest.$_createMessage);
  static PruneRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PruneTarget get target => $_getN(0);
  @$pb.TagNumber(1)
  set target(PruneTarget value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);
}

class PruneResult extends $pb.GeneratedMessage {
  factory PruneResult({
    $core.bool? success,
    $core.String? message,
    $fixnum.Int64? spaceReclaimed,
    $core.int? deleted,
  }) {
    final result = PruneResult._();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    if (spaceReclaimed != null) result.spaceReclaimed = spaceReclaimed;
    if (deleted != null) result.deleted = deleted;
    return result;
  }

  PruneResult._();

  factory PruneResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PruneResult()..mergeFromBuffer(data, registry);
  factory PruneResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PruneResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PruneResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PruneResult.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'spaceReclaimed', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(4, _omitFieldNames ? '' : 'deleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PruneResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PruneResult copyWith(void Function(PruneResult) updates) =>
      super.copyWith((message) => updates(message as PruneResult))
          as PruneResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PruneResult() / PruneResult.new instead')
  static PruneResult create() => PruneResult._();
  static $pb.GeneratedMessage $_createMessage() => PruneResult._();
  @$core.override
  PruneResult createEmptyInstance() => PruneResult._();
  @$core.pragma('dart2js:noInline')
  static PruneResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PruneResult>(
          PruneResult.$_createMessage);
  static PruneResult? _defaultInstance;

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
  $fixnum.Int64 get spaceReclaimed => $_getI64(2);
  @$pb.TagNumber(3)
  set spaceReclaimed($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceReclaimed() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpaceReclaimed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get deleted => $_getIZ(3);
  @$pb.TagNumber(4)
  set deleted($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeleted() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeleted() => $_clearField(4);
}

class LogRequest extends $pb.GeneratedMessage {
  factory LogRequest({
    $core.String? containerId,
    $core.bool? follow,
    $core.int? tail,
  }) {
    final result = LogRequest._();
    if (containerId != null) result.containerId = containerId;
    if (follow != null) result.follow = follow;
    if (tail != null) result.tail = tail;
    return result;
  }

  LogRequest._();

  factory LogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogRequest()..mergeFromBuffer(data, registry);
  factory LogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LogRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: LogRequest.$_createMessage)
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
  @$core.Deprecated('Use LogRequest() / LogRequest.new instead')
  static LogRequest create() => LogRequest._();
  static $pb.GeneratedMessage $_createMessage() => LogRequest._();
  @$core.override
  LogRequest createEmptyInstance() => LogRequest._();
  @$core.pragma('dart2js:noInline')
  static LogRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogRequest>(LogRequest.$_createMessage);
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
    $core.bool? rebootRequired,
    $core.Iterable<$core.String>? rebootPackages,
    $fixnum.Int64? lastUpdateUnix,
  }) {
    final result = SystemUpdateStatus._();
    if (osName != null) result.osName = osName;
    if (kernelVersion != null) result.kernelVersion = kernelVersion;
    if (architecture != null) result.architecture = architecture;
    if (upgradableCount != null) result.upgradableCount = upgradableCount;
    if (upgradablePackages != null)
      result.upgradablePackages.addAll(upgradablePackages);
    if (lastUpdate != null) result.lastUpdate = lastUpdate;
    if (uptime != null) result.uptime = uptime;
    if (rebootRequired != null) result.rebootRequired = rebootRequired;
    if (rebootPackages != null) result.rebootPackages.addAll(rebootPackages);
    if (lastUpdateUnix != null) result.lastUpdateUnix = lastUpdateUnix;
    return result;
  }

  SystemUpdateStatus._();

  factory SystemUpdateStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemUpdateStatus()..mergeFromBuffer(data, registry);
  factory SystemUpdateStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemUpdateStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemUpdateStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: SystemUpdateStatus.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'osName')
    ..aOS(2, _omitFieldNames ? '' : 'kernelVersion')
    ..aOS(3, _omitFieldNames ? '' : 'architecture')
    ..aI(4, _omitFieldNames ? '' : 'upgradableCount')
    ..pPM<UpgradablePackage>(5, _omitFieldNames ? '' : 'upgradablePackages',
        subBuilder: UpgradablePackage.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'lastUpdate')
    ..aOS(7, _omitFieldNames ? '' : 'uptime')
    ..aOB(8, _omitFieldNames ? '' : 'rebootRequired')
    ..pPS(9, _omitFieldNames ? '' : 'rebootPackages')
    ..aInt64(10, _omitFieldNames ? '' : 'lastUpdateUnix')
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
  @$core.Deprecated('Use SystemUpdateStatus() / SystemUpdateStatus.new instead')
  static SystemUpdateStatus create() => SystemUpdateStatus._();
  static $pb.GeneratedMessage $_createMessage() => SystemUpdateStatus._();
  @$core.override
  SystemUpdateStatus createEmptyInstance() => SystemUpdateStatus._();
  @$core.pragma('dart2js:noInline')
  static SystemUpdateStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemUpdateStatus>(
          SystemUpdateStatus.$_createMessage);
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

  @$pb.TagNumber(8)
  $core.bool get rebootRequired => $_getBF(7);
  @$pb.TagNumber(8)
  set rebootRequired($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRebootRequired() => $_has(7);
  @$pb.TagNumber(8)
  void clearRebootRequired() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get rebootPackages => $_getList(8);

  @$pb.TagNumber(10)
  $fixnum.Int64 get lastUpdateUnix => $_getI64(9);
  @$pb.TagNumber(10)
  set lastUpdateUnix($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLastUpdateUnix() => $_has(9);
  @$pb.TagNumber(10)
  void clearLastUpdateUnix() => $_clearField(10);
}

class UpgradablePackage extends $pb.GeneratedMessage {
  factory UpgradablePackage({
    $core.String? name,
    $core.String? currentVersion,
    $core.String? newVersion,
    $core.String? architecture,
    $core.bool? security,
    $core.String? source,
  }) {
    final result = UpgradablePackage._();
    if (name != null) result.name = name;
    if (currentVersion != null) result.currentVersion = currentVersion;
    if (newVersion != null) result.newVersion = newVersion;
    if (architecture != null) result.architecture = architecture;
    if (security != null) result.security = security;
    if (source != null) result.source = source;
    return result;
  }

  UpgradablePackage._();

  factory UpgradablePackage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpgradablePackage()..mergeFromBuffer(data, registry);
  factory UpgradablePackage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpgradablePackage()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpgradablePackage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: UpgradablePackage.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'currentVersion')
    ..aOS(3, _omitFieldNames ? '' : 'newVersion')
    ..aOS(4, _omitFieldNames ? '' : 'architecture')
    ..aOB(5, _omitFieldNames ? '' : 'security')
    ..aOS(6, _omitFieldNames ? '' : 'source')
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
  @$core.Deprecated('Use UpgradablePackage() / UpgradablePackage.new instead')
  static UpgradablePackage create() => UpgradablePackage._();
  static $pb.GeneratedMessage $_createMessage() => UpgradablePackage._();
  @$core.override
  UpgradablePackage createEmptyInstance() => UpgradablePackage._();
  @$core.pragma('dart2js:noInline')
  static UpgradablePackage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpgradablePackage>(
          UpgradablePackage.$_createMessage);
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

  @$pb.TagNumber(5)
  $core.bool get security => $_getBF(4);
  @$pb.TagNumber(5)
  set security($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSecurity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSecurity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get source => $_getSZ(5);
  @$pb.TagNumber(6)
  set source($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSource() => $_has(5);
  @$pb.TagNumber(6)
  void clearSource() => $_clearField(6);
}

class UpgradeProgress extends $pb.GeneratedMessage {
  factory UpgradeProgress({
    $core.String? line,
    $core.String? phase,
    $core.int? percent,
    $core.bool? isComplete,
    $core.bool? success,
  }) {
    final result = UpgradeProgress._();
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
      UpgradeProgress()..mergeFromBuffer(data, registry);
  factory UpgradeProgress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpgradeProgress()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpgradeProgress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: UpgradeProgress.$_createMessage)
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
  @$core.Deprecated('Use UpgradeProgress() / UpgradeProgress.new instead')
  static UpgradeProgress create() => UpgradeProgress._();
  static $pb.GeneratedMessage $_createMessage() => UpgradeProgress._();
  @$core.override
  UpgradeProgress createEmptyInstance() => UpgradeProgress._();
  @$core.pragma('dart2js:noInline')
  static UpgradeProgress getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpgradeProgress>(
          UpgradeProgress.$_createMessage);
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

class Pm2Info extends $pb.GeneratedMessage {
  factory Pm2Info({
    $core.bool? installed,
    $core.String? version,
    $core.String? pm2Path,
    $core.String? nodeVersion,
    $core.String? user,
    $core.String? home,
    $core.String? pm2Home,
    $core.bool? daemonRunning,
    $core.int? daemonPid,
    $core.bool? startupEnabled,
    $core.String? startupService,
    $core.bool? dumpExists,
    $core.int? dumpProcessCount,
    $core.String? moduleConfigJson,
    $core.bool? npmAvailable,
    $core.bool? agentIsRoot,
    $core.String? error,
  }) {
    final result = Pm2Info._();
    if (installed != null) result.installed = installed;
    if (version != null) result.version = version;
    if (pm2Path != null) result.pm2Path = pm2Path;
    if (nodeVersion != null) result.nodeVersion = nodeVersion;
    if (user != null) result.user = user;
    if (home != null) result.home = home;
    if (pm2Home != null) result.pm2Home = pm2Home;
    if (daemonRunning != null) result.daemonRunning = daemonRunning;
    if (daemonPid != null) result.daemonPid = daemonPid;
    if (startupEnabled != null) result.startupEnabled = startupEnabled;
    if (startupService != null) result.startupService = startupService;
    if (dumpExists != null) result.dumpExists = dumpExists;
    if (dumpProcessCount != null) result.dumpProcessCount = dumpProcessCount;
    if (moduleConfigJson != null) result.moduleConfigJson = moduleConfigJson;
    if (npmAvailable != null) result.npmAvailable = npmAvailable;
    if (agentIsRoot != null) result.agentIsRoot = agentIsRoot;
    if (error != null) result.error = error;
    return result;
  }

  Pm2Info._();

  factory Pm2Info.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Info()..mergeFromBuffer(data, registry);
  factory Pm2Info.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Info()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2Info',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2Info.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'installed')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'pm2Path')
    ..aOS(4, _omitFieldNames ? '' : 'nodeVersion')
    ..aOS(5, _omitFieldNames ? '' : 'user')
    ..aOS(6, _omitFieldNames ? '' : 'home')
    ..aOS(7, _omitFieldNames ? '' : 'pm2Home')
    ..aOB(8, _omitFieldNames ? '' : 'daemonRunning')
    ..aI(9, _omitFieldNames ? '' : 'daemonPid')
    ..aOB(10, _omitFieldNames ? '' : 'startupEnabled')
    ..aOS(11, _omitFieldNames ? '' : 'startupService')
    ..aOB(12, _omitFieldNames ? '' : 'dumpExists')
    ..aI(13, _omitFieldNames ? '' : 'dumpProcessCount')
    ..aOS(14, _omitFieldNames ? '' : 'moduleConfigJson')
    ..aOB(15, _omitFieldNames ? '' : 'npmAvailable')
    ..aOB(16, _omitFieldNames ? '' : 'agentIsRoot')
    ..aOS(17, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Info clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Info copyWith(void Function(Pm2Info) updates) =>
      super.copyWith((message) => updates(message as Pm2Info)) as Pm2Info;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2Info() / Pm2Info.new instead')
  static Pm2Info create() => Pm2Info._();
  static $pb.GeneratedMessage $_createMessage() => Pm2Info._();
  @$core.override
  Pm2Info createEmptyInstance() => Pm2Info._();
  @$core.pragma('dart2js:noInline')
  static Pm2Info getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pm2Info>(Pm2Info.$_createMessage);
  static Pm2Info? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get installed => $_getBF(0);
  @$pb.TagNumber(1)
  set installed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInstalled() => $_has(0);
  @$pb.TagNumber(1)
  void clearInstalled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pm2Path => $_getSZ(2);
  @$pb.TagNumber(3)
  set pm2Path($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPm2Path() => $_has(2);
  @$pb.TagNumber(3)
  void clearPm2Path() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nodeVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set nodeVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNodeVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearNodeVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get user => $_getSZ(4);
  @$pb.TagNumber(5)
  set user($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUser() => $_has(4);
  @$pb.TagNumber(5)
  void clearUser() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get home => $_getSZ(5);
  @$pb.TagNumber(6)
  set home($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHome() => $_has(5);
  @$pb.TagNumber(6)
  void clearHome() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pm2Home => $_getSZ(6);
  @$pb.TagNumber(7)
  set pm2Home($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPm2Home() => $_has(6);
  @$pb.TagNumber(7)
  void clearPm2Home() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get daemonRunning => $_getBF(7);
  @$pb.TagNumber(8)
  set daemonRunning($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDaemonRunning() => $_has(7);
  @$pb.TagNumber(8)
  void clearDaemonRunning() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get daemonPid => $_getIZ(8);
  @$pb.TagNumber(9)
  set daemonPid($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDaemonPid() => $_has(8);
  @$pb.TagNumber(9)
  void clearDaemonPid() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get startupEnabled => $_getBF(9);
  @$pb.TagNumber(10)
  set startupEnabled($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStartupEnabled() => $_has(9);
  @$pb.TagNumber(10)
  void clearStartupEnabled() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get startupService => $_getSZ(10);
  @$pb.TagNumber(11)
  set startupService($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStartupService() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartupService() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get dumpExists => $_getBF(11);
  @$pb.TagNumber(12)
  set dumpExists($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasDumpExists() => $_has(11);
  @$pb.TagNumber(12)
  void clearDumpExists() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get dumpProcessCount => $_getIZ(12);
  @$pb.TagNumber(13)
  set dumpProcessCount($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDumpProcessCount() => $_has(12);
  @$pb.TagNumber(13)
  void clearDumpProcessCount() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get moduleConfigJson => $_getSZ(13);
  @$pb.TagNumber(14)
  set moduleConfigJson($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasModuleConfigJson() => $_has(13);
  @$pb.TagNumber(14)
  void clearModuleConfigJson() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get npmAvailable => $_getBF(14);
  @$pb.TagNumber(15)
  set npmAvailable($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNpmAvailable() => $_has(14);
  @$pb.TagNumber(15)
  void clearNpmAvailable() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get agentIsRoot => $_getBF(15);
  @$pb.TagNumber(16)
  set agentIsRoot($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasAgentIsRoot() => $_has(15);
  @$pb.TagNumber(16)
  void clearAgentIsRoot() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get error => $_getSZ(16);
  @$pb.TagNumber(17)
  set error($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasError() => $_has(16);
  @$pb.TagNumber(17)
  void clearError() => $_clearField(17);
}

class Pm2ProcessList extends $pb.GeneratedMessage {
  factory Pm2ProcessList({
    $core.Iterable<Pm2Process>? processes,
  }) {
    final result = Pm2ProcessList._();
    if (processes != null) result.processes.addAll(processes);
    return result;
  }

  Pm2ProcessList._();

  factory Pm2ProcessList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2ProcessList()..mergeFromBuffer(data, registry);
  factory Pm2ProcessList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2ProcessList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2ProcessList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2ProcessList.$_createMessage)
    ..pPM<Pm2Process>(1, _omitFieldNames ? '' : 'processes',
        subBuilder: Pm2Process.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2ProcessList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2ProcessList copyWith(void Function(Pm2ProcessList) updates) =>
      super.copyWith((message) => updates(message as Pm2ProcessList))
          as Pm2ProcessList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2ProcessList() / Pm2ProcessList.new instead')
  static Pm2ProcessList create() => Pm2ProcessList._();
  static $pb.GeneratedMessage $_createMessage() => Pm2ProcessList._();
  @$core.override
  Pm2ProcessList createEmptyInstance() => Pm2ProcessList._();
  @$core.pragma('dart2js:noInline')
  static Pm2ProcessList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2ProcessList>(
          Pm2ProcessList.$_createMessage);
  static Pm2ProcessList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Pm2Process> get processes => $_getList(0);
}

class Pm2Process extends $pb.GeneratedMessage {
  factory Pm2Process({
    $core.int? pmId,
    $core.String? name,
    $core.String? namespace,
    $core.int? pid,
    $core.String? status,
    $core.double? cpu,
    $fixnum.Int64? memory,
    $fixnum.Int64? startedAt,
    $fixnum.Int64? createdAt,
    $core.int? restarts,
    $core.int? unstableRestarts,
    $core.String? execMode,
    $core.int? instances,
    $core.bool? watch,
    $core.bool? autorestart,
    $core.String? version,
    $core.String? script,
    $core.String? cwd,
    $core.String? interpreter,
    $core.String? nodeVersion,
    $core.bool? isModule,
    $core.String? user,
    $core.String? outLog,
    $core.String? errLog,
    $fixnum.Int64? maxMemoryRestart,
    $core.String? cronRestart,
    $core.Iterable<$core.String>? args,
    $core.Iterable<$core.String>? customActions,
    $core.Iterable<Pm2Metric>? metrics,
    Pm2Versioning? versioning,
    $core.int? exitCode,
    $core.String? interpreterArgs,
  }) {
    final result = Pm2Process._();
    if (pmId != null) result.pmId = pmId;
    if (name != null) result.name = name;
    if (namespace != null) result.namespace = namespace;
    if (pid != null) result.pid = pid;
    if (status != null) result.status = status;
    if (cpu != null) result.cpu = cpu;
    if (memory != null) result.memory = memory;
    if (startedAt != null) result.startedAt = startedAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (restarts != null) result.restarts = restarts;
    if (unstableRestarts != null) result.unstableRestarts = unstableRestarts;
    if (execMode != null) result.execMode = execMode;
    if (instances != null) result.instances = instances;
    if (watch != null) result.watch = watch;
    if (autorestart != null) result.autorestart = autorestart;
    if (version != null) result.version = version;
    if (script != null) result.script = script;
    if (cwd != null) result.cwd = cwd;
    if (interpreter != null) result.interpreter = interpreter;
    if (nodeVersion != null) result.nodeVersion = nodeVersion;
    if (isModule != null) result.isModule = isModule;
    if (user != null) result.user = user;
    if (outLog != null) result.outLog = outLog;
    if (errLog != null) result.errLog = errLog;
    if (maxMemoryRestart != null) result.maxMemoryRestart = maxMemoryRestart;
    if (cronRestart != null) result.cronRestart = cronRestart;
    if (args != null) result.args.addAll(args);
    if (customActions != null) result.customActions.addAll(customActions);
    if (metrics != null) result.metrics.addAll(metrics);
    if (versioning != null) result.versioning = versioning;
    if (exitCode != null) result.exitCode = exitCode;
    if (interpreterArgs != null) result.interpreterArgs = interpreterArgs;
    return result;
  }

  Pm2Process._();

  factory Pm2Process.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Process()..mergeFromBuffer(data, registry);
  factory Pm2Process.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Process()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2Process',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2Process.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'pmId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'namespace')
    ..aI(4, _omitFieldNames ? '' : 'pid')
    ..aOS(5, _omitFieldNames ? '' : 'status')
    ..aD(6, _omitFieldNames ? '' : 'cpu')
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'memory', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(8, _omitFieldNames ? '' : 'startedAt')
    ..aInt64(9, _omitFieldNames ? '' : 'createdAt')
    ..aI(10, _omitFieldNames ? '' : 'restarts')
    ..aI(11, _omitFieldNames ? '' : 'unstableRestarts')
    ..aOS(12, _omitFieldNames ? '' : 'execMode')
    ..aI(13, _omitFieldNames ? '' : 'instances')
    ..aOB(14, _omitFieldNames ? '' : 'watch')
    ..aOB(15, _omitFieldNames ? '' : 'autorestart')
    ..aOS(16, _omitFieldNames ? '' : 'version')
    ..aOS(17, _omitFieldNames ? '' : 'script')
    ..aOS(18, _omitFieldNames ? '' : 'cwd')
    ..aOS(19, _omitFieldNames ? '' : 'interpreter')
    ..aOS(20, _omitFieldNames ? '' : 'nodeVersion')
    ..aOB(21, _omitFieldNames ? '' : 'isModule')
    ..aOS(22, _omitFieldNames ? '' : 'user')
    ..aOS(23, _omitFieldNames ? '' : 'outLog')
    ..aOS(24, _omitFieldNames ? '' : 'errLog')
    ..aInt64(25, _omitFieldNames ? '' : 'maxMemoryRestart')
    ..aOS(26, _omitFieldNames ? '' : 'cronRestart')
    ..pPS(27, _omitFieldNames ? '' : 'args')
    ..pPS(28, _omitFieldNames ? '' : 'customActions')
    ..pPM<Pm2Metric>(29, _omitFieldNames ? '' : 'metrics',
        subBuilder: Pm2Metric.$_createMessage)
    ..aOM<Pm2Versioning>(30, _omitFieldNames ? '' : 'versioning',
        subBuilder: Pm2Versioning.$_createMessage)
    ..aI(31, _omitFieldNames ? '' : 'exitCode')
    ..aOS(32, _omitFieldNames ? '' : 'interpreterArgs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Process clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Process copyWith(void Function(Pm2Process) updates) =>
      super.copyWith((message) => updates(message as Pm2Process)) as Pm2Process;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2Process() / Pm2Process.new instead')
  static Pm2Process create() => Pm2Process._();
  static $pb.GeneratedMessage $_createMessage() => Pm2Process._();
  @$core.override
  Pm2Process createEmptyInstance() => Pm2Process._();
  @$core.pragma('dart2js:noInline')
  static Pm2Process getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pm2Process>(Pm2Process.$_createMessage);
  static Pm2Process? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pmId => $_getIZ(0);
  @$pb.TagNumber(1)
  set pmId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get namespace => $_getSZ(2);
  @$pb.TagNumber(3)
  set namespace($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNamespace() => $_has(2);
  @$pb.TagNumber(3)
  void clearNamespace() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pid => $_getIZ(3);
  @$pb.TagNumber(4)
  set pid($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPid() => $_has(3);
  @$pb.TagNumber(4)
  void clearPid() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get status => $_getSZ(4);
  @$pb.TagNumber(5)
  set status($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get cpu => $_getN(5);
  @$pb.TagNumber(6)
  set cpu($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCpu() => $_has(5);
  @$pb.TagNumber(6)
  void clearCpu() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get memory => $_getI64(6);
  @$pb.TagNumber(7)
  set memory($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMemory() => $_has(6);
  @$pb.TagNumber(7)
  void clearMemory() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get startedAt => $_getI64(7);
  @$pb.TagNumber(8)
  set startedAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStartedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearStartedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get createdAt => $_getI64(8);
  @$pb.TagNumber(9)
  set createdAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get restarts => $_getIZ(9);
  @$pb.TagNumber(10)
  set restarts($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRestarts() => $_has(9);
  @$pb.TagNumber(10)
  void clearRestarts() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get unstableRestarts => $_getIZ(10);
  @$pb.TagNumber(11)
  set unstableRestarts($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasUnstableRestarts() => $_has(10);
  @$pb.TagNumber(11)
  void clearUnstableRestarts() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get execMode => $_getSZ(11);
  @$pb.TagNumber(12)
  set execMode($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasExecMode() => $_has(11);
  @$pb.TagNumber(12)
  void clearExecMode() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get instances => $_getIZ(12);
  @$pb.TagNumber(13)
  set instances($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasInstances() => $_has(12);
  @$pb.TagNumber(13)
  void clearInstances() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get watch => $_getBF(13);
  @$pb.TagNumber(14)
  set watch($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasWatch() => $_has(13);
  @$pb.TagNumber(14)
  void clearWatch() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get autorestart => $_getBF(14);
  @$pb.TagNumber(15)
  set autorestart($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasAutorestart() => $_has(14);
  @$pb.TagNumber(15)
  void clearAutorestart() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get version => $_getSZ(15);
  @$pb.TagNumber(16)
  set version($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasVersion() => $_has(15);
  @$pb.TagNumber(16)
  void clearVersion() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get script => $_getSZ(16);
  @$pb.TagNumber(17)
  set script($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasScript() => $_has(16);
  @$pb.TagNumber(17)
  void clearScript() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get cwd => $_getSZ(17);
  @$pb.TagNumber(18)
  set cwd($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasCwd() => $_has(17);
  @$pb.TagNumber(18)
  void clearCwd() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get interpreter => $_getSZ(18);
  @$pb.TagNumber(19)
  set interpreter($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasInterpreter() => $_has(18);
  @$pb.TagNumber(19)
  void clearInterpreter() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get nodeVersion => $_getSZ(19);
  @$pb.TagNumber(20)
  set nodeVersion($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasNodeVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearNodeVersion() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.bool get isModule => $_getBF(20);
  @$pb.TagNumber(21)
  set isModule($core.bool value) => $_setBool(20, value);
  @$pb.TagNumber(21)
  $core.bool hasIsModule() => $_has(20);
  @$pb.TagNumber(21)
  void clearIsModule() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get user => $_getSZ(21);
  @$pb.TagNumber(22)
  set user($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasUser() => $_has(21);
  @$pb.TagNumber(22)
  void clearUser() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get outLog => $_getSZ(22);
  @$pb.TagNumber(23)
  set outLog($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasOutLog() => $_has(22);
  @$pb.TagNumber(23)
  void clearOutLog() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.String get errLog => $_getSZ(23);
  @$pb.TagNumber(24)
  set errLog($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasErrLog() => $_has(23);
  @$pb.TagNumber(24)
  void clearErrLog() => $_clearField(24);

  @$pb.TagNumber(25)
  $fixnum.Int64 get maxMemoryRestart => $_getI64(24);
  @$pb.TagNumber(25)
  set maxMemoryRestart($fixnum.Int64 value) => $_setInt64(24, value);
  @$pb.TagNumber(25)
  $core.bool hasMaxMemoryRestart() => $_has(24);
  @$pb.TagNumber(25)
  void clearMaxMemoryRestart() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.String get cronRestart => $_getSZ(25);
  @$pb.TagNumber(26)
  set cronRestart($core.String value) => $_setString(25, value);
  @$pb.TagNumber(26)
  $core.bool hasCronRestart() => $_has(25);
  @$pb.TagNumber(26)
  void clearCronRestart() => $_clearField(26);

  @$pb.TagNumber(27)
  $pb.PbList<$core.String> get args => $_getList(26);

  @$pb.TagNumber(28)
  $pb.PbList<$core.String> get customActions => $_getList(27);

  @$pb.TagNumber(29)
  $pb.PbList<Pm2Metric> get metrics => $_getList(28);

  @$pb.TagNumber(30)
  Pm2Versioning get versioning => $_getN(29);
  @$pb.TagNumber(30)
  set versioning(Pm2Versioning value) => $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasVersioning() => $_has(29);
  @$pb.TagNumber(30)
  void clearVersioning() => $_clearField(30);
  @$pb.TagNumber(30)
  Pm2Versioning ensureVersioning() => $_ensure(29);

  @$pb.TagNumber(31)
  $core.int get exitCode => $_getIZ(30);
  @$pb.TagNumber(31)
  set exitCode($core.int value) => $_setSignedInt32(30, value);
  @$pb.TagNumber(31)
  $core.bool hasExitCode() => $_has(30);
  @$pb.TagNumber(31)
  void clearExitCode() => $_clearField(31);

  @$pb.TagNumber(32)
  $core.String get interpreterArgs => $_getSZ(31);
  @$pb.TagNumber(32)
  set interpreterArgs($core.String value) => $_setString(31, value);
  @$pb.TagNumber(32)
  $core.bool hasInterpreterArgs() => $_has(31);
  @$pb.TagNumber(32)
  void clearInterpreterArgs() => $_clearField(32);
}

class Pm2Metric extends $pb.GeneratedMessage {
  factory Pm2Metric({
    $core.String? name,
    $core.String? value,
    $core.String? unit,
  }) {
    final result = Pm2Metric._();
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    return result;
  }

  Pm2Metric._();

  factory Pm2Metric.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Metric()..mergeFromBuffer(data, registry);
  factory Pm2Metric.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Metric()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2Metric',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2Metric.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Metric clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Metric copyWith(void Function(Pm2Metric) updates) =>
      super.copyWith((message) => updates(message as Pm2Metric)) as Pm2Metric;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2Metric() / Pm2Metric.new instead')
  static Pm2Metric create() => Pm2Metric._();
  static $pb.GeneratedMessage $_createMessage() => Pm2Metric._();
  @$core.override
  Pm2Metric createEmptyInstance() => Pm2Metric._();
  @$core.pragma('dart2js:noInline')
  static Pm2Metric getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pm2Metric>(Pm2Metric.$_createMessage);
  static Pm2Metric? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);
}

class Pm2Versioning extends $pb.GeneratedMessage {
  factory Pm2Versioning({
    $core.bool? present,
    $core.String? type,
    $core.String? url,
    $core.String? branch,
    $core.String? revision,
    $core.String? comment,
    $core.bool? unstaged,
    $fixnum.Int64? updateTime,
    $core.String? repoPath,
  }) {
    final result = Pm2Versioning._();
    if (present != null) result.present = present;
    if (type != null) result.type = type;
    if (url != null) result.url = url;
    if (branch != null) result.branch = branch;
    if (revision != null) result.revision = revision;
    if (comment != null) result.comment = comment;
    if (unstaged != null) result.unstaged = unstaged;
    if (updateTime != null) result.updateTime = updateTime;
    if (repoPath != null) result.repoPath = repoPath;
    return result;
  }

  Pm2Versioning._();

  factory Pm2Versioning.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Versioning()..mergeFromBuffer(data, registry);
  factory Pm2Versioning.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Versioning()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2Versioning',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2Versioning.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'present')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'branch')
    ..aOS(5, _omitFieldNames ? '' : 'revision')
    ..aOS(6, _omitFieldNames ? '' : 'comment')
    ..aOB(7, _omitFieldNames ? '' : 'unstaged')
    ..aInt64(8, _omitFieldNames ? '' : 'updateTime')
    ..aOS(9, _omitFieldNames ? '' : 'repoPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Versioning clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Versioning copyWith(void Function(Pm2Versioning) updates) =>
      super.copyWith((message) => updates(message as Pm2Versioning))
          as Pm2Versioning;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2Versioning() / Pm2Versioning.new instead')
  static Pm2Versioning create() => Pm2Versioning._();
  static $pb.GeneratedMessage $_createMessage() => Pm2Versioning._();
  @$core.override
  Pm2Versioning createEmptyInstance() => Pm2Versioning._();
  @$core.pragma('dart2js:noInline')
  static Pm2Versioning getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2Versioning>(
          Pm2Versioning.$_createMessage);
  static Pm2Versioning? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get present => $_getBF(0);
  @$pb.TagNumber(1)
  set present($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPresent() => $_has(0);
  @$pb.TagNumber(1)
  void clearPresent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get branch => $_getSZ(3);
  @$pb.TagNumber(4)
  set branch($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBranch() => $_has(3);
  @$pb.TagNumber(4)
  void clearBranch() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get revision => $_getSZ(4);
  @$pb.TagNumber(5)
  set revision($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRevision() => $_has(4);
  @$pb.TagNumber(5)
  void clearRevision() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get comment => $_getSZ(5);
  @$pb.TagNumber(6)
  set comment($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasComment() => $_has(5);
  @$pb.TagNumber(6)
  void clearComment() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get unstaged => $_getBF(6);
  @$pb.TagNumber(7)
  set unstaged($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnstaged() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnstaged() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get updateTime => $_getI64(7);
  @$pb.TagNumber(8)
  set updateTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdateTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get repoPath => $_getSZ(8);
  @$pb.TagNumber(9)
  set repoPath($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRepoPath() => $_has(8);
  @$pb.TagNumber(9)
  void clearRepoPath() => $_clearField(9);
}

class Pm2Target extends $pb.GeneratedMessage {
  factory Pm2Target({
    $core.String? target,
  }) {
    final result = Pm2Target._();
    if (target != null) result.target = target;
    return result;
  }

  Pm2Target._();

  factory Pm2Target.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Target()..mergeFromBuffer(data, registry);
  factory Pm2Target.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2Target()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2Target',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2Target.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'target')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Target clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2Target copyWith(void Function(Pm2Target) updates) =>
      super.copyWith((message) => updates(message as Pm2Target)) as Pm2Target;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2Target() / Pm2Target.new instead')
  static Pm2Target create() => Pm2Target._();
  static $pb.GeneratedMessage $_createMessage() => Pm2Target._();
  @$core.override
  Pm2Target createEmptyInstance() => Pm2Target._();
  @$core.pragma('dart2js:noInline')
  static Pm2Target getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pm2Target>(Pm2Target.$_createMessage);
  static Pm2Target? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);
}

class Pm2ProcessDetails extends $pb.GeneratedMessage {
  factory Pm2ProcessDetails({
    Pm2Process? process,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? env,
    $core.String? rawJson,
  }) {
    final result = Pm2ProcessDetails._();
    if (process != null) result.process = process;
    if (env != null) result.env.addEntries(env);
    if (rawJson != null) result.rawJson = rawJson;
    return result;
  }

  Pm2ProcessDetails._();

  factory Pm2ProcessDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2ProcessDetails()..mergeFromBuffer(data, registry);
  factory Pm2ProcessDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2ProcessDetails()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2ProcessDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2ProcessDetails.$_createMessage)
    ..aOM<Pm2Process>(1, _omitFieldNames ? '' : 'process',
        subBuilder: Pm2Process.$_createMessage)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'env',
        entryClassName: 'Pm2ProcessDetails.EnvEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('picontrol'))
    ..aOS(3, _omitFieldNames ? '' : 'rawJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2ProcessDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2ProcessDetails copyWith(void Function(Pm2ProcessDetails) updates) =>
      super.copyWith((message) => updates(message as Pm2ProcessDetails))
          as Pm2ProcessDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2ProcessDetails() / Pm2ProcessDetails.new instead')
  static Pm2ProcessDetails create() => Pm2ProcessDetails._();
  static $pb.GeneratedMessage $_createMessage() => Pm2ProcessDetails._();
  @$core.override
  Pm2ProcessDetails createEmptyInstance() => Pm2ProcessDetails._();
  @$core.pragma('dart2js:noInline')
  static Pm2ProcessDetails getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2ProcessDetails>(
          Pm2ProcessDetails.$_createMessage);
  static Pm2ProcessDetails? _defaultInstance;

  @$pb.TagNumber(1)
  Pm2Process get process => $_getN(0);
  @$pb.TagNumber(1)
  set process(Pm2Process value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProcess() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcess() => $_clearField(1);
  @$pb.TagNumber(1)
  Pm2Process ensureProcess() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get env => $_getMap(1);

  @$pb.TagNumber(3)
  $core.String get rawJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set rawJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRawJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearRawJson() => $_clearField(3);
}

class Pm2StartRequest extends $pb.GeneratedMessage {
  factory Pm2StartRequest({
    Pm2StartMode? mode,
    $core.String? script,
    $core.String? name,
    $core.String? cwd,
    $core.Iterable<$core.String>? args,
    $core.String? interpreter,
    $core.String? interpreterArgs,
    $core.String? namespace,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? env,
    $core.String? instances,
    $core.bool? watch,
    $core.String? ignoreWatch,
    $core.String? watchDelay,
    $core.String? maxMemoryRestart,
    $core.String? cronRestart,
    $core.bool? noAutorestart,
    $core.int? restartDelay,
    $core.int? expBackoffRestartDelay,
    $core.int? maxRestarts,
    $core.String? stopExitCodes,
    $core.bool? time,
    $core.String? logDateFormat,
    $core.bool? mergeLogs,
    $core.String? outputLog,
    $core.String? errorLog,
    $core.String? combinedLog,
    $core.bool? disableLogs,
    $core.int? killTimeout,
    $core.int? listenTimeout,
    $core.bool? waitReady,
    $core.bool? shutdownWithMessage,
    $core.bool? noTreekill,
    $core.bool? noAutostart,
    $core.bool? noVizion,
    $core.bool? force,
    $core.String? configFile,
    $core.String? envName,
    $core.String? only,
    $core.bool? updateEnv,
    $core.String? servePath,
    $core.int? servePort,
    $core.bool? spa,
    $core.String? basicAuthUsername,
    $core.String? basicAuthPassword,
  }) {
    final result = Pm2StartRequest._();
    if (mode != null) result.mode = mode;
    if (script != null) result.script = script;
    if (name != null) result.name = name;
    if (cwd != null) result.cwd = cwd;
    if (args != null) result.args.addAll(args);
    if (interpreter != null) result.interpreter = interpreter;
    if (interpreterArgs != null) result.interpreterArgs = interpreterArgs;
    if (namespace != null) result.namespace = namespace;
    if (env != null) result.env.addEntries(env);
    if (instances != null) result.instances = instances;
    if (watch != null) result.watch = watch;
    if (ignoreWatch != null) result.ignoreWatch = ignoreWatch;
    if (watchDelay != null) result.watchDelay = watchDelay;
    if (maxMemoryRestart != null) result.maxMemoryRestart = maxMemoryRestart;
    if (cronRestart != null) result.cronRestart = cronRestart;
    if (noAutorestart != null) result.noAutorestart = noAutorestart;
    if (restartDelay != null) result.restartDelay = restartDelay;
    if (expBackoffRestartDelay != null)
      result.expBackoffRestartDelay = expBackoffRestartDelay;
    if (maxRestarts != null) result.maxRestarts = maxRestarts;
    if (stopExitCodes != null) result.stopExitCodes = stopExitCodes;
    if (time != null) result.time = time;
    if (logDateFormat != null) result.logDateFormat = logDateFormat;
    if (mergeLogs != null) result.mergeLogs = mergeLogs;
    if (outputLog != null) result.outputLog = outputLog;
    if (errorLog != null) result.errorLog = errorLog;
    if (combinedLog != null) result.combinedLog = combinedLog;
    if (disableLogs != null) result.disableLogs = disableLogs;
    if (killTimeout != null) result.killTimeout = killTimeout;
    if (listenTimeout != null) result.listenTimeout = listenTimeout;
    if (waitReady != null) result.waitReady = waitReady;
    if (shutdownWithMessage != null)
      result.shutdownWithMessage = shutdownWithMessage;
    if (noTreekill != null) result.noTreekill = noTreekill;
    if (noAutostart != null) result.noAutostart = noAutostart;
    if (noVizion != null) result.noVizion = noVizion;
    if (force != null) result.force = force;
    if (configFile != null) result.configFile = configFile;
    if (envName != null) result.envName = envName;
    if (only != null) result.only = only;
    if (updateEnv != null) result.updateEnv = updateEnv;
    if (servePath != null) result.servePath = servePath;
    if (servePort != null) result.servePort = servePort;
    if (spa != null) result.spa = spa;
    if (basicAuthUsername != null) result.basicAuthUsername = basicAuthUsername;
    if (basicAuthPassword != null) result.basicAuthPassword = basicAuthPassword;
    return result;
  }

  Pm2StartRequest._();

  factory Pm2StartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2StartRequest()..mergeFromBuffer(data, registry);
  factory Pm2StartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2StartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2StartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2StartRequest.$_createMessage)
    ..aE<Pm2StartMode>(1, _omitFieldNames ? '' : 'mode',
        enumValues: Pm2StartMode.values)
    ..aOS(2, _omitFieldNames ? '' : 'script')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'cwd')
    ..pPS(5, _omitFieldNames ? '' : 'args')
    ..aOS(6, _omitFieldNames ? '' : 'interpreter')
    ..aOS(7, _omitFieldNames ? '' : 'interpreterArgs')
    ..aOS(8, _omitFieldNames ? '' : 'namespace')
    ..m<$core.String, $core.String>(9, _omitFieldNames ? '' : 'env',
        entryClassName: 'Pm2StartRequest.EnvEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('picontrol'))
    ..aOS(10, _omitFieldNames ? '' : 'instances')
    ..aOB(11, _omitFieldNames ? '' : 'watch')
    ..aOS(12, _omitFieldNames ? '' : 'ignoreWatch')
    ..aOS(13, _omitFieldNames ? '' : 'watchDelay')
    ..aOS(14, _omitFieldNames ? '' : 'maxMemoryRestart')
    ..aOS(15, _omitFieldNames ? '' : 'cronRestart')
    ..aOB(16, _omitFieldNames ? '' : 'noAutorestart')
    ..aI(17, _omitFieldNames ? '' : 'restartDelay')
    ..aI(18, _omitFieldNames ? '' : 'expBackoffRestartDelay')
    ..aI(19, _omitFieldNames ? '' : 'maxRestarts')
    ..aOS(20, _omitFieldNames ? '' : 'stopExitCodes')
    ..aOB(21, _omitFieldNames ? '' : 'time')
    ..aOS(22, _omitFieldNames ? '' : 'logDateFormat')
    ..aOB(23, _omitFieldNames ? '' : 'mergeLogs')
    ..aOS(24, _omitFieldNames ? '' : 'outputLog')
    ..aOS(25, _omitFieldNames ? '' : 'errorLog')
    ..aOS(26, _omitFieldNames ? '' : 'combinedLog')
    ..aOB(27, _omitFieldNames ? '' : 'disableLogs')
    ..aI(28, _omitFieldNames ? '' : 'killTimeout')
    ..aI(29, _omitFieldNames ? '' : 'listenTimeout')
    ..aOB(30, _omitFieldNames ? '' : 'waitReady')
    ..aOB(31, _omitFieldNames ? '' : 'shutdownWithMessage')
    ..aOB(32, _omitFieldNames ? '' : 'noTreekill')
    ..aOB(33, _omitFieldNames ? '' : 'noAutostart')
    ..aOB(34, _omitFieldNames ? '' : 'noVizion')
    ..aOB(35, _omitFieldNames ? '' : 'force')
    ..aOS(36, _omitFieldNames ? '' : 'configFile')
    ..aOS(37, _omitFieldNames ? '' : 'envName')
    ..aOS(38, _omitFieldNames ? '' : 'only')
    ..aOB(39, _omitFieldNames ? '' : 'updateEnv')
    ..aOS(40, _omitFieldNames ? '' : 'servePath')
    ..aI(41, _omitFieldNames ? '' : 'servePort')
    ..aOB(42, _omitFieldNames ? '' : 'spa')
    ..aOS(43, _omitFieldNames ? '' : 'basicAuthUsername')
    ..aOS(44, _omitFieldNames ? '' : 'basicAuthPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2StartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2StartRequest copyWith(void Function(Pm2StartRequest) updates) =>
      super.copyWith((message) => updates(message as Pm2StartRequest))
          as Pm2StartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2StartRequest() / Pm2StartRequest.new instead')
  static Pm2StartRequest create() => Pm2StartRequest._();
  static $pb.GeneratedMessage $_createMessage() => Pm2StartRequest._();
  @$core.override
  Pm2StartRequest createEmptyInstance() => Pm2StartRequest._();
  @$core.pragma('dart2js:noInline')
  static Pm2StartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2StartRequest>(
          Pm2StartRequest.$_createMessage);
  static Pm2StartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Pm2StartMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(Pm2StartMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  /// General
  @$pb.TagNumber(2)
  $core.String get script => $_getSZ(1);
  @$pb.TagNumber(2)
  set script($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearScript() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cwd => $_getSZ(3);
  @$pb.TagNumber(4)
  set cwd($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCwd() => $_has(3);
  @$pb.TagNumber(4)
  void clearCwd() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get args => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get interpreter => $_getSZ(5);
  @$pb.TagNumber(6)
  set interpreter($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInterpreter() => $_has(5);
  @$pb.TagNumber(6)
  void clearInterpreter() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get interpreterArgs => $_getSZ(6);
  @$pb.TagNumber(7)
  set interpreterArgs($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasInterpreterArgs() => $_has(6);
  @$pb.TagNumber(7)
  void clearInterpreterArgs() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get namespace => $_getSZ(7);
  @$pb.TagNumber(8)
  set namespace($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNamespace() => $_has(7);
  @$pb.TagNumber(8)
  void clearNamespace() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, $core.String> get env => $_getMap(8);

  /// Scaling
  @$pb.TagNumber(10)
  $core.String get instances => $_getSZ(9);
  @$pb.TagNumber(10)
  set instances($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasInstances() => $_has(9);
  @$pb.TagNumber(10)
  void clearInstances() => $_clearField(10);

  /// Watch
  @$pb.TagNumber(11)
  $core.bool get watch => $_getBF(10);
  @$pb.TagNumber(11)
  set watch($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWatch() => $_has(10);
  @$pb.TagNumber(11)
  void clearWatch() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get ignoreWatch => $_getSZ(11);
  @$pb.TagNumber(12)
  set ignoreWatch($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIgnoreWatch() => $_has(11);
  @$pb.TagNumber(12)
  void clearIgnoreWatch() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get watchDelay => $_getSZ(12);
  @$pb.TagNumber(13)
  set watchDelay($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasWatchDelay() => $_has(12);
  @$pb.TagNumber(13)
  void clearWatchDelay() => $_clearField(13);

  /// Restart strategy
  @$pb.TagNumber(14)
  $core.String get maxMemoryRestart => $_getSZ(13);
  @$pb.TagNumber(14)
  set maxMemoryRestart($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasMaxMemoryRestart() => $_has(13);
  @$pb.TagNumber(14)
  void clearMaxMemoryRestart() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get cronRestart => $_getSZ(14);
  @$pb.TagNumber(15)
  set cronRestart($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCronRestart() => $_has(14);
  @$pb.TagNumber(15)
  void clearCronRestart() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get noAutorestart => $_getBF(15);
  @$pb.TagNumber(16)
  set noAutorestart($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasNoAutorestart() => $_has(15);
  @$pb.TagNumber(16)
  void clearNoAutorestart() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get restartDelay => $_getIZ(16);
  @$pb.TagNumber(17)
  set restartDelay($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasRestartDelay() => $_has(16);
  @$pb.TagNumber(17)
  void clearRestartDelay() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get expBackoffRestartDelay => $_getIZ(17);
  @$pb.TagNumber(18)
  set expBackoffRestartDelay($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasExpBackoffRestartDelay() => $_has(17);
  @$pb.TagNumber(18)
  void clearExpBackoffRestartDelay() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get maxRestarts => $_getIZ(18);
  @$pb.TagNumber(19)
  set maxRestarts($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasMaxRestarts() => $_has(18);
  @$pb.TagNumber(19)
  void clearMaxRestarts() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get stopExitCodes => $_getSZ(19);
  @$pb.TagNumber(20)
  set stopExitCodes($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasStopExitCodes() => $_has(19);
  @$pb.TagNumber(20)
  void clearStopExitCodes() => $_clearField(20);

  /// Logs
  @$pb.TagNumber(21)
  $core.bool get time => $_getBF(20);
  @$pb.TagNumber(21)
  set time($core.bool value) => $_setBool(20, value);
  @$pb.TagNumber(21)
  $core.bool hasTime() => $_has(20);
  @$pb.TagNumber(21)
  void clearTime() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get logDateFormat => $_getSZ(21);
  @$pb.TagNumber(22)
  set logDateFormat($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasLogDateFormat() => $_has(21);
  @$pb.TagNumber(22)
  void clearLogDateFormat() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.bool get mergeLogs => $_getBF(22);
  @$pb.TagNumber(23)
  set mergeLogs($core.bool value) => $_setBool(22, value);
  @$pb.TagNumber(23)
  $core.bool hasMergeLogs() => $_has(22);
  @$pb.TagNumber(23)
  void clearMergeLogs() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.String get outputLog => $_getSZ(23);
  @$pb.TagNumber(24)
  set outputLog($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasOutputLog() => $_has(23);
  @$pb.TagNumber(24)
  void clearOutputLog() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.String get errorLog => $_getSZ(24);
  @$pb.TagNumber(25)
  set errorLog($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasErrorLog() => $_has(24);
  @$pb.TagNumber(25)
  void clearErrorLog() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.String get combinedLog => $_getSZ(25);
  @$pb.TagNumber(26)
  set combinedLog($core.String value) => $_setString(25, value);
  @$pb.TagNumber(26)
  $core.bool hasCombinedLog() => $_has(25);
  @$pb.TagNumber(26)
  void clearCombinedLog() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.bool get disableLogs => $_getBF(26);
  @$pb.TagNumber(27)
  set disableLogs($core.bool value) => $_setBool(26, value);
  @$pb.TagNumber(27)
  $core.bool hasDisableLogs() => $_has(26);
  @$pb.TagNumber(27)
  void clearDisableLogs() => $_clearField(27);

  /// Control flow
  @$pb.TagNumber(28)
  $core.int get killTimeout => $_getIZ(27);
  @$pb.TagNumber(28)
  set killTimeout($core.int value) => $_setSignedInt32(27, value);
  @$pb.TagNumber(28)
  $core.bool hasKillTimeout() => $_has(27);
  @$pb.TagNumber(28)
  void clearKillTimeout() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.int get listenTimeout => $_getIZ(28);
  @$pb.TagNumber(29)
  set listenTimeout($core.int value) => $_setSignedInt32(28, value);
  @$pb.TagNumber(29)
  $core.bool hasListenTimeout() => $_has(28);
  @$pb.TagNumber(29)
  void clearListenTimeout() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.bool get waitReady => $_getBF(29);
  @$pb.TagNumber(30)
  set waitReady($core.bool value) => $_setBool(29, value);
  @$pb.TagNumber(30)
  $core.bool hasWaitReady() => $_has(29);
  @$pb.TagNumber(30)
  void clearWaitReady() => $_clearField(30);

  @$pb.TagNumber(31)
  $core.bool get shutdownWithMessage => $_getBF(30);
  @$pb.TagNumber(31)
  set shutdownWithMessage($core.bool value) => $_setBool(30, value);
  @$pb.TagNumber(31)
  $core.bool hasShutdownWithMessage() => $_has(30);
  @$pb.TagNumber(31)
  void clearShutdownWithMessage() => $_clearField(31);

  @$pb.TagNumber(32)
  $core.bool get noTreekill => $_getBF(31);
  @$pb.TagNumber(32)
  set noTreekill($core.bool value) => $_setBool(31, value);
  @$pb.TagNumber(32)
  $core.bool hasNoTreekill() => $_has(31);
  @$pb.TagNumber(32)
  void clearNoTreekill() => $_clearField(32);

  @$pb.TagNumber(33)
  $core.bool get noAutostart => $_getBF(32);
  @$pb.TagNumber(33)
  set noAutostart($core.bool value) => $_setBool(32, value);
  @$pb.TagNumber(33)
  $core.bool hasNoAutostart() => $_has(32);
  @$pb.TagNumber(33)
  void clearNoAutostart() => $_clearField(33);

  @$pb.TagNumber(34)
  $core.bool get noVizion => $_getBF(33);
  @$pb.TagNumber(34)
  set noVizion($core.bool value) => $_setBool(33, value);
  @$pb.TagNumber(34)
  $core.bool hasNoVizion() => $_has(33);
  @$pb.TagNumber(34)
  void clearNoVizion() => $_clearField(34);

  @$pb.TagNumber(35)
  $core.bool get force => $_getBF(34);
  @$pb.TagNumber(35)
  set force($core.bool value) => $_setBool(34, value);
  @$pb.TagNumber(35)
  $core.bool hasForce() => $_has(34);
  @$pb.TagNumber(35)
  void clearForce() => $_clearField(35);

  /// Ecosystem
  @$pb.TagNumber(36)
  $core.String get configFile => $_getSZ(35);
  @$pb.TagNumber(36)
  set configFile($core.String value) => $_setString(35, value);
  @$pb.TagNumber(36)
  $core.bool hasConfigFile() => $_has(35);
  @$pb.TagNumber(36)
  void clearConfigFile() => $_clearField(36);

  @$pb.TagNumber(37)
  $core.String get envName => $_getSZ(36);
  @$pb.TagNumber(37)
  set envName($core.String value) => $_setString(36, value);
  @$pb.TagNumber(37)
  $core.bool hasEnvName() => $_has(36);
  @$pb.TagNumber(37)
  void clearEnvName() => $_clearField(37);

  @$pb.TagNumber(38)
  $core.String get only => $_getSZ(37);
  @$pb.TagNumber(38)
  set only($core.String value) => $_setString(37, value);
  @$pb.TagNumber(38)
  $core.bool hasOnly() => $_has(37);
  @$pb.TagNumber(38)
  void clearOnly() => $_clearField(38);

  @$pb.TagNumber(39)
  $core.bool get updateEnv => $_getBF(38);
  @$pb.TagNumber(39)
  set updateEnv($core.bool value) => $_setBool(38, value);
  @$pb.TagNumber(39)
  $core.bool hasUpdateEnv() => $_has(38);
  @$pb.TagNumber(39)
  void clearUpdateEnv() => $_clearField(39);

  /// Serve
  @$pb.TagNumber(40)
  $core.String get servePath => $_getSZ(39);
  @$pb.TagNumber(40)
  set servePath($core.String value) => $_setString(39, value);
  @$pb.TagNumber(40)
  $core.bool hasServePath() => $_has(39);
  @$pb.TagNumber(40)
  void clearServePath() => $_clearField(40);

  @$pb.TagNumber(41)
  $core.int get servePort => $_getIZ(40);
  @$pb.TagNumber(41)
  set servePort($core.int value) => $_setSignedInt32(40, value);
  @$pb.TagNumber(41)
  $core.bool hasServePort() => $_has(40);
  @$pb.TagNumber(41)
  void clearServePort() => $_clearField(41);

  @$pb.TagNumber(42)
  $core.bool get spa => $_getBF(41);
  @$pb.TagNumber(42)
  set spa($core.bool value) => $_setBool(41, value);
  @$pb.TagNumber(42)
  $core.bool hasSpa() => $_has(41);
  @$pb.TagNumber(42)
  void clearSpa() => $_clearField(42);

  @$pb.TagNumber(43)
  $core.String get basicAuthUsername => $_getSZ(42);
  @$pb.TagNumber(43)
  set basicAuthUsername($core.String value) => $_setString(42, value);
  @$pb.TagNumber(43)
  $core.bool hasBasicAuthUsername() => $_has(42);
  @$pb.TagNumber(43)
  void clearBasicAuthUsername() => $_clearField(43);

  @$pb.TagNumber(44)
  $core.String get basicAuthPassword => $_getSZ(43);
  @$pb.TagNumber(44)
  set basicAuthPassword($core.String value) => $_setString(43, value);
  @$pb.TagNumber(44)
  $core.bool hasBasicAuthPassword() => $_has(43);
  @$pb.TagNumber(44)
  void clearBasicAuthPassword() => $_clearField(44);
}

class Pm2ControlRequest extends $pb.GeneratedMessage {
  factory Pm2ControlRequest({
    Pm2Action? action,
    $core.String? target,
    $core.bool? updateEnv,
    $core.String? envName,
    $core.String? only,
    $core.String? value,
    $core.String? actionName,
    $core.String? actionParam,
  }) {
    final result = Pm2ControlRequest._();
    if (action != null) result.action = action;
    if (target != null) result.target = target;
    if (updateEnv != null) result.updateEnv = updateEnv;
    if (envName != null) result.envName = envName;
    if (only != null) result.only = only;
    if (value != null) result.value = value;
    if (actionName != null) result.actionName = actionName;
    if (actionParam != null) result.actionParam = actionParam;
    return result;
  }

  Pm2ControlRequest._();

  factory Pm2ControlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2ControlRequest()..mergeFromBuffer(data, registry);
  factory Pm2ControlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2ControlRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2ControlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2ControlRequest.$_createMessage)
    ..aE<Pm2Action>(1, _omitFieldNames ? '' : 'action',
        enumValues: Pm2Action.values)
    ..aOS(2, _omitFieldNames ? '' : 'target')
    ..aOB(3, _omitFieldNames ? '' : 'updateEnv')
    ..aOS(4, _omitFieldNames ? '' : 'envName')
    ..aOS(5, _omitFieldNames ? '' : 'only')
    ..aOS(6, _omitFieldNames ? '' : 'value')
    ..aOS(7, _omitFieldNames ? '' : 'actionName')
    ..aOS(8, _omitFieldNames ? '' : 'actionParam')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2ControlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2ControlRequest copyWith(void Function(Pm2ControlRequest) updates) =>
      super.copyWith((message) => updates(message as Pm2ControlRequest))
          as Pm2ControlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2ControlRequest() / Pm2ControlRequest.new instead')
  static Pm2ControlRequest create() => Pm2ControlRequest._();
  static $pb.GeneratedMessage $_createMessage() => Pm2ControlRequest._();
  @$core.override
  Pm2ControlRequest createEmptyInstance() => Pm2ControlRequest._();
  @$core.pragma('dart2js:noInline')
  static Pm2ControlRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2ControlRequest>(
          Pm2ControlRequest.$_createMessage);
  static Pm2ControlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Pm2Action get action => $_getN(0);
  @$pb.TagNumber(1)
  set action(Pm2Action value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAction() => $_has(0);
  @$pb.TagNumber(1)
  void clearAction() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get target => $_getSZ(1);
  @$pb.TagNumber(2)
  set target($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTarget() => $_has(1);
  @$pb.TagNumber(2)
  void clearTarget() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get updateEnv => $_getBF(2);
  @$pb.TagNumber(3)
  set updateEnv($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUpdateEnv() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpdateEnv() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get envName => $_getSZ(3);
  @$pb.TagNumber(4)
  set envName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnvName() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnvName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get only => $_getSZ(4);
  @$pb.TagNumber(5)
  set only($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOnly() => $_has(4);
  @$pb.TagNumber(5)
  void clearOnly() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get value => $_getSZ(5);
  @$pb.TagNumber(6)
  set value($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get actionName => $_getSZ(6);
  @$pb.TagNumber(7)
  set actionName($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActionName() => $_has(6);
  @$pb.TagNumber(7)
  void clearActionName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get actionParam => $_getSZ(7);
  @$pb.TagNumber(8)
  set actionParam($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActionParam() => $_has(7);
  @$pb.TagNumber(8)
  void clearActionParam() => $_clearField(8);
}

class Pm2CommandResult extends $pb.GeneratedMessage {
  factory Pm2CommandResult({
    $core.bool? success,
    $core.String? output,
    $core.String? command,
    $core.int? exitCode,
  }) {
    final result = Pm2CommandResult._();
    if (success != null) result.success = success;
    if (output != null) result.output = output;
    if (command != null) result.command = command;
    if (exitCode != null) result.exitCode = exitCode;
    return result;
  }

  Pm2CommandResult._();

  factory Pm2CommandResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2CommandResult()..mergeFromBuffer(data, registry);
  factory Pm2CommandResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2CommandResult()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2CommandResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2CommandResult.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'output')
    ..aOS(3, _omitFieldNames ? '' : 'command')
    ..aI(4, _omitFieldNames ? '' : 'exitCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2CommandResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2CommandResult copyWith(void Function(Pm2CommandResult) updates) =>
      super.copyWith((message) => updates(message as Pm2CommandResult))
          as Pm2CommandResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2CommandResult() / Pm2CommandResult.new instead')
  static Pm2CommandResult create() => Pm2CommandResult._();
  static $pb.GeneratedMessage $_createMessage() => Pm2CommandResult._();
  @$core.override
  Pm2CommandResult createEmptyInstance() => Pm2CommandResult._();
  @$core.pragma('dart2js:noInline')
  static Pm2CommandResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2CommandResult>(
          Pm2CommandResult.$_createMessage);
  static Pm2CommandResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get output => $_getSZ(1);
  @$pb.TagNumber(2)
  set output($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutput() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutput() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get command => $_getSZ(2);
  @$pb.TagNumber(3)
  set command($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommand() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommand() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get exitCode => $_getIZ(3);
  @$pb.TagNumber(4)
  set exitCode($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExitCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearExitCode() => $_clearField(4);
}

class Pm2LogRequest extends $pb.GeneratedMessage {
  factory Pm2LogRequest({
    $core.String? target,
    $core.int? lines,
    $core.bool? follow,
    $core.bool? includeOut,
    $core.bool? includeErr,
    $core.bool? includeDaemon,
  }) {
    final result = Pm2LogRequest._();
    if (target != null) result.target = target;
    if (lines != null) result.lines = lines;
    if (follow != null) result.follow = follow;
    if (includeOut != null) result.includeOut = includeOut;
    if (includeErr != null) result.includeErr = includeErr;
    if (includeDaemon != null) result.includeDaemon = includeDaemon;
    return result;
  }

  Pm2LogRequest._();

  factory Pm2LogRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2LogRequest()..mergeFromBuffer(data, registry);
  factory Pm2LogRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2LogRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2LogRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2LogRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'target')
    ..aI(2, _omitFieldNames ? '' : 'lines')
    ..aOB(3, _omitFieldNames ? '' : 'follow')
    ..aOB(4, _omitFieldNames ? '' : 'includeOut')
    ..aOB(5, _omitFieldNames ? '' : 'includeErr')
    ..aOB(6, _omitFieldNames ? '' : 'includeDaemon')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2LogRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2LogRequest copyWith(void Function(Pm2LogRequest) updates) =>
      super.copyWith((message) => updates(message as Pm2LogRequest))
          as Pm2LogRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2LogRequest() / Pm2LogRequest.new instead')
  static Pm2LogRequest create() => Pm2LogRequest._();
  static $pb.GeneratedMessage $_createMessage() => Pm2LogRequest._();
  @$core.override
  Pm2LogRequest createEmptyInstance() => Pm2LogRequest._();
  @$core.pragma('dart2js:noInline')
  static Pm2LogRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2LogRequest>(
          Pm2LogRequest.$_createMessage);
  static Pm2LogRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get lines => $_getIZ(1);
  @$pb.TagNumber(2)
  set lines($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLines() => $_has(1);
  @$pb.TagNumber(2)
  void clearLines() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get follow => $_getBF(2);
  @$pb.TagNumber(3)
  set follow($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFollow() => $_has(2);
  @$pb.TagNumber(3)
  void clearFollow() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get includeOut => $_getBF(3);
  @$pb.TagNumber(4)
  set includeOut($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIncludeOut() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludeOut() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeErr => $_getBF(4);
  @$pb.TagNumber(5)
  set includeErr($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeErr() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeErr() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get includeDaemon => $_getBF(5);
  @$pb.TagNumber(6)
  set includeDaemon($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIncludeDaemon() => $_has(5);
  @$pb.TagNumber(6)
  void clearIncludeDaemon() => $_clearField(6);
}

class Pm2LogLine extends $pb.GeneratedMessage {
  factory Pm2LogLine({
    $core.String? appName,
    $core.int? pmId,
    $core.String? stream,
    $core.String? text,
    $fixnum.Int64? receivedAt,
    $fixnum.Int64? timestamp,
    $core.bool? timestampFromLog,
    $core.bool? history,
    $core.String? message,
  }) {
    final result = Pm2LogLine._();
    if (appName != null) result.appName = appName;
    if (pmId != null) result.pmId = pmId;
    if (stream != null) result.stream = stream;
    if (text != null) result.text = text;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (timestamp != null) result.timestamp = timestamp;
    if (timestampFromLog != null) result.timestampFromLog = timestampFromLog;
    if (history != null) result.history = history;
    if (message != null) result.message = message;
    return result;
  }

  Pm2LogLine._();

  factory Pm2LogLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2LogLine()..mergeFromBuffer(data, registry);
  factory Pm2LogLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2LogLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2LogLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2LogLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'appName')
    ..aI(2, _omitFieldNames ? '' : 'pmId')
    ..aOS(3, _omitFieldNames ? '' : 'stream')
    ..aOS(4, _omitFieldNames ? '' : 'text')
    ..aInt64(5, _omitFieldNames ? '' : 'receivedAt')
    ..aInt64(6, _omitFieldNames ? '' : 'timestamp')
    ..aOB(7, _omitFieldNames ? '' : 'timestampFromLog')
    ..aOB(8, _omitFieldNames ? '' : 'history')
    ..aOS(9, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2LogLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2LogLine copyWith(void Function(Pm2LogLine) updates) =>
      super.copyWith((message) => updates(message as Pm2LogLine)) as Pm2LogLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2LogLine() / Pm2LogLine.new instead')
  static Pm2LogLine create() => Pm2LogLine._();
  static $pb.GeneratedMessage $_createMessage() => Pm2LogLine._();
  @$core.override
  Pm2LogLine createEmptyInstance() => Pm2LogLine._();
  @$core.pragma('dart2js:noInline')
  static Pm2LogLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pm2LogLine>(Pm2LogLine.$_createMessage);
  static Pm2LogLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appName => $_getSZ(0);
  @$pb.TagNumber(1)
  set appName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAppName() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pmId => $_getIZ(1);
  @$pb.TagNumber(2)
  set pmId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearPmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get stream => $_getSZ(2);
  @$pb.TagNumber(3)
  set stream($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStream() => $_has(2);
  @$pb.TagNumber(3)
  void clearStream() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get text => $_getSZ(3);
  @$pb.TagNumber(4)
  set text($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get receivedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set receivedAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReceivedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearReceivedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get timestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set timestamp($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get timestampFromLog => $_getBF(6);
  @$pb.TagNumber(7)
  set timestampFromLog($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTimestampFromLog() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimestampFromLog() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get history => $_getBF(7);
  @$pb.TagNumber(8)
  set history($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHistory() => $_has(7);
  @$pb.TagNumber(8)
  void clearHistory() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get message => $_getSZ(8);
  @$pb.TagNumber(9)
  set message($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMessage() => $_has(8);
  @$pb.TagNumber(9)
  void clearMessage() => $_clearField(9);
}

class Pm2OperationRequest extends $pb.GeneratedMessage {
  factory Pm2OperationRequest({
    Pm2Operation? operation,
    $core.String? name,
    $core.String? value,
    $core.String? configFile,
    $core.String? deployEnv,
    $core.String? deployCommand,
    $core.String? deployArgs,
    $core.String? cwd,
    $core.bool? force,
    $core.String? mode,
  }) {
    final result = Pm2OperationRequest._();
    if (operation != null) result.operation = operation;
    if (name != null) result.name = name;
    if (value != null) result.value = value;
    if (configFile != null) result.configFile = configFile;
    if (deployEnv != null) result.deployEnv = deployEnv;
    if (deployCommand != null) result.deployCommand = deployCommand;
    if (deployArgs != null) result.deployArgs = deployArgs;
    if (cwd != null) result.cwd = cwd;
    if (force != null) result.force = force;
    if (mode != null) result.mode = mode;
    return result;
  }

  Pm2OperationRequest._();

  factory Pm2OperationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2OperationRequest()..mergeFromBuffer(data, registry);
  factory Pm2OperationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2OperationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2OperationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2OperationRequest.$_createMessage)
    ..aE<Pm2Operation>(1, _omitFieldNames ? '' : 'operation',
        enumValues: Pm2Operation.values)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'value')
    ..aOS(4, _omitFieldNames ? '' : 'configFile')
    ..aOS(5, _omitFieldNames ? '' : 'deployEnv')
    ..aOS(6, _omitFieldNames ? '' : 'deployCommand')
    ..aOS(7, _omitFieldNames ? '' : 'deployArgs')
    ..aOS(8, _omitFieldNames ? '' : 'cwd')
    ..aOB(9, _omitFieldNames ? '' : 'force')
    ..aOS(10, _omitFieldNames ? '' : 'mode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2OperationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2OperationRequest copyWith(void Function(Pm2OperationRequest) updates) =>
      super.copyWith((message) => updates(message as Pm2OperationRequest))
          as Pm2OperationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use Pm2OperationRequest() / Pm2OperationRequest.new instead')
  static Pm2OperationRequest create() => Pm2OperationRequest._();
  static $pb.GeneratedMessage $_createMessage() => Pm2OperationRequest._();
  @$core.override
  Pm2OperationRequest createEmptyInstance() => Pm2OperationRequest._();
  @$core.pragma('dart2js:noInline')
  static Pm2OperationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Pm2OperationRequest>(
          Pm2OperationRequest.$_createMessage);
  static Pm2OperationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Pm2Operation get operation => $_getN(0);
  @$pb.TagNumber(1)
  set operation(Pm2Operation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOperation() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperation() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get value => $_getSZ(2);
  @$pb.TagNumber(3)
  set value($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get configFile => $_getSZ(3);
  @$pb.TagNumber(4)
  set configFile($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfigFile() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfigFile() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get deployEnv => $_getSZ(4);
  @$pb.TagNumber(5)
  set deployEnv($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeployEnv() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeployEnv() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get deployCommand => $_getSZ(5);
  @$pb.TagNumber(6)
  set deployCommand($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeployCommand() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeployCommand() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get deployArgs => $_getSZ(6);
  @$pb.TagNumber(7)
  set deployArgs($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeployArgs() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeployArgs() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get cwd => $_getSZ(7);
  @$pb.TagNumber(8)
  set cwd($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCwd() => $_has(7);
  @$pb.TagNumber(8)
  void clearCwd() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get force => $_getBF(8);
  @$pb.TagNumber(9)
  set force($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasForce() => $_has(8);
  @$pb.TagNumber(9)
  void clearForce() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get mode => $_getSZ(9);
  @$pb.TagNumber(10)
  set mode($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMode() => $_has(9);
  @$pb.TagNumber(10)
  void clearMode() => $_clearField(10);
}

class Pm2OutputLine extends $pb.GeneratedMessage {
  factory Pm2OutputLine({
    $core.String? text,
    $core.bool? isError,
    $core.bool? done,
    $core.bool? success,
    $core.int? exitCode,
  }) {
    final result = Pm2OutputLine._();
    if (text != null) result.text = text;
    if (isError != null) result.isError = isError;
    if (done != null) result.done = done;
    if (success != null) result.success = success;
    if (exitCode != null) result.exitCode = exitCode;
    return result;
  }

  Pm2OutputLine._();

  factory Pm2OutputLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2OutputLine()..mergeFromBuffer(data, registry);
  factory Pm2OutputLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Pm2OutputLine()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Pm2OutputLine',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Pm2OutputLine.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOB(2, _omitFieldNames ? '' : 'isError')
    ..aOB(3, _omitFieldNames ? '' : 'done')
    ..aOB(4, _omitFieldNames ? '' : 'success')
    ..aI(5, _omitFieldNames ? '' : 'exitCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2OutputLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Pm2OutputLine copyWith(void Function(Pm2OutputLine) updates) =>
      super.copyWith((message) => updates(message as Pm2OutputLine))
          as Pm2OutputLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Pm2OutputLine() / Pm2OutputLine.new instead')
  static Pm2OutputLine create() => Pm2OutputLine._();
  static $pb.GeneratedMessage $_createMessage() => Pm2OutputLine._();
  @$core.override
  Pm2OutputLine createEmptyInstance() => Pm2OutputLine._();
  @$core.pragma('dart2js:noInline')
  static Pm2OutputLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Pm2OutputLine>(
          Pm2OutputLine.$_createMessage);
  static Pm2OutputLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isError => $_getBF(1);
  @$pb.TagNumber(2)
  set isError($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsError() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsError() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get done => $_getBF(2);
  @$pb.TagNumber(3)
  set done($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDone() => $_has(2);
  @$pb.TagNumber(3)
  void clearDone() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get success => $_getBF(3);
  @$pb.TagNumber(4)
  set success($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuccess() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuccess() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get exitCode => $_getIZ(4);
  @$pb.TagNumber(5)
  set exitCode($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExitCode() => $_has(4);
  @$pb.TagNumber(5)
  void clearExitCode() => $_clearField(5);
}

class CommandOutput extends $pb.GeneratedMessage {
  factory CommandOutput({
    $core.bool? success,
    $core.String? output,
    $core.int? exitCode,
    $core.String? command,
  }) {
    final result = CommandOutput._();
    if (success != null) result.success = success;
    if (output != null) result.output = output;
    if (exitCode != null) result.exitCode = exitCode;
    if (command != null) result.command = command;
    return result;
  }

  CommandOutput._();

  factory CommandOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandOutput()..mergeFromBuffer(data, registry);
  factory CommandOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: CommandOutput.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'output')
    ..aI(3, _omitFieldNames ? '' : 'exitCode')
    ..aOS(4, _omitFieldNames ? '' : 'command')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandOutput copyWith(void Function(CommandOutput) updates) =>
      super.copyWith((message) => updates(message as CommandOutput))
          as CommandOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommandOutput() / CommandOutput.new instead')
  static CommandOutput create() => CommandOutput._();
  static $pb.GeneratedMessage $_createMessage() => CommandOutput._();
  @$core.override
  CommandOutput createEmptyInstance() => CommandOutput._();
  @$core.pragma('dart2js:noInline')
  static CommandOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandOutput>(
          CommandOutput.$_createMessage);
  static CommandOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get output => $_getSZ(1);
  @$pb.TagNumber(2)
  set output($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutput() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutput() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get exitCode => $_getIZ(2);
  @$pb.TagNumber(3)
  set exitCode($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExitCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearExitCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get command => $_getSZ(3);
  @$pb.TagNumber(4)
  set command($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCommand() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommand() => $_clearField(4);
}

class CrontabRequest extends $pb.GeneratedMessage {
  factory CrontabRequest({
    $core.String? user,
  }) {
    final result = CrontabRequest._();
    if (user != null) result.user = user;
    return result;
  }

  CrontabRequest._();

  factory CrontabRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CrontabRequest()..mergeFromBuffer(data, registry);
  factory CrontabRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CrontabRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CrontabRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: CrontabRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'user')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CrontabRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CrontabRequest copyWith(void Function(CrontabRequest) updates) =>
      super.copyWith((message) => updates(message as CrontabRequest))
          as CrontabRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CrontabRequest() / CrontabRequest.new instead')
  static CrontabRequest create() => CrontabRequest._();
  static $pb.GeneratedMessage $_createMessage() => CrontabRequest._();
  @$core.override
  CrontabRequest createEmptyInstance() => CrontabRequest._();
  @$core.pragma('dart2js:noInline')
  static CrontabRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CrontabRequest>(
          CrontabRequest.$_createMessage);
  static CrontabRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get user => $_getSZ(0);
  @$pb.TagNumber(1)
  set user($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);
}

class Crontab extends $pb.GeneratedMessage {
  factory Crontab({
    $core.String? user,
    $core.String? content,
    $core.bool? exists,
    $core.Iterable<CronFile>? systemFiles,
    $core.Iterable<$core.String>? usersWithCrontab,
  }) {
    final result = Crontab._();
    if (user != null) result.user = user;
    if (content != null) result.content = content;
    if (exists != null) result.exists = exists;
    if (systemFiles != null) result.systemFiles.addAll(systemFiles);
    if (usersWithCrontab != null)
      result.usersWithCrontab.addAll(usersWithCrontab);
    return result;
  }

  Crontab._();

  factory Crontab.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Crontab()..mergeFromBuffer(data, registry);
  factory Crontab.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Crontab()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Crontab',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: Crontab.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'user')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..aOB(3, _omitFieldNames ? '' : 'exists')
    ..pPM<CronFile>(4, _omitFieldNames ? '' : 'systemFiles',
        subBuilder: CronFile.$_createMessage)
    ..pPS(5, _omitFieldNames ? '' : 'usersWithCrontab')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Crontab clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Crontab copyWith(void Function(Crontab) updates) =>
      super.copyWith((message) => updates(message as Crontab)) as Crontab;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Crontab() / Crontab.new instead')
  static Crontab create() => Crontab._();
  static $pb.GeneratedMessage $_createMessage() => Crontab._();
  @$core.override
  Crontab createEmptyInstance() => Crontab._();
  @$core.pragma('dart2js:noInline')
  static Crontab getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Crontab>(Crontab.$_createMessage);
  static Crontab? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get user => $_getSZ(0);
  @$pb.TagNumber(1)
  set user($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get exists => $_getBF(2);
  @$pb.TagNumber(3)
  set exists($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExists() => $_has(2);
  @$pb.TagNumber(3)
  void clearExists() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<CronFile> get systemFiles => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get usersWithCrontab => $_getList(4);
}

class CronFile extends $pb.GeneratedMessage {
  factory CronFile({
    $core.String? path,
    $core.String? content,
  }) {
    final result = CronFile._();
    if (path != null) result.path = path;
    if (content != null) result.content = content;
    return result;
  }

  CronFile._();

  factory CronFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CronFile()..mergeFromBuffer(data, registry);
  factory CronFile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CronFile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CronFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: CronFile.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CronFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CronFile copyWith(void Function(CronFile) updates) =>
      super.copyWith((message) => updates(message as CronFile)) as CronFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CronFile() / CronFile.new instead')
  static CronFile create() => CronFile._();
  static $pb.GeneratedMessage $_createMessage() => CronFile._();
  @$core.override
  CronFile createEmptyInstance() => CronFile._();
  @$core.pragma('dart2js:noInline')
  static CronFile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CronFile>(CronFile.$_createMessage);
  static CronFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);
}

class RunAsUserRequest extends $pb.GeneratedMessage {
  factory RunAsUserRequest({
    $core.String? user,
    $core.String? command,
    $core.int? timeoutSeconds,
  }) {
    final result = RunAsUserRequest._();
    if (user != null) result.user = user;
    if (command != null) result.command = command;
    if (timeoutSeconds != null) result.timeoutSeconds = timeoutSeconds;
    return result;
  }

  RunAsUserRequest._();

  factory RunAsUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RunAsUserRequest()..mergeFromBuffer(data, registry);
  factory RunAsUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RunAsUserRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RunAsUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: RunAsUserRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'user')
    ..aOS(2, _omitFieldNames ? '' : 'command')
    ..aI(3, _omitFieldNames ? '' : 'timeoutSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunAsUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunAsUserRequest copyWith(void Function(RunAsUserRequest) updates) =>
      super.copyWith((message) => updates(message as RunAsUserRequest))
          as RunAsUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RunAsUserRequest() / RunAsUserRequest.new instead')
  static RunAsUserRequest create() => RunAsUserRequest._();
  static $pb.GeneratedMessage $_createMessage() => RunAsUserRequest._();
  @$core.override
  RunAsUserRequest createEmptyInstance() => RunAsUserRequest._();
  @$core.pragma('dart2js:noInline')
  static RunAsUserRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RunAsUserRequest>(
          RunAsUserRequest.$_createMessage);
  static RunAsUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get user => $_getSZ(0);
  @$pb.TagNumber(1)
  set user($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUser() => $_has(0);
  @$pb.TagNumber(1)
  void clearUser() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get command => $_getSZ(1);
  @$pb.TagNumber(2)
  set command($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommand() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommand() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get timeoutSeconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeoutSeconds($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimeoutSeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeoutSeconds() => $_clearField(3);
}

class FirewallStatus extends $pb.GeneratedMessage {
  factory FirewallStatus({
    $core.bool? installed,
    $core.bool? active,
    $core.String? defaultIncoming,
    $core.String? defaultOutgoing,
    $core.String? defaultRouted,
    $core.String? logging,
    $core.Iterable<FirewallRule>? rules,
    $core.String? raw,
    $core.int? sshPort,
    $core.Iterable<$core.String>? appProfiles,
  }) {
    final result = FirewallStatus._();
    if (installed != null) result.installed = installed;
    if (active != null) result.active = active;
    if (defaultIncoming != null) result.defaultIncoming = defaultIncoming;
    if (defaultOutgoing != null) result.defaultOutgoing = defaultOutgoing;
    if (defaultRouted != null) result.defaultRouted = defaultRouted;
    if (logging != null) result.logging = logging;
    if (rules != null) result.rules.addAll(rules);
    if (raw != null) result.raw = raw;
    if (sshPort != null) result.sshPort = sshPort;
    if (appProfiles != null) result.appProfiles.addAll(appProfiles);
    return result;
  }

  FirewallStatus._();

  factory FirewallStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FirewallStatus()..mergeFromBuffer(data, registry);
  factory FirewallStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FirewallStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirewallStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FirewallStatus.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'installed')
    ..aOB(2, _omitFieldNames ? '' : 'active')
    ..aOS(3, _omitFieldNames ? '' : 'defaultIncoming')
    ..aOS(4, _omitFieldNames ? '' : 'defaultOutgoing')
    ..aOS(5, _omitFieldNames ? '' : 'defaultRouted')
    ..aOS(6, _omitFieldNames ? '' : 'logging')
    ..pPM<FirewallRule>(7, _omitFieldNames ? '' : 'rules',
        subBuilder: FirewallRule.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'raw')
    ..aI(9, _omitFieldNames ? '' : 'sshPort')
    ..pPS(10, _omitFieldNames ? '' : 'appProfiles')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirewallStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirewallStatus copyWith(void Function(FirewallStatus) updates) =>
      super.copyWith((message) => updates(message as FirewallStatus))
          as FirewallStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FirewallStatus() / FirewallStatus.new instead')
  static FirewallStatus create() => FirewallStatus._();
  static $pb.GeneratedMessage $_createMessage() => FirewallStatus._();
  @$core.override
  FirewallStatus createEmptyInstance() => FirewallStatus._();
  @$core.pragma('dart2js:noInline')
  static FirewallStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FirewallStatus>(
          FirewallStatus.$_createMessage);
  static FirewallStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get installed => $_getBF(0);
  @$pb.TagNumber(1)
  set installed($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInstalled() => $_has(0);
  @$pb.TagNumber(1)
  void clearInstalled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get active => $_getBF(1);
  @$pb.TagNumber(2)
  set active($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActive() => $_has(1);
  @$pb.TagNumber(2)
  void clearActive() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get defaultIncoming => $_getSZ(2);
  @$pb.TagNumber(3)
  set defaultIncoming($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultIncoming() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultIncoming() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get defaultOutgoing => $_getSZ(3);
  @$pb.TagNumber(4)
  set defaultOutgoing($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultOutgoing() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultOutgoing() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get defaultRouted => $_getSZ(4);
  @$pb.TagNumber(5)
  set defaultRouted($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDefaultRouted() => $_has(4);
  @$pb.TagNumber(5)
  void clearDefaultRouted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get logging => $_getSZ(5);
  @$pb.TagNumber(6)
  set logging($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLogging() => $_has(5);
  @$pb.TagNumber(6)
  void clearLogging() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<FirewallRule> get rules => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get raw => $_getSZ(7);
  @$pb.TagNumber(8)
  set raw($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRaw() => $_has(7);
  @$pb.TagNumber(8)
  void clearRaw() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get sshPort => $_getIZ(8);
  @$pb.TagNumber(9)
  set sshPort($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSshPort() => $_has(8);
  @$pb.TagNumber(9)
  void clearSshPort() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get appProfiles => $_getList(9);
}

class FirewallRule extends $pb.GeneratedMessage {
  factory FirewallRule({
    $core.int? number,
    $core.String? to,
    $core.String? action,
    $core.String? from,
    $core.bool? v6,
    $core.String? comment,
    $core.String? spec,
  }) {
    final result = FirewallRule._();
    if (number != null) result.number = number;
    if (to != null) result.to = to;
    if (action != null) result.action = action;
    if (from != null) result.from = from;
    if (v6 != null) result.v6 = v6;
    if (comment != null) result.comment = comment;
    if (spec != null) result.spec = spec;
    return result;
  }

  FirewallRule._();

  factory FirewallRule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FirewallRule()..mergeFromBuffer(data, registry);
  factory FirewallRule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FirewallRule()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirewallRule',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FirewallRule.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'number')
    ..aOS(2, _omitFieldNames ? '' : 'to')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..aOS(4, _omitFieldNames ? '' : 'from')
    ..aOB(5, _omitFieldNames ? '' : 'v6')
    ..aOS(6, _omitFieldNames ? '' : 'comment')
    ..aOS(7, _omitFieldNames ? '' : 'spec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirewallRule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirewallRule copyWith(void Function(FirewallRule) updates) =>
      super.copyWith((message) => updates(message as FirewallRule))
          as FirewallRule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FirewallRule() / FirewallRule.new instead')
  static FirewallRule create() => FirewallRule._();
  static $pb.GeneratedMessage $_createMessage() => FirewallRule._();
  @$core.override
  FirewallRule createEmptyInstance() => FirewallRule._();
  @$core.pragma('dart2js:noInline')
  static FirewallRule getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FirewallRule>(
          FirewallRule.$_createMessage);
  static FirewallRule? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get number => $_getIZ(0);
  @$pb.TagNumber(1)
  set number($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get to => $_getSZ(1);
  @$pb.TagNumber(2)
  set to($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get from => $_getSZ(3);
  @$pb.TagNumber(4)
  set from($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFrom() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrom() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get v6 => $_getBF(4);
  @$pb.TagNumber(5)
  set v6($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasV6() => $_has(4);
  @$pb.TagNumber(5)
  void clearV6() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get comment => $_getSZ(5);
  @$pb.TagNumber(6)
  set comment($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasComment() => $_has(5);
  @$pb.TagNumber(6)
  void clearComment() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get spec => $_getSZ(6);
  @$pb.TagNumber(7)
  set spec($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSpec() => $_has(6);
  @$pb.TagNumber(7)
  void clearSpec() => $_clearField(7);
}

class FirewallRequest extends $pb.GeneratedMessage {
  factory FirewallRequest({
    FirewallOp? op,
    $core.String? ruleAction,
    $core.String? direction,
    $core.String? port,
    $core.String? protocol,
    $core.String? from,
    $core.String? to,
    $core.String? comment,
    $core.int? number,
    $core.String? policy,
    $core.String? chain,
    $core.String? logging,
    $core.String? interface,
    $core.String? ruleSpec,
  }) {
    final result = FirewallRequest._();
    if (op != null) result.op = op;
    if (ruleAction != null) result.ruleAction = ruleAction;
    if (direction != null) result.direction = direction;
    if (port != null) result.port = port;
    if (protocol != null) result.protocol = protocol;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (comment != null) result.comment = comment;
    if (number != null) result.number = number;
    if (policy != null) result.policy = policy;
    if (chain != null) result.chain = chain;
    if (logging != null) result.logging = logging;
    if (interface != null) result.interface = interface;
    if (ruleSpec != null) result.ruleSpec = ruleSpec;
    return result;
  }

  FirewallRequest._();

  factory FirewallRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FirewallRequest()..mergeFromBuffer(data, registry);
  factory FirewallRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FirewallRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirewallRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: FirewallRequest.$_createMessage)
    ..aE<FirewallOp>(1, _omitFieldNames ? '' : 'op',
        enumValues: FirewallOp.values)
    ..aOS(2, _omitFieldNames ? '' : 'ruleAction')
    ..aOS(3, _omitFieldNames ? '' : 'direction')
    ..aOS(4, _omitFieldNames ? '' : 'port')
    ..aOS(5, _omitFieldNames ? '' : 'protocol')
    ..aOS(6, _omitFieldNames ? '' : 'from')
    ..aOS(7, _omitFieldNames ? '' : 'to')
    ..aOS(8, _omitFieldNames ? '' : 'comment')
    ..aI(9, _omitFieldNames ? '' : 'number')
    ..aOS(10, _omitFieldNames ? '' : 'policy')
    ..aOS(11, _omitFieldNames ? '' : 'chain')
    ..aOS(12, _omitFieldNames ? '' : 'logging')
    ..aOS(13, _omitFieldNames ? '' : 'interface')
    ..aOS(14, _omitFieldNames ? '' : 'ruleSpec')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirewallRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirewallRequest copyWith(void Function(FirewallRequest) updates) =>
      super.copyWith((message) => updates(message as FirewallRequest))
          as FirewallRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FirewallRequest() / FirewallRequest.new instead')
  static FirewallRequest create() => FirewallRequest._();
  static $pb.GeneratedMessage $_createMessage() => FirewallRequest._();
  @$core.override
  FirewallRequest createEmptyInstance() => FirewallRequest._();
  @$core.pragma('dart2js:noInline')
  static FirewallRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FirewallRequest>(
          FirewallRequest.$_createMessage);
  static FirewallRequest? _defaultInstance;

  @$pb.TagNumber(1)
  FirewallOp get op => $_getN(0);
  @$pb.TagNumber(1)
  set op(FirewallOp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOp() => $_has(0);
  @$pb.TagNumber(1)
  void clearOp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ruleAction => $_getSZ(1);
  @$pb.TagNumber(2)
  set ruleAction($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRuleAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearRuleAction() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get direction => $_getSZ(2);
  @$pb.TagNumber(3)
  set direction($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDirection() => $_has(2);
  @$pb.TagNumber(3)
  void clearDirection() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get port => $_getSZ(3);
  @$pb.TagNumber(4)
  set port($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPort() => $_has(3);
  @$pb.TagNumber(4)
  void clearPort() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get protocol => $_getSZ(4);
  @$pb.TagNumber(5)
  set protocol($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProtocol() => $_has(4);
  @$pb.TagNumber(5)
  void clearProtocol() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get from => $_getSZ(5);
  @$pb.TagNumber(6)
  set from($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearFrom() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get to => $_getSZ(6);
  @$pb.TagNumber(7)
  set to($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTo() => $_has(6);
  @$pb.TagNumber(7)
  void clearTo() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get comment => $_getSZ(7);
  @$pb.TagNumber(8)
  set comment($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasComment() => $_has(7);
  @$pb.TagNumber(8)
  void clearComment() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get number => $_getIZ(8);
  @$pb.TagNumber(9)
  set number($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNumber() => $_has(8);
  @$pb.TagNumber(9)
  void clearNumber() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get policy => $_getSZ(9);
  @$pb.TagNumber(10)
  set policy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPolicy() => $_has(9);
  @$pb.TagNumber(10)
  void clearPolicy() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get chain => $_getSZ(10);
  @$pb.TagNumber(11)
  set chain($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasChain() => $_has(10);
  @$pb.TagNumber(11)
  void clearChain() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get logging => $_getSZ(11);
  @$pb.TagNumber(12)
  set logging($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLogging() => $_has(11);
  @$pb.TagNumber(12)
  void clearLogging() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get interface => $_getSZ(12);
  @$pb.TagNumber(13)
  set interface($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasInterface() => $_has(12);
  @$pb.TagNumber(13)
  void clearInterface() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get ruleSpec => $_getSZ(13);
  @$pb.TagNumber(14)
  set ruleSpec($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRuleSpec() => $_has(13);
  @$pb.TagNumber(14)
  void clearRuleSpec() => $_clearField(14);
}

class UserList extends $pb.GeneratedMessage {
  factory UserList({
    $core.Iterable<SystemUser>? users,
    $core.Iterable<SystemGroup>? groups,
    $core.String? agentUser,
    $core.Iterable<$core.String>? shells,
  }) {
    final result = UserList._();
    if (users != null) result.users.addAll(users);
    if (groups != null) result.groups.addAll(groups);
    if (agentUser != null) result.agentUser = agentUser;
    if (shells != null) result.shells.addAll(shells);
    return result;
  }

  UserList._();

  factory UserList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserList()..mergeFromBuffer(data, registry);
  factory UserList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserList()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: UserList.$_createMessage)
    ..pPM<SystemUser>(1, _omitFieldNames ? '' : 'users',
        subBuilder: SystemUser.$_createMessage)
    ..pPM<SystemGroup>(2, _omitFieldNames ? '' : 'groups',
        subBuilder: SystemGroup.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'agentUser')
    ..pPS(4, _omitFieldNames ? '' : 'shells')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserList copyWith(void Function(UserList) updates) =>
      super.copyWith((message) => updates(message as UserList)) as UserList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UserList() / UserList.new instead')
  static UserList create() => UserList._();
  static $pb.GeneratedMessage $_createMessage() => UserList._();
  @$core.override
  UserList createEmptyInstance() => UserList._();
  @$core.pragma('dart2js:noInline')
  static UserList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserList>(UserList.$_createMessage);
  static UserList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SystemUser> get users => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<SystemGroup> get groups => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get agentUser => $_getSZ(2);
  @$pb.TagNumber(3)
  set agentUser($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAgentUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearAgentUser() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get shells => $_getList(3);
}

class SystemUser extends $pb.GeneratedMessage {
  factory SystemUser({
    $core.String? name,
    $core.int? uid,
    $core.int? gid,
    $core.String? fullName,
    $core.String? home,
    $core.String? shell,
    $core.Iterable<$core.String>? groups,
    $core.bool? locked,
    $core.bool? isSystem,
    $core.bool? canSudo,
    $core.bool? hasPassword,
  }) {
    final result = SystemUser._();
    if (name != null) result.name = name;
    if (uid != null) result.uid = uid;
    if (gid != null) result.gid = gid;
    if (fullName != null) result.fullName = fullName;
    if (home != null) result.home = home;
    if (shell != null) result.shell = shell;
    if (groups != null) result.groups.addAll(groups);
    if (locked != null) result.locked = locked;
    if (isSystem != null) result.isSystem = isSystem;
    if (canSudo != null) result.canSudo = canSudo;
    if (hasPassword != null) result.hasPassword = hasPassword;
    return result;
  }

  SystemUser._();

  factory SystemUser.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemUser()..mergeFromBuffer(data, registry);
  factory SystemUser.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemUser()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemUser',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: SystemUser.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'uid')
    ..aI(3, _omitFieldNames ? '' : 'gid')
    ..aOS(4, _omitFieldNames ? '' : 'fullName')
    ..aOS(5, _omitFieldNames ? '' : 'home')
    ..aOS(6, _omitFieldNames ? '' : 'shell')
    ..pPS(7, _omitFieldNames ? '' : 'groups')
    ..aOB(8, _omitFieldNames ? '' : 'locked')
    ..aOB(9, _omitFieldNames ? '' : 'isSystem')
    ..aOB(10, _omitFieldNames ? '' : 'canSudo')
    ..aOB(11, _omitFieldNames ? '' : 'hasPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemUser clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemUser copyWith(void Function(SystemUser) updates) =>
      super.copyWith((message) => updates(message as SystemUser)) as SystemUser;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SystemUser() / SystemUser.new instead')
  static SystemUser create() => SystemUser._();
  static $pb.GeneratedMessage $_createMessage() => SystemUser._();
  @$core.override
  SystemUser createEmptyInstance() => SystemUser._();
  @$core.pragma('dart2js:noInline')
  static SystemUser getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SystemUser>(SystemUser.$_createMessage);
  static SystemUser? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get uid => $_getIZ(1);
  @$pb.TagNumber(2)
  set uid($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get gid => $_getIZ(2);
  @$pb.TagNumber(3)
  set gid($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGid() => $_has(2);
  @$pb.TagNumber(3)
  void clearGid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fullName => $_getSZ(3);
  @$pb.TagNumber(4)
  set fullName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFullName() => $_has(3);
  @$pb.TagNumber(4)
  void clearFullName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get home => $_getSZ(4);
  @$pb.TagNumber(5)
  set home($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHome() => $_has(4);
  @$pb.TagNumber(5)
  void clearHome() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get shell => $_getSZ(5);
  @$pb.TagNumber(6)
  set shell($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasShell() => $_has(5);
  @$pb.TagNumber(6)
  void clearShell() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get groups => $_getList(6);

  @$pb.TagNumber(8)
  $core.bool get locked => $_getBF(7);
  @$pb.TagNumber(8)
  set locked($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLocked() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocked() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isSystem => $_getBF(8);
  @$pb.TagNumber(9)
  set isSystem($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsSystem() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsSystem() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get canSudo => $_getBF(9);
  @$pb.TagNumber(10)
  set canSudo($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCanSudo() => $_has(9);
  @$pb.TagNumber(10)
  void clearCanSudo() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get hasPassword => $_getBF(10);
  @$pb.TagNumber(11)
  set hasPassword($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHasPassword() => $_has(10);
  @$pb.TagNumber(11)
  void clearHasPassword() => $_clearField(11);
}

class SystemGroup extends $pb.GeneratedMessage {
  factory SystemGroup({
    $core.String? name,
    $core.int? gid,
    $core.Iterable<$core.String>? members,
    $core.bool? isSystem,
  }) {
    final result = SystemGroup._();
    if (name != null) result.name = name;
    if (gid != null) result.gid = gid;
    if (members != null) result.members.addAll(members);
    if (isSystem != null) result.isSystem = isSystem;
    return result;
  }

  SystemGroup._();

  factory SystemGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemGroup()..mergeFromBuffer(data, registry);
  factory SystemGroup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemGroup()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SystemGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: SystemGroup.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'gid')
    ..pPS(3, _omitFieldNames ? '' : 'members')
    ..aOB(4, _omitFieldNames ? '' : 'isSystem')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemGroup copyWith(void Function(SystemGroup) updates) =>
      super.copyWith((message) => updates(message as SystemGroup))
          as SystemGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SystemGroup() / SystemGroup.new instead')
  static SystemGroup create() => SystemGroup._();
  static $pb.GeneratedMessage $_createMessage() => SystemGroup._();
  @$core.override
  SystemGroup createEmptyInstance() => SystemGroup._();
  @$core.pragma('dart2js:noInline')
  static SystemGroup getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemGroup>(
          SystemGroup.$_createMessage);
  static SystemGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get gid => $_getIZ(1);
  @$pb.TagNumber(2)
  set gid($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGid() => $_has(1);
  @$pb.TagNumber(2)
  void clearGid() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get members => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get isSystem => $_getBF(3);
  @$pb.TagNumber(4)
  set isSystem($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsSystem() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsSystem() => $_clearField(4);
}

class UserRequest extends $pb.GeneratedMessage {
  factory UserRequest({
    UserOp? op,
    $core.String? username,
    $core.String? password,
    $core.String? group,
    $core.String? shell,
    $core.String? fullName,
    $core.bool? removeHome,
    $core.bool? sudo,
    $core.Iterable<$core.String>? groups,
  }) {
    final result = UserRequest._();
    if (op != null) result.op = op;
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (group != null) result.group = group;
    if (shell != null) result.shell = shell;
    if (fullName != null) result.fullName = fullName;
    if (removeHome != null) result.removeHome = removeHome;
    if (sudo != null) result.sudo = sudo;
    if (groups != null) result.groups.addAll(groups);
    return result;
  }

  UserRequest._();

  factory UserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserRequest()..mergeFromBuffer(data, registry);
  factory UserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UserRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: UserRequest.$_createMessage)
    ..aE<UserOp>(1, _omitFieldNames ? '' : 'op', enumValues: UserOp.values)
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..aOS(4, _omitFieldNames ? '' : 'group')
    ..aOS(5, _omitFieldNames ? '' : 'shell')
    ..aOS(6, _omitFieldNames ? '' : 'fullName')
    ..aOB(7, _omitFieldNames ? '' : 'removeHome')
    ..aOB(8, _omitFieldNames ? '' : 'sudo')
    ..pPS(9, _omitFieldNames ? '' : 'groups')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserRequest copyWith(void Function(UserRequest) updates) =>
      super.copyWith((message) => updates(message as UserRequest))
          as UserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UserRequest() / UserRequest.new instead')
  static UserRequest create() => UserRequest._();
  static $pb.GeneratedMessage $_createMessage() => UserRequest._();
  @$core.override
  UserRequest createEmptyInstance() => UserRequest._();
  @$core.pragma('dart2js:noInline')
  static UserRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserRequest>(
          UserRequest.$_createMessage);
  static UserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  UserOp get op => $_getN(0);
  @$pb.TagNumber(1)
  set op(UserOp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOp() => $_has(0);
  @$pb.TagNumber(1)
  void clearOp() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get group => $_getSZ(3);
  @$pb.TagNumber(4)
  set group($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroup() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get shell => $_getSZ(4);
  @$pb.TagNumber(5)
  set shell($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasShell() => $_has(4);
  @$pb.TagNumber(5)
  void clearShell() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get fullName => $_getSZ(5);
  @$pb.TagNumber(6)
  set fullName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFullName() => $_has(5);
  @$pb.TagNumber(6)
  void clearFullName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get removeHome => $_getBF(6);
  @$pb.TagNumber(7)
  set removeHome($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRemoveHome() => $_has(6);
  @$pb.TagNumber(7)
  void clearRemoveHome() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get sudo => $_getBF(7);
  @$pb.TagNumber(8)
  set sudo($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSudo() => $_has(7);
  @$pb.TagNumber(8)
  void clearSudo() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get groups => $_getList(8);
}

class HardwareInfo extends $pb.GeneratedMessage {
  factory HardwareInfo({
    $core.bool? isRaspberryPi,
    $core.String? model,
    $core.String? serial,
    $core.String? revision,
    $core.String? soc,
    $core.String? architecture,
    $core.int? cpuCores,
    $core.Iterable<$fixnum.Int64>? cpuFreqMhz,
    $fixnum.Int64? cpuMinMhz,
    $fixnum.Int64? cpuMaxMhz,
    $core.String? governor,
    $fixnum.Int64? memoryTotal,
    $core.String? gpuMemory,
    $core.double? cpuTemp,
    $core.bool? vcgencmdAvailable,
    $core.String? throttledRaw,
    $core.Iterable<$core.String>? throttledNow,
    $core.Iterable<$core.String>? throttledPast,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? voltages,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? clocks,
    $core.String? firmware,
    $core.String? bootloader,
    $core.String? kernel,
    $core.String? os,
    $core.String? hostname,
    $core.Iterable<$core.String>? usbDevices,
  }) {
    final result = HardwareInfo._();
    if (isRaspberryPi != null) result.isRaspberryPi = isRaspberryPi;
    if (model != null) result.model = model;
    if (serial != null) result.serial = serial;
    if (revision != null) result.revision = revision;
    if (soc != null) result.soc = soc;
    if (architecture != null) result.architecture = architecture;
    if (cpuCores != null) result.cpuCores = cpuCores;
    if (cpuFreqMhz != null) result.cpuFreqMhz.addAll(cpuFreqMhz);
    if (cpuMinMhz != null) result.cpuMinMhz = cpuMinMhz;
    if (cpuMaxMhz != null) result.cpuMaxMhz = cpuMaxMhz;
    if (governor != null) result.governor = governor;
    if (memoryTotal != null) result.memoryTotal = memoryTotal;
    if (gpuMemory != null) result.gpuMemory = gpuMemory;
    if (cpuTemp != null) result.cpuTemp = cpuTemp;
    if (vcgencmdAvailable != null) result.vcgencmdAvailable = vcgencmdAvailable;
    if (throttledRaw != null) result.throttledRaw = throttledRaw;
    if (throttledNow != null) result.throttledNow.addAll(throttledNow);
    if (throttledPast != null) result.throttledPast.addAll(throttledPast);
    if (voltages != null) result.voltages.addEntries(voltages);
    if (clocks != null) result.clocks.addEntries(clocks);
    if (firmware != null) result.firmware = firmware;
    if (bootloader != null) result.bootloader = bootloader;
    if (kernel != null) result.kernel = kernel;
    if (os != null) result.os = os;
    if (hostname != null) result.hostname = hostname;
    if (usbDevices != null) result.usbDevices.addAll(usbDevices);
    return result;
  }

  HardwareInfo._();

  factory HardwareInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HardwareInfo()..mergeFromBuffer(data, registry);
  factory HardwareInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HardwareInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HardwareInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: HardwareInfo.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'isRaspberryPi')
    ..aOS(2, _omitFieldNames ? '' : 'model')
    ..aOS(3, _omitFieldNames ? '' : 'serial')
    ..aOS(4, _omitFieldNames ? '' : 'revision')
    ..aOS(5, _omitFieldNames ? '' : 'soc')
    ..aOS(6, _omitFieldNames ? '' : 'architecture')
    ..aI(7, _omitFieldNames ? '' : 'cpuCores')
    ..p<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'cpuFreqMhz', $pb.PbFieldType.K6)
    ..aInt64(9, _omitFieldNames ? '' : 'cpuMinMhz')
    ..aInt64(10, _omitFieldNames ? '' : 'cpuMaxMhz')
    ..aOS(11, _omitFieldNames ? '' : 'governor')
    ..a<$fixnum.Int64>(
        12, _omitFieldNames ? '' : 'memoryTotal', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(13, _omitFieldNames ? '' : 'gpuMemory')
    ..aD(14, _omitFieldNames ? '' : 'cpuTemp')
    ..aOB(15, _omitFieldNames ? '' : 'vcgencmdAvailable')
    ..aOS(16, _omitFieldNames ? '' : 'throttledRaw')
    ..pPS(17, _omitFieldNames ? '' : 'throttledNow')
    ..pPS(18, _omitFieldNames ? '' : 'throttledPast')
    ..m<$core.String, $core.String>(19, _omitFieldNames ? '' : 'voltages',
        entryClassName: 'HardwareInfo.VoltagesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('picontrol'))
    ..m<$core.String, $core.String>(20, _omitFieldNames ? '' : 'clocks',
        entryClassName: 'HardwareInfo.ClocksEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('picontrol'))
    ..aOS(21, _omitFieldNames ? '' : 'firmware')
    ..aOS(22, _omitFieldNames ? '' : 'bootloader')
    ..aOS(23, _omitFieldNames ? '' : 'kernel')
    ..aOS(24, _omitFieldNames ? '' : 'os')
    ..aOS(25, _omitFieldNames ? '' : 'hostname')
    ..pPS(26, _omitFieldNames ? '' : 'usbDevices')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HardwareInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HardwareInfo copyWith(void Function(HardwareInfo) updates) =>
      super.copyWith((message) => updates(message as HardwareInfo))
          as HardwareInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HardwareInfo() / HardwareInfo.new instead')
  static HardwareInfo create() => HardwareInfo._();
  static $pb.GeneratedMessage $_createMessage() => HardwareInfo._();
  @$core.override
  HardwareInfo createEmptyInstance() => HardwareInfo._();
  @$core.pragma('dart2js:noInline')
  static HardwareInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HardwareInfo>(
          HardwareInfo.$_createMessage);
  static HardwareInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isRaspberryPi => $_getBF(0);
  @$pb.TagNumber(1)
  set isRaspberryPi($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsRaspberryPi() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsRaspberryPi() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get model => $_getSZ(1);
  @$pb.TagNumber(2)
  set model($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModel() => $_has(1);
  @$pb.TagNumber(2)
  void clearModel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get serial => $_getSZ(2);
  @$pb.TagNumber(3)
  set serial($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSerial() => $_has(2);
  @$pb.TagNumber(3)
  void clearSerial() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get revision => $_getSZ(3);
  @$pb.TagNumber(4)
  set revision($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRevision() => $_has(3);
  @$pb.TagNumber(4)
  void clearRevision() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get soc => $_getSZ(4);
  @$pb.TagNumber(5)
  set soc($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSoc() => $_has(4);
  @$pb.TagNumber(5)
  void clearSoc() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get architecture => $_getSZ(5);
  @$pb.TagNumber(6)
  set architecture($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasArchitecture() => $_has(5);
  @$pb.TagNumber(6)
  void clearArchitecture() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get cpuCores => $_getIZ(6);
  @$pb.TagNumber(7)
  set cpuCores($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCpuCores() => $_has(6);
  @$pb.TagNumber(7)
  void clearCpuCores() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$fixnum.Int64> get cpuFreqMhz => $_getList(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get cpuMinMhz => $_getI64(8);
  @$pb.TagNumber(9)
  set cpuMinMhz($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCpuMinMhz() => $_has(8);
  @$pb.TagNumber(9)
  void clearCpuMinMhz() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get cpuMaxMhz => $_getI64(9);
  @$pb.TagNumber(10)
  set cpuMaxMhz($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCpuMaxMhz() => $_has(9);
  @$pb.TagNumber(10)
  void clearCpuMaxMhz() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get governor => $_getSZ(10);
  @$pb.TagNumber(11)
  set governor($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGovernor() => $_has(10);
  @$pb.TagNumber(11)
  void clearGovernor() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get memoryTotal => $_getI64(11);
  @$pb.TagNumber(12)
  set memoryTotal($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMemoryTotal() => $_has(11);
  @$pb.TagNumber(12)
  void clearMemoryTotal() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get gpuMemory => $_getSZ(12);
  @$pb.TagNumber(13)
  set gpuMemory($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasGpuMemory() => $_has(12);
  @$pb.TagNumber(13)
  void clearGpuMemory() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get cpuTemp => $_getN(13);
  @$pb.TagNumber(14)
  set cpuTemp($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCpuTemp() => $_has(13);
  @$pb.TagNumber(14)
  void clearCpuTemp() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get vcgencmdAvailable => $_getBF(14);
  @$pb.TagNumber(15)
  set vcgencmdAvailable($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVcgencmdAvailable() => $_has(14);
  @$pb.TagNumber(15)
  void clearVcgencmdAvailable() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get throttledRaw => $_getSZ(15);
  @$pb.TagNumber(16)
  set throttledRaw($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasThrottledRaw() => $_has(15);
  @$pb.TagNumber(16)
  void clearThrottledRaw() => $_clearField(16);

  @$pb.TagNumber(17)
  $pb.PbList<$core.String> get throttledNow => $_getList(16);

  @$pb.TagNumber(18)
  $pb.PbList<$core.String> get throttledPast => $_getList(17);

  @$pb.TagNumber(19)
  $pb.PbMap<$core.String, $core.String> get voltages => $_getMap(18);

  @$pb.TagNumber(20)
  $pb.PbMap<$core.String, $core.String> get clocks => $_getMap(19);

  @$pb.TagNumber(21)
  $core.String get firmware => $_getSZ(20);
  @$pb.TagNumber(21)
  set firmware($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasFirmware() => $_has(20);
  @$pb.TagNumber(21)
  void clearFirmware() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get bootloader => $_getSZ(21);
  @$pb.TagNumber(22)
  set bootloader($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasBootloader() => $_has(21);
  @$pb.TagNumber(22)
  void clearBootloader() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get kernel => $_getSZ(22);
  @$pb.TagNumber(23)
  set kernel($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasKernel() => $_has(22);
  @$pb.TagNumber(23)
  void clearKernel() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.String get os => $_getSZ(23);
  @$pb.TagNumber(24)
  set os($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasOs() => $_has(23);
  @$pb.TagNumber(24)
  void clearOs() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.String get hostname => $_getSZ(24);
  @$pb.TagNumber(25)
  set hostname($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasHostname() => $_has(24);
  @$pb.TagNumber(25)
  void clearHostname() => $_clearField(25);

  @$pb.TagNumber(26)
  $pb.PbList<$core.String> get usbDevices => $_getList(25);
}

class GpioState extends $pb.GeneratedMessage {
  factory GpioState({
    $core.bool? supported,
    $core.String? tool,
    $core.Iterable<GpioPin>? pins,
    $core.String? error,
  }) {
    final result = GpioState._();
    if (supported != null) result.supported = supported;
    if (tool != null) result.tool = tool;
    if (pins != null) result.pins.addAll(pins);
    if (error != null) result.error = error;
    return result;
  }

  GpioState._();

  factory GpioState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GpioState()..mergeFromBuffer(data, registry);
  factory GpioState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GpioState()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GpioState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: GpioState.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'supported')
    ..aOS(2, _omitFieldNames ? '' : 'tool')
    ..pPM<GpioPin>(3, _omitFieldNames ? '' : 'pins',
        subBuilder: GpioPin.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpioState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpioState copyWith(void Function(GpioState) updates) =>
      super.copyWith((message) => updates(message as GpioState)) as GpioState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GpioState() / GpioState.new instead')
  static GpioState create() => GpioState._();
  static $pb.GeneratedMessage $_createMessage() => GpioState._();
  @$core.override
  GpioState createEmptyInstance() => GpioState._();
  @$core.pragma('dart2js:noInline')
  static GpioState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GpioState>(GpioState.$_createMessage);
  static GpioState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get supported => $_getBF(0);
  @$pb.TagNumber(1)
  set supported($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSupported() => $_has(0);
  @$pb.TagNumber(1)
  void clearSupported() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tool => $_getSZ(1);
  @$pb.TagNumber(2)
  set tool($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTool() => $_has(1);
  @$pb.TagNumber(2)
  void clearTool() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<GpioPin> get pins => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get error => $_getSZ(3);
  @$pb.TagNumber(4)
  set error($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
}

class GpioPin extends $pb.GeneratedMessage {
  factory GpioPin({
    $core.int? gpio,
    $core.String? mode,
    $core.String? pull,
    $core.bool? level,
    $core.String? function,
  }) {
    final result = GpioPin._();
    if (gpio != null) result.gpio = gpio;
    if (mode != null) result.mode = mode;
    if (pull != null) result.pull = pull;
    if (level != null) result.level = level;
    if (function != null) result.function = function;
    return result;
  }

  GpioPin._();

  factory GpioPin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GpioPin()..mergeFromBuffer(data, registry);
  factory GpioPin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GpioPin()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GpioPin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: GpioPin.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'gpio')
    ..aOS(2, _omitFieldNames ? '' : 'mode')
    ..aOS(3, _omitFieldNames ? '' : 'pull')
    ..aOB(4, _omitFieldNames ? '' : 'level')
    ..aOS(5, _omitFieldNames ? '' : 'function')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpioPin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpioPin copyWith(void Function(GpioPin) updates) =>
      super.copyWith((message) => updates(message as GpioPin)) as GpioPin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GpioPin() / GpioPin.new instead')
  static GpioPin create() => GpioPin._();
  static $pb.GeneratedMessage $_createMessage() => GpioPin._();
  @$core.override
  GpioPin createEmptyInstance() => GpioPin._();
  @$core.pragma('dart2js:noInline')
  static GpioPin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GpioPin>(GpioPin.$_createMessage);
  static GpioPin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get gpio => $_getIZ(0);
  @$pb.TagNumber(1)
  set gpio($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGpio() => $_has(0);
  @$pb.TagNumber(1)
  void clearGpio() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mode => $_getSZ(1);
  @$pb.TagNumber(2)
  set mode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pull => $_getSZ(2);
  @$pb.TagNumber(3)
  set pull($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPull() => $_has(2);
  @$pb.TagNumber(3)
  void clearPull() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get level => $_getBF(3);
  @$pb.TagNumber(4)
  set level($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLevel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get function => $_getSZ(4);
  @$pb.TagNumber(5)
  set function($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFunction() => $_has(4);
  @$pb.TagNumber(5)
  void clearFunction() => $_clearField(5);
}

class GpioRequest extends $pb.GeneratedMessage {
  factory GpioRequest({
    $core.int? gpio,
    $core.String? mode,
    $core.bool? level,
    $core.String? pull,
  }) {
    final result = GpioRequest._();
    if (gpio != null) result.gpio = gpio;
    if (mode != null) result.mode = mode;
    if (level != null) result.level = level;
    if (pull != null) result.pull = pull;
    return result;
  }

  GpioRequest._();

  factory GpioRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GpioRequest()..mergeFromBuffer(data, registry);
  factory GpioRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GpioRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GpioRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: GpioRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'gpio')
    ..aOS(2, _omitFieldNames ? '' : 'mode')
    ..aOB(3, _omitFieldNames ? '' : 'level')
    ..aOS(4, _omitFieldNames ? '' : 'pull')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpioRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GpioRequest copyWith(void Function(GpioRequest) updates) =>
      super.copyWith((message) => updates(message as GpioRequest))
          as GpioRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GpioRequest() / GpioRequest.new instead')
  static GpioRequest create() => GpioRequest._();
  static $pb.GeneratedMessage $_createMessage() => GpioRequest._();
  @$core.override
  GpioRequest createEmptyInstance() => GpioRequest._();
  @$core.pragma('dart2js:noInline')
  static GpioRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GpioRequest>(
          GpioRequest.$_createMessage);
  static GpioRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get gpio => $_getIZ(0);
  @$pb.TagNumber(1)
  set gpio($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGpio() => $_has(0);
  @$pb.TagNumber(1)
  void clearGpio() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mode => $_getSZ(1);
  @$pb.TagNumber(2)
  set mode($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearMode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get level => $_getBF(2);
  @$pb.TagNumber(3)
  set level($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pull => $_getSZ(3);
  @$pb.TagNumber(4)
  set pull($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPull() => $_has(3);
  @$pb.TagNumber(4)
  void clearPull() => $_clearField(4);
}

class PowerRequest extends $pb.GeneratedMessage {
  factory PowerRequest({
    PowerOp? op,
  }) {
    final result = PowerRequest._();
    if (op != null) result.op = op;
    return result;
  }

  PowerRequest._();

  factory PowerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PowerRequest()..mergeFromBuffer(data, registry);
  factory PowerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PowerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PowerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'picontrol'),
      createEmptyInstance: PowerRequest.$_createMessage)
    ..aE<PowerOp>(1, _omitFieldNames ? '' : 'op', enumValues: PowerOp.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerRequest copyWith(void Function(PowerRequest) updates) =>
      super.copyWith((message) => updates(message as PowerRequest))
          as PowerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PowerRequest() / PowerRequest.new instead')
  static PowerRequest create() => PowerRequest._();
  static $pb.GeneratedMessage $_createMessage() => PowerRequest._();
  @$core.override
  PowerRequest createEmptyInstance() => PowerRequest._();
  @$core.pragma('dart2js:noInline')
  static PowerRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PowerRequest>(
          PowerRequest.$_createMessage);
  static PowerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PowerOp get op => $_getN(0);
  @$pb.TagNumber(1)
  set op(PowerOp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOp() => $_has(0);
  @$pb.TagNumber(1)
  void clearOp() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
