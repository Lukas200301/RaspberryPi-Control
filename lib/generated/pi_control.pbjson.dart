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
    'CXRpbWVzdGFtcBgSIAEoA1IJdGltZXN0YW1w');

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
