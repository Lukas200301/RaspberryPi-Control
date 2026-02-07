// This is a generated file - do not edit.
//
// Generated from pi_control.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use serviceActionDescriptor instead')
const ServiceAction$json = {
  '1': 'ServiceAction',
  '2': [
    {'1': 'START', '2': 0},
    {'1': 'STOP', '2': 1},
    {'1': 'RESTART', '2': 2},
    {'1': 'ENABLE', '2': 3},
    {'1': 'DISABLE', '2': 4},
    {'1': 'RELOAD', '2': 5},
  ],
};

/// Descriptor for `ServiceAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List serviceActionDescriptor = $convert.base64Decode(
    'Cg1TZXJ2aWNlQWN0aW9uEgkKBVNUQVJUEAASCAoEU1RPUBABEgsKB1JFU1RBUlQQAhIKCgZFTk'
    'FCTEUQAxILCgdESVNBQkxFEAQSCgoGUkVMT0FEEAU=');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use liveStatsDescriptor instead')
const LiveStats$json = {
  '1': 'LiveStats',
  '2': [
    {'1': 'cpu_usage', '3': 1, '4': 1, '5': 1, '10': 'cpuUsage'},
    {'1': 'cpu_per_core', '3': 2, '4': 3, '5': 1, '10': 'cpuPerCore'},
    {'1': 'ram_used', '3': 3, '4': 1, '5': 4, '10': 'ramUsed'},
    {'1': 'ram_total', '3': 4, '4': 1, '5': 4, '10': 'ramTotal'},
    {'1': 'ram_free', '3': 5, '4': 1, '5': 4, '10': 'ramFree'},
    {'1': 'ram_cached', '3': 6, '4': 1, '5': 4, '10': 'ramCached'},
    {'1': 'swap_used', '3': 7, '4': 1, '5': 4, '10': 'swapUsed'},
    {'1': 'swap_total', '3': 8, '4': 1, '5': 4, '10': 'swapTotal'},
    {'1': 'cpu_temp', '3': 9, '4': 1, '5': 1, '10': 'cpuTemp'},
    {'1': 'gpu_temp', '3': 10, '4': 1, '5': 1, '10': 'gpuTemp'},
    {'1': 'uptime', '3': 11, '4': 1, '5': 4, '10': 'uptime'},
    {'1': 'load_1min', '3': 12, '4': 1, '5': 1, '10': 'load1min'},
    {'1': 'load_5min', '3': 13, '4': 1, '5': 1, '10': 'load5min'},
    {'1': 'load_15min', '3': 14, '4': 1, '5': 1, '10': 'load15min'},
    {'1': 'net_bytes_sent', '3': 15, '4': 1, '5': 4, '10': 'netBytesSent'},
    {'1': 'net_bytes_recv', '3': 16, '4': 1, '5': 4, '10': 'netBytesRecv'},
    {
      '1': 'top_processes',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ProcessInfo',
      '10': 'topProcesses'
    },
    {'1': 'timestamp', '3': 18, '4': 1, '5': 3, '10': 'timestamp'},
    {
      '1': 'disk_io',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DiskIOStat',
      '10': 'diskIo'
    },
  ],
};

/// Descriptor for `LiveStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List liveStatsDescriptor = $convert.base64Decode(
    'CglMaXZlU3RhdHMSGwoJY3B1X3VzYWdlGAEgASgBUghjcHVVc2FnZRIgCgxjcHVfcGVyX2Nvcm'
    'UYAiADKAFSCmNwdVBlckNvcmUSGQoIcmFtX3VzZWQYAyABKARSB3JhbVVzZWQSGwoJcmFtX3Rv'
    'dGFsGAQgASgEUghyYW1Ub3RhbBIZCghyYW1fZnJlZRgFIAEoBFIHcmFtRnJlZRIdCgpyYW1fY2'
    'FjaGVkGAYgASgEUglyYW1DYWNoZWQSGwoJc3dhcF91c2VkGAcgASgEUghzd2FwVXNlZBIdCgpz'
    'd2FwX3RvdGFsGAggASgEUglzd2FwVG90YWwSGQoIY3B1X3RlbXAYCSABKAFSB2NwdVRlbXASGQ'
    'oIZ3B1X3RlbXAYCiABKAFSB2dwdVRlbXASFgoGdXB0aW1lGAsgASgEUgZ1cHRpbWUSGwoJbG9h'
    'ZF8xbWluGAwgASgBUghsb2FkMW1pbhIbCglsb2FkXzVtaW4YDSABKAFSCGxvYWQ1bWluEh0KCm'
    'xvYWRfMTVtaW4YDiABKAFSCWxvYWQxNW1pbhIkCg5uZXRfYnl0ZXNfc2VudBgPIAEoBFIMbmV0'
    'Qnl0ZXNTZW50EiQKDm5ldF9ieXRlc19yZWN2GBAgASgEUgxuZXRCeXRlc1JlY3YSOwoNdG9wX3'
    'Byb2Nlc3NlcxgRIAMoCzIWLnBpY29udHJvbC5Qcm9jZXNzSW5mb1IMdG9wUHJvY2Vzc2VzEhwK'
    'CXRpbWVzdGFtcBgSIAEoA1IJdGltZXN0YW1wEi4KB2Rpc2tfaW8YEyADKAsyFS5waWNvbnRyb2'
    'wuRGlza0lPU3RhdFIGZGlza0lv');

@$core.Deprecated('Use processInfoDescriptor instead')
const ProcessInfo$json = {
  '1': 'ProcessInfo',
  '2': [
    {'1': 'pid', '3': 1, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'cpu_percent', '3': 3, '4': 1, '5': 1, '10': 'cpuPercent'},
    {'1': 'memory_percent', '3': 4, '4': 1, '5': 1, '10': 'memoryPercent'},
    {'1': 'memory_bytes', '3': 5, '4': 1, '5': 4, '10': 'memoryBytes'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'username', '3': 7, '4': 1, '5': 9, '10': 'username'},
    {'1': 'cmdline', '3': 8, '4': 1, '5': 9, '10': 'cmdline'},
  ],
};

/// Descriptor for `ProcessInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processInfoDescriptor = $convert.base64Decode(
    'CgtQcm9jZXNzSW5mbxIQCgNwaWQYASABKAVSA3BpZBISCgRuYW1lGAIgASgJUgRuYW1lEh8KC2'
    'NwdV9wZXJjZW50GAMgASgBUgpjcHVQZXJjZW50EiUKDm1lbW9yeV9wZXJjZW50GAQgASgBUg1t'
    'ZW1vcnlQZXJjZW50EiEKDG1lbW9yeV9ieXRlcxgFIAEoBFILbWVtb3J5Qnl0ZXMSFgoGc3RhdH'
    'VzGAYgASgJUgZzdGF0dXMSGgoIdXNlcm5hbWUYByABKAlSCHVzZXJuYW1lEhgKB2NtZGxpbmUY'
    'CCABKAlSB2NtZGxpbmU=');

@$core.Deprecated('Use processListDescriptor instead')
const ProcessList$json = {
  '1': 'ProcessList',
  '2': [
    {
      '1': 'processes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ProcessInfo',
      '10': 'processes'
    },
  ],
};

/// Descriptor for `ProcessList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processListDescriptor = $convert.base64Decode(
    'CgtQcm9jZXNzTGlzdBI0Cglwcm9jZXNzZXMYASADKAsyFi5waWNvbnRyb2wuUHJvY2Vzc0luZm'
    '9SCXByb2Nlc3Nlcw==');

@$core.Deprecated('Use processIdDescriptor instead')
const ProcessId$json = {
  '1': 'ProcessId',
  '2': [
    {'1': 'pid', '3': 1, '4': 1, '5': 5, '10': 'pid'},
  ],
};

/// Descriptor for `ProcessId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processIdDescriptor =
    $convert.base64Decode('CglQcm9jZXNzSWQSEAoDcGlkGAEgASgFUgNwaWQ=');

@$core.Deprecated('Use serviceInfoDescriptor instead')
const ServiceInfo$json = {
  '1': 'ServiceInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'enabled', '3': 4, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'sub_state', '3': 5, '4': 1, '5': 9, '10': 'subState'},
  ],
};

/// Descriptor for `ServiceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceInfoDescriptor = $convert.base64Decode(
    'CgtTZXJ2aWNlSW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEhYKBnN0YXR1cxgCIAEoCVIGc3RhdH'
    'VzEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIYCgdlbmFibGVkGAQgASgIUgdl'
    'bmFibGVkEhsKCXN1Yl9zdGF0ZRgFIAEoCVIIc3ViU3RhdGU=');

@$core.Deprecated('Use serviceListDescriptor instead')
const ServiceList$json = {
  '1': 'ServiceList',
  '2': [
    {
      '1': 'services',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.ServiceInfo',
      '10': 'services'
    },
  ],
};

/// Descriptor for `ServiceList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceListDescriptor = $convert.base64Decode(
    'CgtTZXJ2aWNlTGlzdBIyCghzZXJ2aWNlcxgBIAMoCzIWLnBpY29udHJvbC5TZXJ2aWNlSW5mb1'
    'IIc2VydmljZXM=');

@$core.Deprecated('Use serviceCommandDescriptor instead')
const ServiceCommand$json = {
  '1': 'ServiceCommand',
  '2': [
    {'1': 'service_name', '3': 1, '4': 1, '5': 9, '10': 'serviceName'},
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.picontrol.ServiceAction',
      '10': 'action'
    },
  ],
};

/// Descriptor for `ServiceCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serviceCommandDescriptor = $convert.base64Decode(
    'Cg5TZXJ2aWNlQ29tbWFuZBIhCgxzZXJ2aWNlX25hbWUYASABKAlSC3NlcnZpY2VOYW1lEjAKBm'
    'FjdGlvbhgCIAEoDjIYLnBpY29udHJvbC5TZXJ2aWNlQWN0aW9uUgZhY3Rpb24=');

@$core.Deprecated('Use actionStatusDescriptor instead')
const ActionStatus$json = {
  '1': 'ActionStatus',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'error_code', '3': 3, '4': 1, '5': 5, '10': 'errorCode'},
  ],
};

/// Descriptor for `ActionStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionStatusDescriptor = $convert.base64Decode(
    'CgxBY3Rpb25TdGF0dXMSGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEh0KCmVycm9yX2NvZGUYAyABKAVSCWVycm9yQ29kZQ==');

@$core.Deprecated('Use logFilterDescriptor instead')
const LogFilter$json = {
  '1': 'LogFilter',
  '2': [
    {'1': 'levels', '3': 1, '4': 3, '5': 9, '10': 'levels'},
    {'1': 'service', '3': 2, '4': 1, '5': 9, '10': 'service'},
    {'1': 'tail_lines', '3': 3, '4': 1, '5': 5, '10': 'tailLines'},
  ],
};

/// Descriptor for `LogFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logFilterDescriptor = $convert.base64Decode(
    'CglMb2dGaWx0ZXISFgoGbGV2ZWxzGAEgAygJUgZsZXZlbHMSGAoHc2VydmljZRgCIAEoCVIHc2'
    'VydmljZRIdCgp0YWlsX2xpbmVzGAMgASgFUgl0YWlsTGluZXM=');

@$core.Deprecated('Use logEntryDescriptor instead')
const LogEntry$json = {
  '1': 'LogEntry',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'level', '3': 2, '4': 1, '5': 9, '10': 'level'},
    {'1': 'service', '3': 3, '4': 1, '5': 9, '10': 'service'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `LogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logEntryDescriptor = $convert.base64Decode(
    'CghMb2dFbnRyeRIcCgl0aW1lc3RhbXAYASABKANSCXRpbWVzdGFtcBIUCgVsZXZlbBgCIAEoCV'
    'IFbGV2ZWwSGAoHc2VydmljZRgDIAEoCVIHc2VydmljZRIYCgdtZXNzYWdlGAQgASgJUgdtZXNz'
    'YWdl');

@$core.Deprecated('Use diskInfoDescriptor instead')
const DiskInfo$json = {
  '1': 'DiskInfo',
  '2': [
    {
      '1': 'partitions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DiskPartition',
      '10': 'partitions'
    },
  ],
};

/// Descriptor for `DiskInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diskInfoDescriptor = $convert.base64Decode(
    'CghEaXNrSW5mbxI4CgpwYXJ0aXRpb25zGAEgAygLMhgucGljb250cm9sLkRpc2tQYXJ0aXRpb2'
    '5SCnBhcnRpdGlvbnM=');

@$core.Deprecated('Use diskPartitionDescriptor instead')
const DiskPartition$json = {
  '1': 'DiskPartition',
  '2': [
    {'1': 'device', '3': 1, '4': 1, '5': 9, '10': 'device'},
    {'1': 'mount_point', '3': 2, '4': 1, '5': 9, '10': 'mountPoint'},
    {'1': 'filesystem', '3': 3, '4': 1, '5': 9, '10': 'filesystem'},
    {'1': 'total_bytes', '3': 4, '4': 1, '5': 4, '10': 'totalBytes'},
    {'1': 'used_bytes', '3': 5, '4': 1, '5': 4, '10': 'usedBytes'},
    {'1': 'free_bytes', '3': 6, '4': 1, '5': 4, '10': 'freeBytes'},
    {'1': 'usage_percent', '3': 7, '4': 1, '5': 1, '10': 'usagePercent'},
  ],
};

/// Descriptor for `DiskPartition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diskPartitionDescriptor = $convert.base64Decode(
    'Cg1EaXNrUGFydGl0aW9uEhYKBmRldmljZRgBIAEoCVIGZGV2aWNlEh8KC21vdW50X3BvaW50GA'
    'IgASgJUgptb3VudFBvaW50Eh4KCmZpbGVzeXN0ZW0YAyABKAlSCmZpbGVzeXN0ZW0SHwoLdG90'
    'YWxfYnl0ZXMYBCABKARSCnRvdGFsQnl0ZXMSHQoKdXNlZF9ieXRlcxgFIAEoBFIJdXNlZEJ5dG'
    'VzEh0KCmZyZWVfYnl0ZXMYBiABKARSCWZyZWVCeXRlcxIjCg11c2FnZV9wZXJjZW50GAcgASgB'
    'Ugx1c2FnZVBlcmNlbnQ=');

@$core.Deprecated('Use networkInfoDescriptor instead')
const NetworkInfo$json = {
  '1': 'NetworkInfo',
  '2': [
    {
      '1': 'interfaces',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.NetworkInterface',
      '10': 'interfaces'
    },
  ],
};

/// Descriptor for `NetworkInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkInfoDescriptor = $convert.base64Decode(
    'CgtOZXR3b3JrSW5mbxI7CgppbnRlcmZhY2VzGAEgAygLMhsucGljb250cm9sLk5ldHdvcmtJbn'
    'RlcmZhY2VSCmludGVyZmFjZXM=');

@$core.Deprecated('Use networkInterfaceDescriptor instead')
const NetworkInterface$json = {
  '1': 'NetworkInterface',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'addresses', '3': 2, '4': 3, '5': 9, '10': 'addresses'},
    {'1': 'mac_address', '3': 3, '4': 1, '5': 9, '10': 'macAddress'},
    {'1': 'is_up', '3': 4, '4': 1, '5': 8, '10': 'isUp'},
    {'1': 'bytes_sent', '3': 5, '4': 1, '5': 4, '10': 'bytesSent'},
    {'1': 'bytes_recv', '3': 6, '4': 1, '5': 4, '10': 'bytesRecv'},
    {'1': 'packets_sent', '3': 7, '4': 1, '5': 4, '10': 'packetsSent'},
    {'1': 'packets_recv', '3': 8, '4': 1, '5': 4, '10': 'packetsRecv'},
  ],
};

/// Descriptor for `NetworkInterface`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkInterfaceDescriptor = $convert.base64Decode(
    'ChBOZXR3b3JrSW50ZXJmYWNlEhIKBG5hbWUYASABKAlSBG5hbWUSHAoJYWRkcmVzc2VzGAIgAy'
    'gJUglhZGRyZXNzZXMSHwoLbWFjX2FkZHJlc3MYAyABKAlSCm1hY0FkZHJlc3MSEwoFaXNfdXAY'
    'BCABKAhSBGlzVXASHQoKYnl0ZXNfc2VudBgFIAEoBFIJYnl0ZXNTZW50Eh0KCmJ5dGVzX3JlY3'
    'YYBiABKARSCWJ5dGVzUmVjdhIhCgxwYWNrZXRzX3NlbnQYByABKARSC3BhY2tldHNTZW50EiEK'
    'DHBhY2tldHNfcmVjdhgIIAEoBFILcGFja2V0c1JlY3Y=');

@$core.Deprecated('Use networkConnectionListDescriptor instead')
const NetworkConnectionList$json = {
  '1': 'NetworkConnectionList',
  '2': [
    {
      '1': 'connections',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.NetworkConnection',
      '10': 'connections'
    },
  ],
};

/// Descriptor for `NetworkConnectionList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkConnectionListDescriptor = $convert.base64Decode(
    'ChVOZXR3b3JrQ29ubmVjdGlvbkxpc3QSPgoLY29ubmVjdGlvbnMYASADKAsyHC5waWNvbnRyb2'
    'wuTmV0d29ya0Nvbm5lY3Rpb25SC2Nvbm5lY3Rpb25z');

@$core.Deprecated('Use networkConnectionDescriptor instead')
const NetworkConnection$json = {
  '1': 'NetworkConnection',
  '2': [
    {'1': 'protocol', '3': 1, '4': 1, '5': 9, '10': 'protocol'},
    {'1': 'local_address', '3': 2, '4': 1, '5': 9, '10': 'localAddress'},
    {'1': 'local_port', '3': 3, '4': 1, '5': 5, '10': 'localPort'},
    {'1': 'remote_address', '3': 4, '4': 1, '5': 9, '10': 'remoteAddress'},
    {'1': 'remote_port', '3': 5, '4': 1, '5': 5, '10': 'remotePort'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'pid', '3': 7, '4': 1, '5': 5, '10': 'pid'},
    {'1': 'process_name', '3': 8, '4': 1, '5': 9, '10': 'processName'},
  ],
};

/// Descriptor for `NetworkConnection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List networkConnectionDescriptor = $convert.base64Decode(
    'ChFOZXR3b3JrQ29ubmVjdGlvbhIaCghwcm90b2NvbBgBIAEoCVIIcHJvdG9jb2wSIwoNbG9jYW'
    'xfYWRkcmVzcxgCIAEoCVIMbG9jYWxBZGRyZXNzEh0KCmxvY2FsX3BvcnQYAyABKAVSCWxvY2Fs'
    'UG9ydBIlCg5yZW1vdGVfYWRkcmVzcxgEIAEoCVINcmVtb3RlQWRkcmVzcxIfCgtyZW1vdGVfcG'
    '9ydBgFIAEoBVIKcmVtb3RlUG9ydBIWCgZzdGF0dXMYBiABKAlSBnN0YXR1cxIQCgNwaWQYByAB'
    'KAVSA3BpZBIhCgxwcm9jZXNzX25hbWUYCCABKAlSC3Byb2Nlc3NOYW1l');

@$core.Deprecated('Use packageFilterDescriptor instead')
const PackageFilter$json = {
  '1': 'PackageFilter',
  '2': [
    {'1': 'search_term', '3': 1, '4': 1, '5': 9, '10': 'searchTerm'},
    {'1': 'installed_only', '3': 2, '4': 1, '5': 8, '10': 'installedOnly'},
  ],
};

/// Descriptor for `PackageFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageFilterDescriptor = $convert.base64Decode(
    'Cg1QYWNrYWdlRmlsdGVyEh8KC3NlYXJjaF90ZXJtGAEgASgJUgpzZWFyY2hUZXJtEiUKDmluc3'
    'RhbGxlZF9vbmx5GAIgASgIUg1pbnN0YWxsZWRPbmx5');

@$core.Deprecated('Use packageInfoDescriptor instead')
const PackageInfo$json = {
  '1': 'PackageInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'architecture', '3': 3, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'installed', '3': 5, '4': 1, '5': 8, '10': 'installed'},
    {'1': 'status', '3': 6, '4': 1, '5': 9, '10': 'status'},
    {'1': 'installed_size', '3': 7, '4': 1, '5': 4, '10': 'installedSize'},
    {'1': 'section', '3': 8, '4': 1, '5': 9, '10': 'section'},
  ],
};

/// Descriptor for `PackageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageInfoDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlSW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEhgKB3ZlcnNpb24YAiABKAlSB3Zlcn'
    'Npb24SIgoMYXJjaGl0ZWN0dXJlGAMgASgJUgxhcmNoaXRlY3R1cmUSIAoLZGVzY3JpcHRpb24Y'
    'BCABKAlSC2Rlc2NyaXB0aW9uEhwKCWluc3RhbGxlZBgFIAEoCFIJaW5zdGFsbGVkEhYKBnN0YX'
    'R1cxgGIAEoCVIGc3RhdHVzEiUKDmluc3RhbGxlZF9zaXplGAcgASgEUg1pbnN0YWxsZWRTaXpl'
    'EhgKB3NlY3Rpb24YCCABKAlSB3NlY3Rpb24=');

@$core.Deprecated('Use packageListDescriptor instead')
const PackageList$json = {
  '1': 'PackageList',
  '2': [
    {
      '1': 'packages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.picontrol.PackageInfo',
      '10': 'packages'
    },
  ],
};

/// Descriptor for `PackageList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageListDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlTGlzdBIyCghwYWNrYWdlcxgBIAMoCzIWLnBpY29udHJvbC5QYWNrYWdlSW5mb1'
    'IIcGFja2FnZXM=');

@$core.Deprecated('Use packageCommandDescriptor instead')
const PackageCommand$json = {
  '1': 'PackageCommand',
  '2': [
    {'1': 'package_name', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
  ],
};

/// Descriptor for `PackageCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageCommandDescriptor = $convert.base64Decode(
    'Cg5QYWNrYWdlQ29tbWFuZBIhCgxwYWNrYWdlX25hbWUYASABKAlSC3BhY2thZ2VOYW1l');

@$core.Deprecated('Use packageDetailsRequestDescriptor instead')
const PackageDetailsRequest$json = {
  '1': 'PackageDetailsRequest',
  '2': [
    {'1': 'package_name', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
  ],
};

/// Descriptor for `PackageDetailsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageDetailsRequestDescriptor = $convert.base64Decode(
    'ChVQYWNrYWdlRGV0YWlsc1JlcXVlc3QSIQoMcGFja2FnZV9uYW1lGAEgASgJUgtwYWNrYWdlTm'
    'FtZQ==');

@$core.Deprecated('Use packageDetailsDescriptor instead')
const PackageDetails$json = {
  '1': 'PackageDetails',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'architecture', '3': 3, '4': 1, '5': 9, '10': 'architecture'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'long_description', '3': 5, '4': 1, '5': 9, '10': 'longDescription'},
    {'1': 'installed', '3': 6, '4': 1, '5': 8, '10': 'installed'},
    {'1': 'status', '3': 7, '4': 1, '5': 9, '10': 'status'},
    {'1': 'installed_size', '3': 8, '4': 1, '5': 4, '10': 'installedSize'},
    {'1': 'maintainer', '3': 9, '4': 1, '5': 9, '10': 'maintainer'},
    {'1': 'homepage', '3': 10, '4': 1, '5': 9, '10': 'homepage'},
    {'1': 'section', '3': 11, '4': 1, '5': 9, '10': 'section'},
    {'1': 'install_date', '3': 12, '4': 1, '5': 3, '10': 'installDate'},
    {'1': 'tags', '3': 13, '4': 3, '5': 9, '10': 'tags'},
    {'1': 'source', '3': 14, '4': 1, '5': 9, '10': 'source'},
    {'1': 'priority', '3': 15, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'license', '3': 16, '4': 1, '5': 9, '10': 'license'},
  ],
};

/// Descriptor for `PackageDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageDetailsDescriptor = $convert.base64Decode(
    'Cg5QYWNrYWdlRGV0YWlscxISCgRuYW1lGAEgASgJUgRuYW1lEhgKB3ZlcnNpb24YAiABKAlSB3'
    'ZlcnNpb24SIgoMYXJjaGl0ZWN0dXJlGAMgASgJUgxhcmNoaXRlY3R1cmUSIAoLZGVzY3JpcHRp'
    'b24YBCABKAlSC2Rlc2NyaXB0aW9uEikKEGxvbmdfZGVzY3JpcHRpb24YBSABKAlSD2xvbmdEZX'
    'NjcmlwdGlvbhIcCglpbnN0YWxsZWQYBiABKAhSCWluc3RhbGxlZBIWCgZzdGF0dXMYByABKAlS'
    'BnN0YXR1cxIlCg5pbnN0YWxsZWRfc2l6ZRgIIAEoBFINaW5zdGFsbGVkU2l6ZRIeCgptYWludG'
    'FpbmVyGAkgASgJUgptYWludGFpbmVyEhoKCGhvbWVwYWdlGAogASgJUghob21lcGFnZRIYCgdz'
    'ZWN0aW9uGAsgASgJUgdzZWN0aW9uEiEKDGluc3RhbGxfZGF0ZRgMIAEoA1ILaW5zdGFsbERhdG'
    'USEgoEdGFncxgNIAMoCVIEdGFncxIWCgZzb3VyY2UYDiABKAlSBnNvdXJjZRIaCghwcmlvcml0'
    'eRgPIAEoBVIIcHJpb3JpdHkSGAoHbGljZW5zZRgQIAEoCVIHbGljZW5zZQ==');

@$core.Deprecated('Use packageDependenciesDescriptor instead')
const PackageDependencies$json = {
  '1': 'PackageDependencies',
  '2': [
    {'1': 'package_name', '3': 1, '4': 1, '5': 9, '10': 'packageName'},
    {'1': 'depends', '3': 2, '4': 3, '5': 9, '10': 'depends'},
    {'1': 'required_by', '3': 3, '4': 3, '5': 9, '10': 'requiredBy'},
    {'1': 'recommends', '3': 4, '4': 3, '5': 9, '10': 'recommends'},
    {'1': 'suggests', '3': 5, '4': 3, '5': 9, '10': 'suggests'},
    {'1': 'conflicts', '3': 6, '4': 3, '5': 9, '10': 'conflicts'},
  ],
};

/// Descriptor for `PackageDependencies`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageDependenciesDescriptor = $convert.base64Decode(
    'ChNQYWNrYWdlRGVwZW5kZW5jaWVzEiEKDHBhY2thZ2VfbmFtZRgBIAEoCVILcGFja2FnZU5hbW'
    'USGAoHZGVwZW5kcxgCIAMoCVIHZGVwZW5kcxIfCgtyZXF1aXJlZF9ieRgDIAMoCVIKcmVxdWly'
    'ZWRCeRIeCgpyZWNvbW1lbmRzGAQgAygJUgpyZWNvbW1lbmRzEhoKCHN1Z2dlc3RzGAUgAygJUg'
    'hzdWdnZXN0cxIcCgljb25mbGljdHMYBiADKAlSCWNvbmZsaWN0cw==');

@$core.Deprecated('Use packageOperationLogDescriptor instead')
const PackageOperationLog$json = {
  '1': 'PackageOperationLog',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'level', '3': 2, '4': 1, '5': 9, '10': 'level'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'progress', '3': 4, '4': 1, '5': 1, '10': 'progress'},
    {'1': 'completed', '3': 5, '4': 1, '5': 8, '10': 'completed'},
    {'1': 'success', '3': 6, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `PackageOperationLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageOperationLogDescriptor = $convert.base64Decode(
    'ChNQYWNrYWdlT3BlcmF0aW9uTG9nEhwKCXRpbWVzdGFtcBgBIAEoA1IJdGltZXN0YW1wEhQKBW'
    'xldmVsGAIgASgJUgVsZXZlbBIYCgdtZXNzYWdlGAMgASgJUgdtZXNzYWdlEhoKCHByb2dyZXNz'
    'GAQgASgBUghwcm9ncmVzcxIcCgljb21wbGV0ZWQYBSABKAhSCWNvbXBsZXRlZBIYCgdzdWNjZX'
    'NzGAYgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use diskIOStatDescriptor instead')
const DiskIOStat$json = {
  '1': 'DiskIOStat',
  '2': [
    {'1': 'device', '3': 1, '4': 1, '5': 9, '10': 'device'},
    {'1': 'read_bytes', '3': 2, '4': 1, '5': 4, '10': 'readBytes'},
    {'1': 'write_bytes', '3': 3, '4': 1, '5': 4, '10': 'writeBytes'},
    {'1': 'read_count', '3': 4, '4': 1, '5': 4, '10': 'readCount'},
    {'1': 'write_count', '3': 5, '4': 1, '5': 4, '10': 'writeCount'},
  ],
};

/// Descriptor for `DiskIOStat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diskIOStatDescriptor = $convert.base64Decode(
    'CgpEaXNrSU9TdGF0EhYKBmRldmljZRgBIAEoCVIGZGV2aWNlEh0KCnJlYWRfYnl0ZXMYAiABKA'
    'RSCXJlYWRCeXRlcxIfCgt3cml0ZV9ieXRlcxgDIAEoBFIKd3JpdGVCeXRlcxIdCgpyZWFkX2Nv'
    'dW50GAQgASgEUglyZWFkQ291bnQSHwoLd3JpdGVfY291bnQYBSABKARSCndyaXRlQ291bnQ=');

@$core.Deprecated('Use versionInfoDescriptor instead')
const VersionInfo$json = {
  '1': 'VersionInfo',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {'1': 'is_root', '3': 2, '4': 1, '5': 8, '10': 'isRoot'},
  ],
};

/// Descriptor for `VersionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionInfoDescriptor = $convert.base64Decode(
    'CgtWZXJzaW9uSW5mbxIYCgd2ZXJzaW9uGAEgASgJUgd2ZXJzaW9uEhcKB2lzX3Jvb3QYAiABKA'
    'hSBmlzUm9vdA==');

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
    {'1': 'timeout', '3': 3, '4': 1, '5': 5, '10': 'timeout'},
    {'1': 'packet_size', '3': 4, '4': 1, '5': 5, '10': 'packetSize'},
  ],
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdBISCgRob3N0GAEgASgJUgRob3N0EhQKBWNvdW50GAIgASgFUgVjb3VudB'
    'IYCgd0aW1lb3V0GAMgASgFUgd0aW1lb3V0Eh8KC3BhY2tldF9zaXplGAQgASgFUgpwYWNrZXRT'
    'aXpl');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'host', '3': 2, '4': 1, '5': 9, '10': 'host'},
    {'1': 'ip', '3': 3, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'latency', '3': 4, '4': 1, '5': 1, '10': 'latency'},
    {'1': 'sequence', '3': 5, '4': 1, '5': 5, '10': 'sequence'},
    {'1': 'ttl', '3': 6, '4': 1, '5': 5, '10': 'ttl'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
    {'1': 'finished', '3': 8, '4': 1, '5': 8, '10': 'finished'},
    {
      '1': 'statistics',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.picontrol.PingStats',
      '10': 'statistics'
    },
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxISCgRob3N0GAIgASgJUg'
    'Rob3N0Eg4KAmlwGAMgASgJUgJpcBIYCgdsYXRlbmN5GAQgASgBUgdsYXRlbmN5EhoKCHNlcXVl'
    'bmNlGAUgASgFUghzZXF1ZW5jZRIQCgN0dGwYBiABKAVSA3R0bBIUCgVlcnJvchgHIAEoCVIFZX'
    'Jyb3ISGgoIZmluaXNoZWQYCCABKAhSCGZpbmlzaGVkEjQKCnN0YXRpc3RpY3MYCSABKAsyFC5w'
    'aWNvbnRyb2wuUGluZ1N0YXRzUgpzdGF0aXN0aWNz');

@$core.Deprecated('Use pingStatsDescriptor instead')
const PingStats$json = {
  '1': 'PingStats',
  '2': [
    {'1': 'packets_sent', '3': 1, '4': 1, '5': 5, '10': 'packetsSent'},
    {'1': 'packets_received', '3': 2, '4': 1, '5': 5, '10': 'packetsReceived'},
    {'1': 'packet_loss', '3': 3, '4': 1, '5': 1, '10': 'packetLoss'},
    {'1': 'min_latency', '3': 4, '4': 1, '5': 1, '10': 'minLatency'},
    {'1': 'max_latency', '3': 5, '4': 1, '5': 1, '10': 'maxLatency'},
    {'1': 'avg_latency', '3': 6, '4': 1, '5': 1, '10': 'avgLatency'},
  ],
};

/// Descriptor for `PingStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingStatsDescriptor = $convert.base64Decode(
    'CglQaW5nU3RhdHMSIQoMcGFja2V0c19zZW50GAEgASgFUgtwYWNrZXRzU2VudBIpChBwYWNrZX'
    'RzX3JlY2VpdmVkGAIgASgFUg9wYWNrZXRzUmVjZWl2ZWQSHwoLcGFja2V0X2xvc3MYAyABKAFS'
    'CnBhY2tldExvc3MSHwoLbWluX2xhdGVuY3kYBCABKAFSCm1pbkxhdGVuY3kSHwoLbWF4X2xhdG'
    'VuY3kYBSABKAFSCm1heExhdGVuY3kSHwoLYXZnX2xhdGVuY3kYBiABKAFSCmF2Z0xhdGVuY3k=');

@$core.Deprecated('Use portScanRequestDescriptor instead')
const PortScanRequest$json = {
  '1': 'PortScanRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'ports', '3': 2, '4': 3, '5': 5, '10': 'ports'},
    {'1': 'start_port', '3': 3, '4': 1, '5': 5, '10': 'startPort'},
    {'1': 'end_port', '3': 4, '4': 1, '5': 5, '10': 'endPort'},
    {'1': 'timeout', '3': 5, '4': 1, '5': 5, '10': 'timeout'},
  ],
};

/// Descriptor for `PortScanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portScanRequestDescriptor = $convert.base64Decode(
    'Cg9Qb3J0U2NhblJlcXVlc3QSEgoEaG9zdBgBIAEoCVIEaG9zdBIUCgVwb3J0cxgCIAMoBVIFcG'
    '9ydHMSHQoKc3RhcnRfcG9ydBgDIAEoBVIJc3RhcnRQb3J0EhkKCGVuZF9wb3J0GAQgASgFUgdl'
    'bmRQb3J0EhgKB3RpbWVvdXQYBSABKAVSB3RpbWVvdXQ=');

@$core.Deprecated('Use portScanResponseDescriptor instead')
const PortScanResponse$json = {
  '1': 'PortScanResponse',
  '2': [
    {'1': 'port', '3': 1, '4': 1, '5': 5, '10': 'port'},
    {'1': 'open', '3': 2, '4': 1, '5': 8, '10': 'open'},
    {'1': 'service', '3': 3, '4': 1, '5': 9, '10': 'service'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'finished', '3': 5, '4': 1, '5': 8, '10': 'finished'},
    {'1': 'progress', '3': 6, '4': 1, '5': 5, '10': 'progress'},
  ],
};

/// Descriptor for `PortScanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List portScanResponseDescriptor = $convert.base64Decode(
    'ChBQb3J0U2NhblJlc3BvbnNlEhIKBHBvcnQYASABKAVSBHBvcnQSEgoEb3BlbhgCIAEoCFIEb3'
    'BlbhIYCgdzZXJ2aWNlGAMgASgJUgdzZXJ2aWNlEhQKBWVycm9yGAQgASgJUgVlcnJvchIaCghm'
    'aW5pc2hlZBgFIAEoCFIIZmluaXNoZWQSGgoIcHJvZ3Jlc3MYBiABKAVSCHByb2dyZXNz');

@$core.Deprecated('Use dNSRequestDescriptor instead')
const DNSRequest$json = {
  '1': 'DNSRequest',
  '2': [
    {'1': 'hostname', '3': 1, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'record_type', '3': 2, '4': 1, '5': 9, '10': 'recordType'},
  ],
};

/// Descriptor for `DNSRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dNSRequestDescriptor = $convert.base64Decode(
    'CgpETlNSZXF1ZXN0EhoKCGhvc3RuYW1lGAEgASgJUghob3N0bmFtZRIfCgtyZWNvcmRfdHlwZR'
    'gCIAEoCVIKcmVjb3JkVHlwZQ==');

@$core.Deprecated('Use dNSResponseDescriptor instead')
const DNSResponse$json = {
  '1': 'DNSResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'hostname', '3': 2, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'addresses', '3': 3, '4': 3, '5': 9, '10': 'addresses'},
    {
      '1': 'records',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.picontrol.DNSRecord',
      '10': 'records'
    },
    {'1': 'query_time', '3': 5, '4': 1, '5': 1, '10': 'queryTime'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `DNSResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dNSResponseDescriptor = $convert.base64Decode(
    'CgtETlNSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEhoKCGhvc3RuYW1lGAIgAS'
    'gJUghob3N0bmFtZRIcCglhZGRyZXNzZXMYAyADKAlSCWFkZHJlc3NlcxIuCgdyZWNvcmRzGAQg'
    'AygLMhQucGljb250cm9sLkROU1JlY29yZFIHcmVjb3JkcxIdCgpxdWVyeV90aW1lGAUgASgBUg'
    'lxdWVyeVRpbWUSFAoFZXJyb3IYBiABKAlSBWVycm9y');

@$core.Deprecated('Use dNSRecordDescriptor instead')
const DNSRecord$json = {
  '1': 'DNSRecord',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
    {'1': 'ttl', '3': 3, '4': 1, '5': 5, '10': 'ttl'},
    {'1': 'priority', '3': 4, '4': 1, '5': 5, '10': 'priority'},
  ],
};

/// Descriptor for `DNSRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dNSRecordDescriptor = $convert.base64Decode(
    'CglETlNSZWNvcmQSEgoEdHlwZRgBIAEoCVIEdHlwZRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWUSEA'
    'oDdHRsGAMgASgFUgN0dGwSGgoIcHJpb3JpdHkYBCABKAVSCHByaW9yaXR5');

@$core.Deprecated('Use tracerouteRequestDescriptor instead')
const TracerouteRequest$json = {
  '1': 'TracerouteRequest',
  '2': [
    {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    {'1': 'max_hops', '3': 2, '4': 1, '5': 5, '10': 'maxHops'},
    {'1': 'timeout', '3': 3, '4': 1, '5': 5, '10': 'timeout'},
  ],
};

/// Descriptor for `TracerouteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tracerouteRequestDescriptor = $convert.base64Decode(
    'ChFUcmFjZXJvdXRlUmVxdWVzdBISCgRob3N0GAEgASgJUgRob3N0EhkKCG1heF9ob3BzGAIgAS'
    'gFUgdtYXhIb3BzEhgKB3RpbWVvdXQYAyABKAVSB3RpbWVvdXQ=');

@$core.Deprecated('Use tracerouteResponseDescriptor instead')
const TracerouteResponse$json = {
  '1': 'TracerouteResponse',
  '2': [
    {'1': 'hop', '3': 1, '4': 1, '5': 5, '10': 'hop'},
    {'1': 'ip', '3': 2, '4': 1, '5': 9, '10': 'ip'},
    {'1': 'hostname', '3': 3, '4': 1, '5': 9, '10': 'hostname'},
    {'1': 'latency', '3': 4, '4': 1, '5': 1, '10': 'latency'},
    {'1': 'timeout', '3': 5, '4': 1, '5': 8, '10': 'timeout'},
    {'1': 'finished', '3': 6, '4': 1, '5': 8, '10': 'finished'},
    {'1': 'error', '3': 7, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `TracerouteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tracerouteResponseDescriptor = $convert.base64Decode(
    'ChJUcmFjZXJvdXRlUmVzcG9uc2USEAoDaG9wGAEgASgFUgNob3ASDgoCaXAYAiABKAlSAmlwEh'
    'oKCGhvc3RuYW1lGAMgASgJUghob3N0bmFtZRIYCgdsYXRlbmN5GAQgASgBUgdsYXRlbmN5EhgK'
    'B3RpbWVvdXQYBSABKAhSB3RpbWVvdXQSGgoIZmluaXNoZWQYBiABKAhSCGZpbmlzaGVkEhQKBW'
    'Vycm9yGAcgASgJUgVlcnJvcg==');

@$core.Deprecated('Use wifiInfoDescriptor instead')
const WifiInfo$json = {
  '1': 'WifiInfo',
  '2': [
    {'1': 'connected', '3': 1, '4': 1, '5': 8, '10': 'connected'},
    {'1': 'ssid', '3': 2, '4': 1, '5': 9, '10': 'ssid'},
    {'1': 'bssid', '3': 3, '4': 1, '5': 9, '10': 'bssid'},
    {'1': 'signal_strength', '3': 4, '4': 1, '5': 5, '10': 'signalStrength'},
    {'1': 'signal_quality', '3': 5, '4': 1, '5': 5, '10': 'signalQuality'},
    {'1': 'frequency', '3': 6, '4': 1, '5': 1, '10': 'frequency'},
    {'1': 'security', '3': 7, '4': 1, '5': 9, '10': 'security'},
    {'1': 'link_speed', '3': 8, '4': 1, '5': 1, '10': 'linkSpeed'},
    {'1': 'ip_address', '3': 9, '4': 1, '5': 9, '10': 'ipAddress'},
    {
      '1': 'available_networks',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.picontrol.WifiNetwork',
      '10': 'availableNetworks'
    },
  ],
};

/// Descriptor for `WifiInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wifiInfoDescriptor = $convert.base64Decode(
    'CghXaWZpSW5mbxIcCgljb25uZWN0ZWQYASABKAhSCWNvbm5lY3RlZBISCgRzc2lkGAIgASgJUg'
    'Rzc2lkEhQKBWJzc2lkGAMgASgJUgVic3NpZBInCg9zaWduYWxfc3RyZW5ndGgYBCABKAVSDnNp'
    'Z25hbFN0cmVuZ3RoEiUKDnNpZ25hbF9xdWFsaXR5GAUgASgFUg1zaWduYWxRdWFsaXR5EhwKCW'
    'ZyZXF1ZW5jeRgGIAEoAVIJZnJlcXVlbmN5EhoKCHNlY3VyaXR5GAcgASgJUghzZWN1cml0eRId'
    'CgpsaW5rX3NwZWVkGAggASgBUglsaW5rU3BlZWQSHQoKaXBfYWRkcmVzcxgJIAEoCVIJaXBBZG'
    'RyZXNzEkUKEmF2YWlsYWJsZV9uZXR3b3JrcxgKIAMoCzIWLnBpY29udHJvbC5XaWZpTmV0d29y'
    'a1IRYXZhaWxhYmxlTmV0d29ya3M=');

@$core.Deprecated('Use wifiNetworkDescriptor instead')
const WifiNetwork$json = {
  '1': 'WifiNetwork',
  '2': [
    {'1': 'ssid', '3': 1, '4': 1, '5': 9, '10': 'ssid'},
    {'1': 'bssid', '3': 2, '4': 1, '5': 9, '10': 'bssid'},
    {'1': 'signal_strength', '3': 3, '4': 1, '5': 5, '10': 'signalStrength'},
    {'1': 'signal_quality', '3': 4, '4': 1, '5': 5, '10': 'signalQuality'},
    {'1': 'frequency', '3': 5, '4': 1, '5': 1, '10': 'frequency'},
    {'1': 'security', '3': 6, '4': 1, '5': 9, '10': 'security'},
  ],
};

/// Descriptor for `WifiNetwork`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wifiNetworkDescriptor = $convert.base64Decode(
    'CgtXaWZpTmV0d29yaxISCgRzc2lkGAEgASgJUgRzc2lkEhQKBWJzc2lkGAIgASgJUgVic3NpZB'
    'InCg9zaWduYWxfc3RyZW5ndGgYAyABKAVSDnNpZ25hbFN0cmVuZ3RoEiUKDnNpZ25hbF9xdWFs'
    'aXR5GAQgASgFUg1zaWduYWxRdWFsaXR5EhwKCWZyZXF1ZW5jeRgFIAEoAVIJZnJlcXVlbmN5Eh'
    'oKCHNlY3VyaXR5GAYgASgJUghzZWN1cml0eQ==');

@$core.Deprecated('Use speedTestRequestDescriptor instead')
const SpeedTestRequest$json = {
  '1': 'SpeedTestRequest',
  '2': [
    {'1': 'test_download', '3': 1, '4': 1, '5': 8, '10': 'testDownload'},
    {'1': 'test_upload', '3': 2, '4': 1, '5': 8, '10': 'testUpload'},
    {'1': 'duration', '3': 3, '4': 1, '5': 5, '10': 'duration'},
  ],
};

/// Descriptor for `SpeedTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speedTestRequestDescriptor = $convert.base64Decode(
    'ChBTcGVlZFRlc3RSZXF1ZXN0EiMKDXRlc3RfZG93bmxvYWQYASABKAhSDHRlc3REb3dubG9hZB'
    'IfCgt0ZXN0X3VwbG9hZBgCIAEoCFIKdGVzdFVwbG9hZBIaCghkdXJhdGlvbhgDIAEoBVIIZHVy'
    'YXRpb24=');

@$core.Deprecated('Use speedTestResponseDescriptor instead')
const SpeedTestResponse$json = {
  '1': 'SpeedTestResponse',
  '2': [
    {'1': 'phase', '3': 1, '4': 1, '5': 9, '10': 'phase'},
    {'1': 'download_speed', '3': 2, '4': 1, '5': 1, '10': 'downloadSpeed'},
    {'1': 'upload_speed', '3': 3, '4': 1, '5': 1, '10': 'uploadSpeed'},
    {'1': 'progress', '3': 4, '4': 1, '5': 1, '10': 'progress'},
    {'1': 'latency', '3': 5, '4': 1, '5': 1, '10': 'latency'},
    {'1': 'server', '3': 6, '4': 1, '5': 9, '10': 'server'},
    {'1': 'finished', '3': 7, '4': 1, '5': 8, '10': 'finished'},
    {'1': 'error', '3': 8, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `SpeedTestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speedTestResponseDescriptor = $convert.base64Decode(
    'ChFTcGVlZFRlc3RSZXNwb25zZRIUCgVwaGFzZRgBIAEoCVIFcGhhc2USJQoOZG93bmxvYWRfc3'
    'BlZWQYAiABKAFSDWRvd25sb2FkU3BlZWQSIQoMdXBsb2FkX3NwZWVkGAMgASgBUgt1cGxvYWRT'
    'cGVlZBIaCghwcm9ncmVzcxgEIAEoAVIIcHJvZ3Jlc3MSGAoHbGF0ZW5jeRgFIAEoAVIHbGF0ZW'
    '5jeRIWCgZzZXJ2ZXIYBiABKAlSBnNlcnZlchIaCghmaW5pc2hlZBgHIAEoCFIIZmluaXNoZWQS'
    'FAoFZXJyb3IYCCABKAlSBWVycm9y');

@$core.Deprecated('Use fileChunkDescriptor instead')
const FileChunk$json = {
  '1': 'FileChunk',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
    {'1': 'offset', '3': 3, '4': 1, '5': 3, '10': 'offset'},
    {'1': 'total_size', '3': 4, '4': 1, '5': 3, '10': 'totalSize'},
    {'1': 'is_final', '3': 5, '4': 1, '5': 8, '10': 'isFinal'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `FileChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileChunkDescriptor = $convert.base64Decode(
    'CglGaWxlQ2h1bmsSEgoEcGF0aBgBIAEoCVIEcGF0aBISCgRkYXRhGAIgASgMUgRkYXRhEhYKBm'
    '9mZnNldBgDIAEoA1IGb2Zmc2V0Eh0KCnRvdGFsX3NpemUYBCABKANSCXRvdGFsU2l6ZRIZCghp'
    'c19maW5hbBgFIAEoCFIHaXNGaW5hbBIUCgVlcnJvchgGIAEoCVIFZXJyb3I=');

@$core.Deprecated('Use fileUploadResponseDescriptor instead')
const FileUploadResponse$json = {
  '1': 'FileUploadResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
    {'1': 'bytes_written', '3': 3, '4': 1, '5': 3, '10': 'bytesWritten'},
    {'1': 'error', '3': 4, '4': 1, '5': 9, '10': 'error'},
    {'1': 'duration', '3': 5, '4': 1, '5': 1, '10': 'duration'},
  ],
};

/// Descriptor for `FileUploadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileUploadResponseDescriptor = $convert.base64Decode(
    'ChJGaWxlVXBsb2FkUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxISCgRwYXRoGA'
    'IgASgJUgRwYXRoEiMKDWJ5dGVzX3dyaXR0ZW4YAyABKANSDGJ5dGVzV3JpdHRlbhIUCgVlcnJv'
    'chgEIAEoCVIFZXJyb3ISGgoIZHVyYXRpb24YBSABKAFSCGR1cmF0aW9u');

@$core.Deprecated('Use fileDownloadRequestDescriptor instead')
const FileDownloadRequest$json = {
  '1': 'FileDownloadRequest',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'offset', '3': 2, '4': 1, '5': 3, '10': 'offset'},
  ],
};

/// Descriptor for `FileDownloadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDownloadRequestDescriptor = $convert.base64Decode(
    'ChNGaWxlRG93bmxvYWRSZXF1ZXN0EhIKBHBhdGgYASABKAlSBHBhdGgSFgoGb2Zmc2V0GAIgAS'
    'gDUgZvZmZzZXQ=');

@$core.Deprecated('Use fileDeleteRequestDescriptor instead')
const FileDeleteRequest$json = {
  '1': 'FileDeleteRequest',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'is_directory', '3': 2, '4': 1, '5': 8, '10': 'isDirectory'},
  ],
};

/// Descriptor for `FileDeleteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDeleteRequestDescriptor = $convert.base64Decode(
    'ChFGaWxlRGVsZXRlUmVxdWVzdBISCgRwYXRoGAEgASgJUgRwYXRoEiEKDGlzX2RpcmVjdG9yeR'
    'gCIAEoCFILaXNEaXJlY3Rvcnk=');

@$core.Deprecated('Use fileDeleteResponseDescriptor instead')
const FileDeleteResponse$json = {
  '1': 'FileDeleteResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '10': 'error'},
  ],
};

/// Descriptor for `FileDeleteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDeleteResponseDescriptor = $convert.base64Decode(
    'ChJGaWxlRGVsZXRlUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxISCgRwYXRoGA'
    'IgASgJUgRwYXRoEhQKBWVycm9yGAMgASgJUgVlcnJvcg==');
